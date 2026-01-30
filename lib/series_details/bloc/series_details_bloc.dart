import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/core/status_wrapper.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/media/repos/library_repository.dart';
import 'package:playcado/media/repos/playback_repository.dart';
import 'package:playcado/services/logger_service.dart';

part 'series_details_event.dart';
part 'series_details_state.dart';

class SeriesDetailsBloc extends Bloc<SeriesDetailsEvent, SeriesDetailsState> {
  final LibraryRepository _libraryRepository;
  final PlaybackRepository _playbackRepository;

  SeriesDetailsBloc({
    required LibraryRepository libraryRepository,
    required PlaybackRepository playbackRepository,
  }) : _libraryRepository = libraryRepository,
       _playbackRepository = playbackRepository,
       super(const SeriesDetailsState()) {
    on<FetchSeasons>(_onFetchSeasons);
    on<FetchEpisodes>(_onFetchEpisodes);
    on<FetchNextEpisode>(_onFetchNextEpisode);
    on<FetchSeriesMetadata>(_onFetchSeriesMetadata);
    on<CollapseSeason>(_onCollapseSeason);
    on<FetchItemDetails>(_onFetchItemDetails);
    on<FetchSelectedEpisodeDetails>(_onFetchSelectedEpisodeDetails);
    on<TogglePlayedStatus>(_onTogglePlayedStatus);
    on<SelectEpisode>(_onSelectEpisode);
    on<UpdateLocalPlaybackProgress>(_onUpdateLocalPlaybackProgress);
  }

  Future<void> _onFetchSeasons(
    FetchSeasons event,
    Emitter<SeriesDetailsState> emit,
  ) async {
    emit(state.copyWith(seasons: state.seasons.toLoading()));
    try {
      final seasons = await _libraryRepository.getSeasons(event.seriesId);
      emit(state.copyWith(seasons: state.seasons.toSuccess(seasons)));

      if (seasons.isNotEmpty && state.expandedSeasonId == null) {
        add(
          FetchEpisodes(seriesId: event.seriesId, seasonId: seasons.first.id),
        );
      }
    } catch (e, stackTrace) {
      LoggerService.media.severe('Failed to fetch seasons', e, stackTrace);
      emit(state.copyWith(seasons: state.seasons.toError()));
    }
  }

  Future<void> _onFetchEpisodes(
    FetchEpisodes event,
    Emitter<SeriesDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        episodes: state.episodes.toLoading(),
        expandedSeasonId: event.seasonId,
      ),
    );
    try {
      final episodes = await _libraryRepository.getEpisodes(
        seriesId: event.seriesId,
        seasonId: event.seasonId,
      );
      final currentEpisodes = Map<String, List<MediaItem>>.from(
        state.episodes.value ?? {},
      );
      currentEpisodes[event.seasonId] = episodes;
      emit(state.copyWith(episodes: state.episodes.toSuccess(currentEpisodes)));
    } catch (e, stackTrace) {
      LoggerService.media.severe('Failed to fetch episodes', e, stackTrace);
      emit(state.copyWith(episodes: state.episodes.toError()));
    }
  }

  Future<void> _onFetchNextEpisode(
    FetchNextEpisode event,
    Emitter<SeriesDetailsState> emit,
  ) async {
    emit(state.copyWith(nextEpisode: state.nextEpisode.toLoading()));
    try {
      final resumeItems = await _libraryRepository.getResumeItems();
      final resumableEpisode = resumeItems.cast<MediaItem?>().firstWhere(
        (item) => item?.seriesId == event.seriesId,
        orElse: () => null,
      );

      if (resumableEpisode != null) {
        emit(
          state.copyWith(
            nextEpisode: state.nextEpisode.toSuccess(resumableEpisode),
            isResuming: true,
          ),
        );
        return;
      }

      var episode = await _libraryRepository.getNextEpisode(event.seriesId);
      episode ??= await _libraryRepository.getFirstEpisode(event.seriesId);

      emit(
        state.copyWith(
          nextEpisode: state.nextEpisode.toSuccess(episode),
          isResuming: false,
        ),
      );
    } catch (e, stackTrace) {
      LoggerService.media.severe('Failed to fetch next episode', e, stackTrace);
      emit(state.copyWith(nextEpisode: state.nextEpisode.toError()));
    }
  }

  Future<void> _onFetchSeriesMetadata(
    FetchSeriesMetadata event,
    Emitter<SeriesDetailsState> emit,
  ) async {
    emit(state.copyWith(series: state.series.toLoading()));
    try {
      final series = await _libraryRepository.getItem(event.seriesId);
      emit(state.copyWith(series: state.series.toSuccess(series)));
    } catch (e, stackTrace) {
      LoggerService.media.severe(
        'Failed to fetch series metadata',
        e,
        stackTrace,
      );
      emit(state.copyWith(series: state.series.toError()));
    }
  }

  void _onCollapseSeason(
    CollapseSeason event,
    Emitter<SeriesDetailsState> emit,
  ) {
    emit(state.copyWith(clearExpandedSeasonId: true));
  }

  Future<void> _onFetchItemDetails(
    FetchItemDetails event,
    Emitter<SeriesDetailsState> emit,
  ) async {
    emit(state.copyWith(series: state.series.toLoading()));
    try {
      final item = await _libraryRepository.getItem(event.itemId);
      emit(state.copyWith(series: state.series.toSuccess(item)));
    } catch (e, stackTrace) {
      LoggerService.media.severe('Failed to fetch item details', e, stackTrace);
      emit(state.copyWith(series: state.series.toError()));
    }
  }

  Future<void> _onFetchSelectedEpisodeDetails(
    FetchSelectedEpisodeDetails event,
    Emitter<SeriesDetailsState> emit,
  ) async {
    try {
      final item = await _libraryRepository.getItem(event.episodeId);
      emit(state.copyWith(selectedEpisode: () => item));
    } catch (e, stackTrace) {
      LoggerService.media.severe(
        'Failed to fetch selected episode details',
        e,
        stackTrace,
      );
    }
  }

  Future<void> _onTogglePlayedStatus(
    TogglePlayedStatus event,
    Emitter<SeriesDetailsState> emit,
  ) async {
    final currentItem = state.series.value;
    if (currentItem == null) return;

    final newPlayedStatus = !currentItem.isPlayed;

    final updatedItem = currentItem.copyWith(isPlayed: newPlayedStatus);
    emit(state.copyWith(series: state.series.toSuccess(updatedItem)));

    try {
      await _playbackRepository.togglePlayedStatus(
        currentItem.id,
        newPlayedStatus,
      );
    } catch (e, stackTrace) {
      LoggerService.media.severe(
        'Failed to toggle played status',
        e,
        stackTrace,
      );
      emit(state.copyWith(series: state.series.toSuccess(currentItem)));
    }
  }

  void _onSelectEpisode(SelectEpisode event, Emitter<SeriesDetailsState> emit) {
    emit(state.copyWith(selectedEpisode: () => event.episode));
  }

  void _onUpdateLocalPlaybackProgress(
    UpdateLocalPlaybackProgress event,
    Emitter<SeriesDetailsState> emit,
  ) {
    // 1. Update main series/movie item
    if (state.series.value?.id == event.itemId) {
      final updated = state.series.value!.copyWith(
        playbackPositionTicks: event.positionTicks,
      );
      emit(state.copyWith(series: state.series.toSuccess(updated)));
    }

    // 2. Update next up episode
    if (state.nextEpisode.value?.id == event.itemId) {
      final updated = state.nextEpisode.value!.copyWith(
        playbackPositionTicks: event.positionTicks,
      );
      emit(state.copyWith(nextEpisode: state.nextEpisode.toSuccess(updated)));
    }

    // 3. Update selected episode
    if (state.selectedEpisode?.id == event.itemId) {
      final updated = state.selectedEpisode!.copyWith(
        playbackPositionTicks: event.positionTicks,
      );
      emit(state.copyWith(selectedEpisode: () => updated));
    }
  }
}
