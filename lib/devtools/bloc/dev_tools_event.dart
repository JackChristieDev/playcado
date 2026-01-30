part of 'dev_tools_bloc.dart';

abstract class DevToolsEvent extends Equatable {
  const DevToolsEvent();

  @override
  List<Object?> get props => [];
}

class DevToolsCastSessionUpdated extends DevToolsEvent {
  final bool isConnected;
  const DevToolsCastSessionUpdated(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}

class DevToolsCastTestVideoRequested extends DevToolsEvent {}

class DevToolsClearPreferencesServiceRequested extends DevToolsEvent {}

class DevToolsClearDownloadsDataRequested extends DevToolsEvent {}

class DevToolsClearSecureStorageRequested extends DevToolsEvent {}

class DevToolsDisconnectCastRequested extends DevToolsEvent {}

class DevToolsInitialized extends DevToolsEvent {}
