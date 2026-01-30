import 'package:equatable/equatable.dart';
import 'package:playcado/media/models/media_item.dart';

class CastItem extends Equatable {
  final MediaItem mediaItem;
  final String streamUrl;
  final String imageUrl;
  final String? mimeType;

  String get correctMimeType {
    if (mimeType != null) return mimeType!;
    final path = streamUrl.toLowerCase();
    if (path.endsWith('.m3u8')) return 'application/x-mpegURL';
    if (path.endsWith('.mp4')) return 'video/mp4';
    if (path.endsWith('.mp3')) return 'audio/mpeg';
    return 'video/mp4';
  }

  const CastItem({
    required this.mediaItem,
    required this.streamUrl,
    required this.imageUrl,
    this.mimeType,
  });

  @override
  List<Object?> get props => [mediaItem, streamUrl, imageUrl, mimeType];
}
