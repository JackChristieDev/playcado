import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playcado/app_router/app_router.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/services/media_url/media_url_service.dart';
import 'package:playcado/widgets/widgets.dart';

/// A widget that displays a media poster with a hero transition.
class MediaPoster extends StatelessWidget {
  final MediaItem item;
  final String? heroTag;
  final bool isLandscape;
  final int? customCacheWidth;

  const MediaPoster({
    super.key,
    required this.item,
    this.heroTag,
    this.isLandscape = false,
    this.customCacheWidth,
  });

  @override
  Widget build(BuildContext context) {
    final urlGenerator = context.read<MediaUrlService>();
    final theme = Theme.of(context);
    final effectiveTag = heroTag ?? item.heroTag();

    final title = item.type == MediaItemType.episode
        ? (item.seriesName ?? item.name)
        : item.name;

    final subtitle = item.displaySubtitle;

    final String imgUrl;
    if (isLandscape) {
      imgUrl = (item.type == MediaItemType.episode)
          ? urlGenerator.getImageUrl(item.id)
          : urlGenerator.getBackdropUrl(item.id);
    } else {
      final posterId =
          (item.type == MediaItemType.episode && item.seriesId != null)
          ? item.seriesId!
          : item.id;
      imgUrl = urlGenerator.getImageUrl(posterId);
    }

    return GestureDetector(
      onTap: () {
        context.push(
          AppRouter.detailsPath,
          extra: {'item': item, 'heroTag': effectiveTag},
        );
      },
      child: RepaintBoundary(
        child: Hero(
          tag: effectiveTag,
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: PlaycadoNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      filterQuality: FilterQuality.low,
                      memCacheWidth:
                          customCacheWidth ?? (isLandscape ? 800 : 400),
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            isLandscape
                                ? Icons.image_outlined
                                : Icons.movie_outlined,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(
                          Icons.broken_image,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
