import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/media/repos/library_repository.dart';
import 'package:playcado/paginated_media_list/bloc/paginated_media_list_bloc.dart';
import 'package:playcado/paginated_media_list/ui/widgets/paginated_media_grid.dart';
import 'package:playcado/services/logger_service.dart';

class TvShowsScreen extends StatelessWidget {
  const TvShowsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    LoggerService.home.info('Building TvShowsScreen');
    final repo = context.read<LibraryRepository>();

    return BlocProvider<PaginatedMediaListBloc>(
      create: (context) => PaginatedMediaListBloc(
        fetcher:
            ({
              required int startIndex,
              required int limit,
              required String sortBy,
              required String sortOrder,
            }) => repo.getTvShows(
              startIndex: startIndex,
              limit: limit,
              sortBy: sortBy,
              sortOrder: sortOrder,
            ),
      )..add(FetchItems()),
      child: const Scaffold(body: TvShowsGrid()),
    );
  }
}

class TvShowsGrid extends StatelessWidget {
  const TvShowsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaginatedMediaListBloc, PaginatedMediaListState>(
      builder: (context, state) {
        return PaginatedMediaGrid(
          title: 'TV Shows',
          items: state.items.value,
          isLoading: state.items.isLoading,
          isError: state.items.isError,
          hasReachedMax: state.hasReachedMax,
          sortBy: state.sortBy,
          sortOrder: state.sortOrder,
          dateSortLabel: 'Premiere Date',
          onLoadMore: () {
            context.read<PaginatedMediaListBloc>().add(LoadMoreItems());
          },
          onRefresh: () async {
            context.read<PaginatedMediaListBloc>().add(FetchItems());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          onRetry: () {
            context.read<PaginatedMediaListBloc>().add(FetchItems());
          },
          onSortChanged: (sortBy, sortOrder) {
            context.read<PaginatedMediaListBloc>().add(
              ChangeSort(sortBy: sortBy, sortOrder: sortOrder),
            );
          },
        );
      },
    );
  }
}
