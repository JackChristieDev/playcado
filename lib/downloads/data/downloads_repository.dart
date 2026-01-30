import 'dart:async';
import 'dart:convert';

import 'package:background_downloader/background_downloader.dart';
import 'package:playcado/downloads/models/download_item.dart';
import 'package:playcado/services/logger_service.dart';

class DownloadsRepository {
  final _controller = StreamController<List<DownloadItem>>.broadcast();

  /// In-memory cache of items
  final Map<String, DownloadItem> _items = {};

  /// Tracks IDs currently being deleted to prevent race conditions
  /// where terminal updates resurrect the item in the UI.
  final Set<String> _processingDeletions = {};

  Stream<List<DownloadItem>> get downloads => _controller.stream;
  List<DownloadItem> get currentDownloads => _items.values.toList();

  DownloadsRepository() {
    _init();
  }

  Future<void> _init() async {
    try {
      // 1. Configure Plugin
      await FileDownloader().configure(
        globalConfig: [(Config.requestTimeout, const Duration(seconds: 100))],
      );

      // 2. Start Listeners
      // We use an async listener to verify task existence in DB before resurrection
      FileDownloader().updates.listen(_onUpdate);

      // 3. Enable Tracking & Database (essential for persistent status)
      await FileDownloader().trackTasks();

      // Activate the database and ensure proper restart after suspend/kill
      await FileDownloader().start();

      // 4. Load existing tasks from Plugin Database
      final records = await FileDownloader().database.allRecords();

      for (final record in records) {
        try {
          if (record.task.metaData.isNotEmpty) {
            final jsonMap = jsonDecode(record.task.metaData);
            final item = DownloadItem.fromJson(jsonMap);
            final path = await record.task.filePath();

            _items[record.taskId] = item.copyWith(
              status: _mapStatus(record.status),
              progress: record.progress,
              localPath: path,
            );
          }
        } catch (e, s) {
          LoggerService.downloads.warning(
            'Failed to parse download record: ${record.taskId}',
            e,
            s,
          );
        }
      }
    } catch (e, s) {
      LoggerService.downloads.severe('DownloadsRepository init failed', e, s);
    }
    _emit();
  }

  DownloadStatus _mapStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.enqueued:
      case TaskStatus.waitingToRetry:
        return DownloadStatus.queued;
      case TaskStatus.running:
        return DownloadStatus.downloading;
      case TaskStatus.complete:
        return DownloadStatus.completed;
      case TaskStatus.paused:
        return DownloadStatus.paused;
      case TaskStatus.canceled:
      case TaskStatus.failed:
      case TaskStatus.notFound:
        return DownloadStatus.error;
    }
  }

  Future<void> addDownload(DownloadItem item) async {
    // Basic sanitation for filename
    final safeName = item.name.replaceAll(RegExp(r'[^\w\s\.-]'), '');
    final filename = '$safeName.mp4';

    final task = DownloadTask(
      taskId: item.id,
      url: item.downloadUrl,
      filename: filename,
      baseDirectory: BaseDirectory.applicationDocuments,
      updates: Updates.statusAndProgress,
      allowPause: true,
    );

    // Resolve the absolute path before enqueuing to store it in metadata
    final absolutePath = await task.filePath();
    final itemWithPath = item.copyWith(
      localPath: absolutePath,
      status: DownloadStatus.queued,
    );

    // Store the FULL item in metaData so we can recover it later
    final metaString = jsonEncode(itemWithPath.toJson());
    final taskWithMeta = task.copyWith(metaData: metaString);

    // 2. Add to local memory immediately for UI responsiveness
    _items[item.id] = itemWithPath;
    _emit();

    // 3. Enqueue
    // Since we called trackTasks() in _init, this automatically adds/updates the DB record.
    try {
      await FileDownloader().enqueue(taskWithMeta);
    } catch (e, s) {
      LoggerService.downloads.severe('Failed to enqueue task', e, s);
      _items.remove(item.id);
      _emit();
      rethrow;
    }
  }

  /// Cancels and completely removes a download.
  ///
  /// The order of operations is critical here to prevent "resurrection" of the task
  /// in the UI via the stream listener.
  Future<void> deleteDownload(String id) async {
    _processingDeletions.add(id);

    try {
      // 1. Remove from local memory immediately.
      // The UI updates instantly to show the item is gone.
      _items.remove(id);
      _emit();

      // 2. Delete the record from the database.
      // This is the "source of truth". By removing it here, we ensure that
      // when the subsequent cancel event fires (step 3), the _onUpdate listener
      // will see that the record is missing from the DB and will NOT resurrect it.
      await FileDownloader().database.deleteRecordWithId(id);

      // 3. Cancel the actual native task.
      // This triggers a TaskStatus.canceled update, which our listener handles safely.
      await FileDownloader().cancelTaskWithId(id);
    } finally {
      // Small delay ensures any final native updates are ignored
      Future.delayed(const Duration(milliseconds: 500), () {
        _processingDeletions.remove(id);
      });
    }
  }

  Future<void> pauseDownload(String id) async {
    final task = await FileDownloader().taskForId(id);
    if (task is DownloadTask) {
      await FileDownloader().pause(task);
    }
  }

  Future<void> resumeDownload(String id) async {
    final task = await FileDownloader().taskForId(id);
    if (task is DownloadTask) {
      await FileDownloader().resume(task);
    }
  }

  Future<void> clearAll() async {
    // Clear in-memory list first
    _items.clear();
    _emit();

    // Clear persistence and cancel native tasks
    await FileDownloader().database.deleteAllRecords();
    await FileDownloader().cancelAll();
  }

  Future<void> _onUpdate(TaskUpdate update) async {
    final taskId = update.task.taskId;

    // Ignore updates for items currently being deleted
    if (_processingDeletions.contains(taskId)) return;

    // If the update is terminal, handle it and return
    if (update is TaskStatusUpdate && _isTerminalStatus(update.status)) {
      await _handleTerminalStatus(taskId);
      return;
    }

    // Handle completed downloads: Move to Shared Storage (Downloads folder)
    if (update is TaskStatusUpdate && update.status == TaskStatus.complete) {
      final task = update.task;
      if (task is DownloadTask) {
        final sharedPath = await FileDownloader().moveToSharedStorage(
          task,
          SharedStorage.downloads,
        );

        if (sharedPath != null) {
          LoggerService.downloads.info(
            'File moved to shared storage: $sharedPath',
          );
          final item = _items[taskId];
          if (item != null) {
            _items[taskId] = item.copyWith(
              localPath: sharedPath,
              status: DownloadStatus.completed,
            );
            _emit();
            return;
          }
        }
      }
    }

    final item = await _getOrCreateItem(taskId, update);
    if (item == null) return;

    final updatedItem = _updateItem(item, update);
    if (updatedItem == null) return;

    // Update in-memory list and emit
    _items[taskId] = updatedItem;
    _emit();
  }

  /// Whether a task status is terminal
  /// Canceled and NotFound are terminal states
  bool _isTerminalStatus(TaskStatus status) {
    return status == TaskStatus.canceled || status == TaskStatus.notFound;
  }

  /// Handles terminal states
  /// Canceled and NotFound are terminal states
  Future<void> _handleTerminalStatus(String taskId) async {
    if (_items.remove(taskId) != null) {
      _emit();
    }

    await FileDownloader().database.deleteRecordWithId(taskId);
  }

  /// Gets the item from the in-memory cache or creates it from the database
  Future<DownloadItem?> _getOrCreateItem(
    String taskId,
    TaskUpdate update,
  ) async {
    final existing = _items[taskId];
    if (existing != null) return existing;

    LoggerService.downloads.info('Item not in memory cache: $taskId');

    final record = await FileDownloader().database.recordForId(taskId);

    if (record == null) {
      LoggerService.downloads.info('No record exists for $taskId');
      return null;
    }

    if (update.task.metaData.isEmpty) return null;

    try {
      LoggerService.downloads.info(
        'Reconstructing item from metadata: $taskId',
      );

      final jsonMap = jsonDecode(update.task.metaData);
      final path = await update.task.filePath();
      final item = DownloadItem.fromJson(jsonMap).copyWith(localPath: path);
      _items[taskId] = item;
      return item;
    } catch (_) {
      LoggerService.downloads.warning(
        'Failed to reconstruct item from metadata: $taskId',
      );
      return null;
    }
  }

  /// Applies an update to the item
  DownloadItem? _updateItem(DownloadItem item, TaskUpdate update) {
    switch (update) {
      case TaskStatusUpdate():
        LoggerService.downloads.info(
          'Status update: ${update.task.taskId} → ${update.status}',
        );
        return item.copyWith(status: _mapStatus(update.status));

      case TaskProgressUpdate():
        LoggerService.downloads.info(
          'Progress update: ${update.task.taskId} → ${update.progress}',
        );

        final total = update.expectedFileSize > 0
            ? update.expectedFileSize
            : item.totalBytes;

        final received = total > 0 ? (total * update.progress).round() : 0;

        return item.copyWith(
          progress: update.progress,
          networkSpeed: update.networkSpeed * 1024 * 1024,
          totalBytes: total,
          receivedBytes: received,
        );
    }
  }

  void _emit() => _controller.add(_items.values.toList());
}
