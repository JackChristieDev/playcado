part of 'series_details_bloc.dart';

abstract class SeriesDetailsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchSeasons extends SeriesDetailsEvent {
  final String seriesId;
  FetchSeasons({required this.seriesId});
  @override
  List<Object> get props => [seriesId];
}

class FetchEpisodes extends SeriesDetailsEvent {
  final String seriesId;
  final String seasonId;

  FetchEpisodes({required this.seriesId, required this.seasonId});

  @override
  List<Object> get props => [seriesId, seasonId];
}

class FetchNextEpisode extends SeriesDetailsEvent {
  final String seriesId;
  FetchNextEpisode({required this.seriesId});
  @override
  List<Object> get props => [seriesId];
}

class FetchSeriesMetadata extends SeriesDetailsEvent {
  final String seriesId;
  FetchSeriesMetadata({required this.seriesId});
  @override
  List<Object> get props => [seriesId];
}

class CollapseSeason extends SeriesDetailsEvent {}

class FetchItemDetails extends SeriesDetailsEvent {
  final String itemId;
  FetchItemDetails({required this.itemId});
  @override
  List<Object> get props => [itemId];
}

class FetchSelectedEpisodeDetails extends SeriesDetailsEvent {
  final String episodeId;
  FetchSelectedEpisodeDetails({required this.episodeId});
  @override
  List<Object> get props => [episodeId];
}

class TogglePlayedStatus extends SeriesDetailsEvent {}

class SelectEpisode extends SeriesDetailsEvent {
  final MediaItem episode;
  SelectEpisode({required this.episode});
  @override
  List<Object> get props => [episode];
}

/// Updates the local playback position for an item in the state
class UpdateLocalPlaybackProgress extends SeriesDetailsEvent {
  final String itemId;
  final int positionTicks;

  UpdateLocalPlaybackProgress({
    required this.itemId,
    required this.positionTicks,
  });

  @override
  List<Object> get props => [itemId, positionTicks];
}
