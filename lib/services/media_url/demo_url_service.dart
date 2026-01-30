import 'package:playcado/services/media_url/media_url_service.dart';

class DemoUrlService implements MediaUrlService {
  static const _imgBase = 'https://picsum.photos/seed';
  static const _videoUrl =
      'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

  @override
  String getImageUrl(String itemId) {
    // 600x900: Standard Portrait
    return '$_imgBase/$itemId/600/900';
  }

  @override
  String getBackdropUrl(String itemId) {
    // 1280x720: Standard Landscape (16:9)
    // Append 'backdrop' to seed to differentiate from poster
    return '$_imgBase/${itemId}backdrop/1280/720';
  }

  @override
  String getStreamUrl(String itemId) => _videoUrl;

  @override
  String getDownloadUrl(String itemId, {int? maxHeight}) => _videoUrl;

  @override
  String generateTranscodeUrl({
    required String itemId,
    required String mediaSourceId,
  }) => _videoUrl;
}
