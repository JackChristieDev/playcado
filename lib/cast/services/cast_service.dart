import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'package:playcado/cast/models/cast_item.dart';
import 'package:playcado/services/logger_service.dart';

/// Manages Google Cast functionality.
class CastService {
  /// Initializes the Cast service.
  CastService();

  /// The session manager for handling Cast sessions.
  final _sessionManager = GoogleCastSessionManager.instance;

  /// The discovery manager for handling Cast device discovery.
  final _discoveryManager = GoogleCastDiscoveryManager.instance;

  /// The remote media client for handling media playback.
  final _remoteMediaClient = GoogleCastRemoteMediaClient.instance;

  /// Whether the Cast service is initialized.
  bool _isInitialized = false;

  /// Whether the device is currently connected to a Cast device.
  bool _isConnected = false;

  /// Notifier for local playback state handling
  /// Default is false (paused/stopped)
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);

  /// Convenience getter for current state
  bool get isPlaying => isPlayingNotifier.value;

  /// Whether the current platform supports Google Cast.
  bool get _isSupportedPlatform => Platform.isIOS || Platform.isAndroid;

  /// The stream of discovered Cast devices.
  Stream<List<GoogleCastDevice>> get devicesStream =>
      _discoveryManager.devicesStream;

  /// The stream of the current Cast session.
  Stream<GoogleCastSession?> get currentSessionStream =>
      _sessionManager.currentSessionStream;

  /// The stream of media status updates.
  Stream<GoggleCastMediaStatus?> get mediaStatusStream =>
      _remoteMediaClient.mediaStatusStream;

  /// The current Cast session.
  GoogleCastSession? get currentSession => _sessionManager.currentSession;

  /// Whether the device is currently connected to a Cast device.
  bool get isConnected =>
      _sessionManager.connectionState == GoogleCastConnectState.connected;

  /// Initializes the Cast service.
  Future<void> initialize() async {
    if (!_isSupportedPlatform || _isInitialized) return;

    LoggerService.castService.info('Initializing Google Cast Options');
    const appId = GoogleCastDiscoveryCriteria.kDefaultApplicationId;

    GoogleCastOptions? options;
    if (Platform.isIOS) {
      options = IOSGoogleCastOptions(
        GoogleCastDiscoveryCriteriaInitialize.initWithApplicationID(appId),
      );
    } else if (Platform.isAndroid) {
      options = GoogleCastOptionsAndroid(appId: appId);
    }

    if (options != null) {
      await GoogleCastContext.instance.setSharedInstanceWithOptions(options);
    }

    _isInitialized = true;

    // Explicitly start discovery scan
    _discoveryManager.startDiscovery();

    currentSessionStream.listen((session) {
      LoggerService.castService.info(
        'Cast Session: ConnectionState:${session?.connectionState}, Device:${session?.device?.friendlyName}, SessionID:${session?.sessionID}, Muted:${session?.currentDeviceMuted}, Volume:${session?.currentDeviceVolume}, Status:${session?.deviceStatusText}',
      );
      if (session?.connectionState == GoogleCastConnectState.connected) {
        if (_isConnected) return;
        _isConnected = true;
      } else {
        _isConnected = false;
      }
    });

    devicesStream.listen((devices) {
      LoggerService.castService.info('Discovered devices: ${devices.length}');
    });

    mediaStatusStream.listen((status) {
      LoggerService.castService.info(
        'Media status: PlayerState:${status?.playerState}, MediaSessionID:${status?.mediaSessionID}',
      );

      // Sync local state with remote status
      final state = status?.playerState;
      final playing =
          state == CastMediaPlayerState.playing ||
          state == CastMediaPlayerState.buffering;

      // Only update if changed to avoid unnecessary rebuilds
      if (isPlayingNotifier.value != playing) {
        isPlayingNotifier.value = playing;
      }
    });
  }

  Future<void> connect(GoogleCastDevice device) async {
    if (!_isSupportedPlatform) return;
    LoggerService.castService.info(
      'Connecting to Cast device: ${device.friendlyName}',
    );
    try {
      await _sessionManager.startSessionWithDevice(device);
    } catch (e, stack) {
      LoggerService.castService.severe(
        'Failed to connect to Cast device',
        e,
        stack,
      );
    }
  }

  Future<void> disconnect() async {
    if (!_isSupportedPlatform) return;
    LoggerService.castService.info('Disconnecting from Cast device...');
    try {
      await _sessionManager.endSessionAndStopCasting();
      // Reset state on disconnect
      isPlayingNotifier.value = false;
    } catch (e, stack) {
      LoggerService.castService.severe('Failed to disconnect Cast', e, stack);
    }
  }

  /// Waits until the device is connected to a Cast session.
  Future<bool> waitUntilConnected({
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (isConnected) return true;

    try {
      await currentSessionStream
          .firstWhere(
            (session) =>
                session?.connectionState == GoogleCastConnectState.connected,
          )
          .timeout(timeout);
      return true;
    } catch (e) {
      LoggerService.castService.warning('Wait for connection timed out: $e');
      return false;
    }
  }

  Future<void> play() async {
    if (!_isSupportedPlatform) return;
    // Optimistic update
    isPlayingNotifier.value = true;
    try {
      await _remoteMediaClient.play();
    } catch (e, stack) {
      LoggerService.castService.warning('Failed to play', e, stack);
    }
  }

  Future<void> pause() async {
    if (!_isSupportedPlatform) return;
    // Optimistic update
    isPlayingNotifier.value = false;
    try {
      await _remoteMediaClient.pause();
    } catch (e, stack) {
      LoggerService.castService.warning('Failed to pause', e, stack);
    }
  }

  Future<void> stop() async {
    if (!_isSupportedPlatform) return;
    // Optimistic update
    isPlayingNotifier.value = false;
    try {
      await _remoteMediaClient.stop();
    } catch (e, stack) {
      LoggerService.castService.warning('Failed to stop', e, stack);
    }
  }

  Future<void> seek(Duration position) async {
    if (!_isSupportedPlatform) return;
    try {
      await _remoteMediaClient.seek(
        GoogleCastMediaSeekOption(position: position),
      );
    } catch (e, stack) {
      LoggerService.castService.warning('Failed to seek', e, stack);
    }
  }

  /// Loads media onto the cast device.
  /// [streamUrl] and [imageUrl] must be valid, accessible URLs.
  Future<void> loadMedia(CastItem castItem, {Duration? playPosition}) async {
    if (!_isSupportedPlatform) {
      LoggerService.castService.warning('Cannot cast from this platform.');
      return;
    }
    if (!isConnected) return;

    // Small delay for Android stability after session connect
    if (Platform.isAndroid) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final uri = Uri.parse(castItem.streamUrl);

    LoggerService.castService.info(
      'Preparing to cast URL: ${castItem.streamUrl}',
    );

    DateTime releaseDate = DateTime.now();
    if (castItem.mediaItem.productionYear != null) {
      try {
        releaseDate = DateTime(int.parse(castItem.mediaItem.productionYear!));
      } catch (_) {}
    }

    final mediaInfo = GoogleCastMediaInformation(
      contentId: castItem.streamUrl,
      contentUrl: uri,
      streamType: CastMediaStreamType.buffered,
      contentType: castItem.correctMimeType,
      metadata: GoogleCastMovieMediaMetadata(
        title: castItem.mediaItem.name,
        subtitle: castItem.mediaItem.seriesName ?? '',
        studio: 'Playcado',
        releaseDate: releaseDate,
        images: [
          if (castItem.imageUrl.isNotEmpty)
            GoogleCastImage(
              url: Uri.parse(castItem.imageUrl),
              width: 480,
              height: 720,
            ),
        ],
      ),
    );

    try {
      await _remoteMediaClient.loadMedia(
        mediaInfo,
        autoPlay: true,
        playPosition: playPosition ?? Duration.zero,
      );
      LoggerService.castService.info(
        'Cast loadMedia command sent successfully',
      );
      isPlayingNotifier.value = true;
    } catch (e, stack) {
      LoggerService.castService.severe(
        'Failed to load media on Cast',
        e,
        stack,
      );
      rethrow;
    }
  }
}
