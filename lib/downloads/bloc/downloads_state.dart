part of 'downloads_bloc.dart';

class DownloadsState extends Equatable {
  final List<DownloadItem> downloads;
  final bool isLoading;

  const DownloadsState({
    this.downloads = const [],
    this.isLoading = true,
  });

  List<DownloadItem> get activeDownloads =>
      downloads.where((i) => i.status != DownloadStatus.completed).toList();

  List<DownloadItem> get completedDownloads =>
      downloads.where((i) => i.status == DownloadStatus.completed).toList();

  DownloadsState copyWith({
    List<DownloadItem>? downloads,
    bool? isLoading,
  }) {
    return DownloadsState(
      downloads: downloads ?? this.downloads,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [downloads, isLoading];
}
