part of 'downloads_bloc.dart';

abstract class DownloadsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DownloadsDeleteRequested extends DownloadsEvent {
  final String id;
  DownloadsDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class DownloadsInitialized extends DownloadsEvent {}

class DownloadsPauseRequested extends DownloadsEvent {
  final String id;
  DownloadsPauseRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class DownloadsResumeRequested extends DownloadsEvent {
  final String id;
  DownloadsResumeRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class DownloadsStartRequested extends DownloadsEvent {
  final DownloadItem item;
  DownloadsStartRequested(this.item);
  @override
  List<Object?> get props => [item];
}

class DownloadsRequested extends DownloadsEvent {
  final MediaItem item;

  DownloadsRequested({
    required this.item,
  });

  @override
  List<Object?> get props => [item];
}

class DownloadsUpdated extends DownloadsEvent {
  final List<DownloadItem> items;
  DownloadsUpdated(this.items);
  @override
  List<Object?> get props => [items];
}
