part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthLoadAccountsRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String server;
  final String username;
  final String password;
  final bool rememberCredentials;

  AuthLoginRequested(
    this.server,
    this.username,
    this.password, {
    this.rememberCredentials = true,
  });

  @override
  List<Object> get props => [server, username, password, rememberCredentials];
}

class AuthLogoutRequested extends AuthEvent {
  AuthLogoutRequested();
}

class AuthRemoveAccountRequested extends AuthEvent {
  final String id;
  AuthRemoveAccountRequested(this.id);

  @override
  List<Object> get props => [id];
}

class AuthSwitchAccountRequested extends AuthEvent {
  final ServerCredentials credentials;
  AuthSwitchAccountRequested(this.credentials);

  @override
  List<Object> get props => [credentials];
}

class AuthEnterOfflineModeRequested extends AuthEvent {}

class AuthDemoModeRequested extends AuthEvent {}
