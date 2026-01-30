abstract class MediaUrlService {
  String getImageUrl(String itemId);
  String getBackdropUrl(String itemId);
  String getStreamUrl(String itemId);
  String getDownloadUrl(String itemId, {int? maxHeight});
  String generateTranscodeUrl({
    required String itemId,
    required String mediaSourceId,
  });
}
