part of 'video_player_bloc.dart';

abstract class VideoPlayerEvent extends Equatable {
  const VideoPlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayerPlayRequested extends VideoPlayerEvent {
  final MediaItem item;
  final String? localPath;

  const PlayerPlayRequested({required this.item, this.localPath});

  @override
  List<Object?> get props => [item, localPath];
}

class PlayerStopRequested extends VideoPlayerEvent {}

class PlayerPauseRequested extends VideoPlayerEvent {}

class PlayerResumeRequested extends VideoPlayerEvent {}

class PlayerPositionUpdated extends VideoPlayerEvent {
  final Duration position;
  const PlayerPositionUpdated(this.position);

  @override
  List<Object?> get props => [position];
}

class PlayerStatusUpdated extends VideoPlayerEvent {
  final bool isPlaying;
  const PlayerStatusUpdated(this.isPlaying);

  @override
  List<Object?> get props => [isPlaying];
}

class PlayerCastRequested extends VideoPlayerEvent {
  final MediaItem item;

  const PlayerCastRequested({required this.item});

  @override
  List<Object?> get props => [item];
}

class PlayerSkipIntroRequested extends VideoPlayerEvent {}
