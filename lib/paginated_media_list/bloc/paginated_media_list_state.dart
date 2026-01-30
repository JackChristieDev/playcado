part of 'paginated_media_list_bloc.dart';

class PaginatedMediaListState extends Equatable {
  final StatusWrapper<List<MediaItem>> items;
  final bool hasReachedMax;
  final String sortBy;
  final String sortOrder;

  const PaginatedMediaListState({
    this.items = const StatusWrapper(),
    this.hasReachedMax = false,
    this.sortBy = 'SortName',
    this.sortOrder = 'Ascending',
  });

  PaginatedMediaListState copyWith({
    StatusWrapper<List<MediaItem>>? items,
    bool? hasReachedMax,
    String? sortBy,
    String? sortOrder,
  }) {
    return PaginatedMediaListState(
      items: items ?? this.items,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [items, hasReachedMax, sortBy, sortOrder];
}
