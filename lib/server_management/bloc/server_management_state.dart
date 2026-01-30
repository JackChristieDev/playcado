part of 'server_management_bloc.dart';

class ServerManagementState extends Equatable {
  final String serverUrl;
  final String username;
  final String password;
  final bool isLoading;

  const ServerManagementState({
    this.serverUrl = '',
    this.username = '',
    this.password = '',
    this.isLoading = false,
  });

  ServerManagementState copyWith({
    String? serverUrl,
    String? username,
    String? password,
    bool? isLoading,
  }) {
    return ServerManagementState(
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [serverUrl, username, password, isLoading];
}
