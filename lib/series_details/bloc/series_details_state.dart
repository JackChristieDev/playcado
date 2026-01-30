part of 'series_details_bloc.dart';

class SeriesDetailsState extends Equatable {
  final StatusWrapper<List<MediaItem>> seasons;
  final StatusWrapper<Map<String, List<MediaItem>>> episodes;
  final StatusWrapper<MediaItem> nextEpisode;
  final StatusWrapper<MediaItem> series;
  final String? expandedSeasonId;
  final bool isResuming;
  final MediaItem? selectedEpisode;

  const SeriesDetailsState({
    this.seasons = const StatusWrapper(),
    this.episodes = const StatusWrapper(),
    this.nextEpisode = const StatusWrapper(),
    this.series = const StatusWrapper(),
    this.expandedSeasonId,
    this.isResuming = false,
    this.selectedEpisode,
  });

  SeriesDetailsState copyWith({
    StatusWrapper<List<MediaItem>>? seasons,
    StatusWrapper<Map<String, List<MediaItem>>>? episodes,
    StatusWrapper<MediaItem>? nextEpisode,
    StatusWrapper<MediaItem>? series,
    String? expandedSeasonId,
    bool clearExpandedSeasonId = false,
    bool? isResuming,
    ValueGetter<MediaItem?>? selectedEpisode,
  }) {
    return SeriesDetailsState(
      seasons: seasons ?? this.seasons,
      episodes: episodes ?? this.episodes,
      nextEpisode: nextEpisode ?? this.nextEpisode,
      series: series ?? this.series,
      expandedSeasonId: clearExpandedSeasonId
          ? null
          : (expandedSeasonId ?? this.expandedSeasonId),
      isResuming: isResuming ?? this.isResuming,
      selectedEpisode:
          selectedEpisode != null ? selectedEpisode() : this.selectedEpisode,
    );
  }

  @override
  List<Object?> get props => [
        seasons,
        episodes,
        nextEpisode,
        series,
        expandedSeasonId,
        isResuming,
        selectedEpisode,
      ];
}
