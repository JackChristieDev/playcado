part of 'home_bloc.dart';

class HomeState extends Equatable {
  final StatusWrapper<List<MediaItem>> continueWatching;
  final StatusWrapper<List<MediaItem>> nextUp;
  final StatusWrapper<List<MediaItem>> latestMovies;
  final StatusWrapper<List<MediaItem>> latestTv;

  const HomeState({
    this.continueWatching = const StatusWrapper(),
    this.nextUp = const StatusWrapper(),
    this.latestMovies = const StatusWrapper(),
    this.latestTv = const StatusWrapper(),
  });

  HomeState copyWith({
    StatusWrapper<List<MediaItem>>? continueWatching,
    StatusWrapper<List<MediaItem>>? nextUp,
    StatusWrapper<List<MediaItem>>? latestMovies,
    StatusWrapper<List<MediaItem>>? latestTv,
  }) {
    return HomeState(
      continueWatching: continueWatching ?? this.continueWatching,
      nextUp: nextUp ?? this.nextUp,
      latestMovies: latestMovies ?? this.latestMovies,
      latestTv: latestTv ?? this.latestTv,
    );
  }

  @override
  List<Object> get props => [continueWatching, nextUp, latestMovies, latestTv];
}
