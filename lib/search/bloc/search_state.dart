part of 'search_bloc.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<MediaItem> items;
  final String query;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.initial,
    this.items = const [],
    this.query = '',
    this.errorMessage,
  });

  SearchState copyWith({
    SearchStatus? status,
    List<MediaItem>? items,
    String? query,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      items: items ?? this.items,
      query: query ?? this.query,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, query, errorMessage];
}
