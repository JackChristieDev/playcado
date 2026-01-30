part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final List<ServerCredentials> availableAccounts;
  final StatusWrapper<User> user;
  final bool isOfflineMode;
  final bool isDemoMode;
  final ServerCredentials? credentials;

  const AuthState({
    this.availableAccounts = const [],
    this.user = const StatusWrapper(),
    this.isOfflineMode = false,
    this.isDemoMode = false,
    this.credentials,
  });

  /// Returns true if the user is successfully authenticated.
  bool get isLoggedIn => user.isSuccess;

  AuthState copyWith({
    List<ServerCredentials>? availableAccounts,
    StatusWrapper<User>? user,
    bool? isOfflineMode,
    bool? isDemoMode,
    ValueGetter<ServerCredentials?>? credentials,
  }) {
    return AuthState(
      availableAccounts: availableAccounts ?? this.availableAccounts,
      user: user ?? this.user,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      isDemoMode: isDemoMode ?? this.isDemoMode,
      credentials: credentials != null ? credentials() : this.credentials,
    );
  }

  @override
  List<Object?> get props => [
    availableAccounts,
    user,
    isOfflineMode,
    isDemoMode,
    credentials,
  ];
}
