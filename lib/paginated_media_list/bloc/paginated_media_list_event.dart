part of 'paginated_media_list_bloc.dart';

abstract class PaginatedMediaListEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchItems extends PaginatedMediaListEvent {}

class LoadMoreItems extends PaginatedMediaListEvent {}

class ChangeSort extends PaginatedMediaListEvent {
  final String sortBy;
  final String sortOrder;

  ChangeSort({required this.sortBy, required this.sortOrder});

  @override
  List<Object> get props => [sortBy, sortOrder];
}
