import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:playcado/services/logger_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class PlayerService {
  late final Player player;
  late final VideoController controller;
  bool _isInitialized = false;

  PlayerService() {
    _init();
  }

  void _init() {
    player = Player();
    controller = VideoController(
      player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
        androidAttachSurfaceAfterVideoParameters: true,
      ),
    );
    _initAudioSession();
    _isInitialized = true;
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
        avAudioSessionMode: AVAudioSessionMode.moviePlayback,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.movie,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ),
    );
  }

  Future<void> playMedia(
    String source, {
    Map<String, String>? headers,
    Duration? startPosition,
  }) async {
    if (!_isInitialized) _init();

    LoggerService.player.info('Opening media: $source');
    await WakelockPlus.enable();

    await player.open(Media(source, httpHeaders: headers), play: false);

    if (startPosition != null && startPosition != Duration.zero) {
      await player.stream.duration.firstWhere((d) => d > Duration.zero);
      await player.seek(startPosition);
    }
    await player.play();
  }

  Future<void> stop() async {
    await player.stop();
    await WakelockPlus.disable();
  }

  Future<void> play() async => await player.play();
  Future<void> pause() async => await player.pause();
  Future<void> seek(Duration position) async => await player.seek(position);

  void dispose() {
    player.dispose();
    WakelockPlus.disable();
  }
}
