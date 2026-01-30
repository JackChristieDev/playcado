import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:playcado/services/logger_service.dart';

/// A wrapper around [CachedNetworkImage] that includes centralized logging
/// for image loading failures and consistent error handling.
class PlaycadoNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final PlaceholderWidgetBuilder? placeholder;
  final LoadingErrorWidgetBuilder? errorWidget;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final FilterQuality filterQuality;

  const PlaycadoNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
    this.filterQuality = FilterQuality.low,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: placeholder,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      filterQuality: filterQuality,
      errorListener: (error) {
        LoggerService.ui.severe('Failed to load image: $imageUrl', error);
      },
      errorWidget:
          errorWidget ??
          (context, url, error) => Center(
            child: Icon(Icons.broken_image, color: theme.colorScheme.error),
          ),
    );
  }
}
