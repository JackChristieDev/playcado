part of 'dev_tools_bloc.dart';

enum DevToolsStatus { initial, loading, success, error }

class DevToolsState extends Equatable {
  final bool isCastConnected;
  final String? message;
  final DevToolsStatus status;

  const DevToolsState({
    this.isCastConnected = false,
    this.message,
    this.status = DevToolsStatus.initial,
  });

  DevToolsState copyWith({
    bool? isCastConnected,
    String? message,
    DevToolsStatus? status,
  }) {
    return DevToolsState(
      isCastConnected: isCastConnected ?? this.isCastConnected,
      message: message,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [isCastConnected, message, status];
}
