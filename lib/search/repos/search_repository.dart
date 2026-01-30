import 'package:jellyfin_dart/jellyfin_dart.dart';
import 'package:playcado/media/data/media_remote_data_source.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/services/logger_service.dart';

class SearchRepository {
  final MediaRemoteDataSource _dataSource;

  SearchRepository({required MediaRemoteDataSource dataSource})
    : _dataSource = dataSource;

  Future<List<MediaItem>> searchMedia(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      LoggerService.api.info('Searching media with query: $query');
      final currentUserId = await _dataSource.getCurrentUserId();
      if (currentUserId == null) throw Exception('Unable to get current user');

      final results = await Future.wait([
        _dataSource.fetchItems(
          userId: currentUserId,
          searchTerm: query,
          limit: 50,
          recursive: true,
          includeItemTypes: [BaseItemKind.movie, BaseItemKind.series],
          fields: [ItemFields.overview, ItemFields.mediaSources],
        ),
        _dataSource.fetchItems(
          userId: currentUserId,
          searchTerm: query,
          limit: 50,
          recursive: true,
          includeItemTypes: [BaseItemKind.episode],
          fields: [ItemFields.overview, ItemFields.mediaSources],
        ),
      ]);

      final items = [...results[0], ...results[1]];

      // Sort items by Type: Movie -> Series -> Episode
      items.sort((a, b) {
        int priority(MediaItemType? type) {
          switch (type) {
            case MediaItemType.movie:
              return 0;
            case MediaItemType.series:
              return 1;
            case MediaItemType.episode:
              return 2;
            default:
              return 3;
          }
        }

        return priority(a.type).compareTo(priority(b.type));
      });

      return items;
    } catch (e, s) {
      LoggerService.api.severe('Error searching media', e, s);
      rethrow;
    }
  }
}
