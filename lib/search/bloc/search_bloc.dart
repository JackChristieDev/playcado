import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/search/repos/search_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _searchRepository;

  SearchBloc({required SearchRepository searchRepository})
    : _searchRepository = searchRepository,
      super(const SearchState()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchClearRequested>(_onClearRequested);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query;

    if (query.isEmpty) {
      emit(
        state.copyWith(query: query, status: SearchStatus.initial, items: []),
      );
      return;
    }

    emit(state.copyWith(query: query, status: SearchStatus.loading));

    try {
      final items = await _searchRepository.searchMedia(query);
      emit(state.copyWith(status: SearchStatus.success, items: items));
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchStatus.failure,
          errorMessage: 'Failed to search media',
        ),
      );
    }
  }

  void _onClearRequested(
    SearchClearRequested event,
    Emitter<SearchState> emit,
  ) {
    emit(const SearchState());
  }
}
