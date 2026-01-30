import 'package:flutter/foundation.dart';
import 'package:jellyfin_dart/jellyfin_dart.dart';
import 'package:playcado/media/data/media_remote_data_source.dart';
import 'package:playcado/services/logger_service.dart';
import 'package:playcado/services/media_url/media_url_service.dart';

class PlaybackRepository {
  final MediaRemoteDataSource _dataSource;
  final MediaUrlService _urlGenerator;

  PlaybackRepository({
    required MediaRemoteDataSource dataSource,
    required MediaUrlService urlGenerator,
  }) : _dataSource = dataSource,
       _urlGenerator = urlGenerator;

  Future<void> reportPlaybackStart(String itemId) async {
    try {
      LoggerService.api.fine('Reporting playback START: $itemId');
      await _dataSource.reportPlaybackStart(
        itemId: itemId,
        playMethod: PlayMethod.directPlay,
      );
    } catch (e) {
      LoggerService.api.warning('Failed to report playback start', e);
    }
  }

  Future<void> reportPlaybackProgress({
    required String itemId,
    required int positionTicks,
    bool isPaused = false,
  }) async {
    try {
      LoggerService.api.finest('Reporting progress: $itemId @ $positionTicks');
      await _dataSource.reportPlaybackProgress(
        itemId: itemId,
        positionTicks: positionTicks,
        isPaused: isPaused,
        playMethod: PlayMethod.directPlay,
      );
    } catch (e) {
      LoggerService.api.finer('Failed to report playback progress', e);
    }
  }

  Future<void> reportPlaybackStopped({
    required String itemId,
    required int positionTicks,
  }) async {
    try {
      LoggerService.api.fine('Reporting playback STOPPED: $itemId');
      await _dataSource.reportPlaybackStopped(
        itemId: itemId,
        positionTicks: positionTicks,
      );
    } catch (e) {
      LoggerService.api.warning('Failed to report playback stop', e);
    }
  }

  Future<void> togglePlayedStatus(String itemId, bool isPlayed) async {
    try {
      final userId = await _dataSource.getCurrentUserId();
      if (userId == null) return;

      if (isPlayed) {
        await _dataSource.markPlayedItem(userId: userId, itemId: itemId);
      } else {
        await _dataSource.markUnplayedItem(userId: userId, itemId: itemId);
      }
    } catch (e) {
      LoggerService.api.warning('Failed to toggle played status', e);
    }
  }

  String getStreamUrl(String itemId) {
    return _urlGenerator.getStreamUrl(itemId);
  }

  String getDownloadUrl(String itemId, {int? maxHeight}) {
    return _urlGenerator.getDownloadUrl(itemId, maxHeight: maxHeight);
  }

  Future<String> getCastUrl(String itemId) async {
    LoggerService.api.info('Generating Cast URL for item: $itemId');

    try {
      final userId = await _dataSource.getCurrentUserId();
      if (userId == null) throw Exception('Unable to get current user');

      final items = await _dataSource.fetchItems(
        userId: userId,
        ids: [itemId],
        fields: [ItemFields.mediaSources],
      );

      if (items.isEmpty) {
        LoggerService.api.warning('Item not found for cast: $itemId');
        throw Exception('Item not found');
      }

      final mediaItem = items.first;
      final mediaSourceId = mediaItem.mediaSourceId;

      if (mediaSourceId == null) {
        LoggerService.api.warning('No media sources for cast: $itemId');
        throw Exception('No MediaSources found for item: $itemId');
      }

      final url = _urlGenerator.generateTranscodeUrl(
        itemId: itemId,
        mediaSourceId: mediaSourceId,
      );

      LoggerService.api.info('CAST URL Generated successfully');
      debugPrint('CAST URL: $url');
      return url;
    } catch (e, s) {
      LoggerService.api.severe('Error generating cast URL', e, s);
      rethrow;
    }
  }
}
