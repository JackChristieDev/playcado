import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/core/status_wrapper.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/media/repos/library_repository.dart';
import 'package:playcado/services/logger_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final LibraryRepository _libraryRepository;

  HomeBloc({required LibraryRepository libraryRepository})
    : _libraryRepository = libraryRepository,
      super(const HomeState()) {
    on<LoadHomeContent>(_onLoadHomeContent);
  }

  Future<void> _onLoadHomeContent(
    LoadHomeContent event,
    Emitter<HomeState> emit,
  ) async {
    // Set all to loading
    emit(
      state.copyWith(
        continueWatching: state.continueWatching.toLoading(),
        nextUp: state.nextUp.toLoading(),
        latestMovies: state.latestMovies.toLoading(),
        latestTv: state.latestTv.toLoading(),
      ),
    );

    try {
      // Execute requests in parallel for better performance
      final results = await Future.wait([
        _libraryRepository.getResumeItems(),
        _libraryRepository.getNextUpItems(),
        _libraryRepository.getLatestMovies(),
        _libraryRepository.getLatestTvShows(),
      ]);

      emit(
        state.copyWith(
          continueWatching: state.continueWatching.toSuccess(results[0]),
          nextUp: state.nextUp.toSuccess(results[1]),
          latestMovies: state.latestMovies.toSuccess(results[2]),
          latestTv: state.latestTv.toSuccess(results[3]),
        ),
      );
    } catch (e, stack) {
      LoggerService.home.severe('Failed to load home content', e, stack);
      // Mark all as error to prompt retry
      emit(
        state.copyWith(
          continueWatching: state.continueWatching.toError(),
          nextUp: state.nextUp.toError(),
          latestMovies: state.latestMovies.toError(),
          latestTv: state.latestTv.toError(),
        ),
      );
    }
  }
}
