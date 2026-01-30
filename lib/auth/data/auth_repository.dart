import 'package:jellyfin_dart/jellyfin_dart.dart';
import 'package:playcado/auth/models/server_credentials.dart';
import 'package:playcado/services/jellyfin_client_service.dart';
import 'package:playcado/services/logger_service.dart';
import 'package:playcado/services/secure_storage_service.dart';

class AuthRepository {
  final JellyfinClientService _jellyfinClientService;
  final SecureStorageService _secureStorage;

  AuthRepository({
    required JellyfinClientService jellyfinClient,
    required SecureStorageService secureStorage,
  }) : _jellyfinClientService = jellyfinClient,
       _secureStorage = secureStorage;

  JellyfinDart? get client => _jellyfinClientService.client;
  ServerCredentials? get currentCredentials =>
      _jellyfinClientService.credentials;
  bool get isLoggedIn => _jellyfinClientService.hasSession;

  Future<List<ServerCredentials>> getSavedAccounts() async {
    return await _secureStorage.getSavedAccounts();
  }

  Future<bool> hasStoredCredentials() async {
    return await _secureStorage.hasCredentials();
  }

  Future<bool> login({
    required String serverUrl,
    required String username,
    required String password,
    bool rememberCredentials = false,
  }) async {
    LoggerService.auth.info(
      'Starting login for user: $username on server: $serverUrl',
    );
    try {
      serverUrl = serverUrl.trim();
      if (!serverUrl.startsWith('http://') &&
          !serverUrl.startsWith('https://')) {
        serverUrl = 'http://$serverUrl';
      }

      final newClient = JellyfinDart(basePathOverride: serverUrl);

      // Generate and capture the deviceId
      final deviceId = 'playcado-${DateTime.now().millisecondsSinceEpoch}';

      newClient.setMediaBrowserAuth(
        deviceId: deviceId,
        version: '1.0.0',
        client: 'playcado',
        device: 'Playcado App',
      );

      final userApi = newClient.getUserApi();
      final authRequest = AuthenticateUserByName(
        username: username,
        pw: password,
      );
      final response = await userApi.authenticateUserByName(
        authenticateUserByName: authRequest,
      );
      final authenticationResult = response.data;

      if (authenticationResult != null &&
          authenticationResult.user != null &&
          authenticationResult.accessToken != null) {
        LoggerService.auth.info('Authentication successful for $username');
        newClient.setToken(authenticationResult.accessToken!);

        final credentials = ServerCredentials(
          serverName: serverUrl,
          username: username,
          password: password,
        );

        _jellyfinClientService.setClient(
          newClient,
          credentials,
          authenticationResult.accessToken!,
          deviceId,
        );

        // Always save to the list of known accounts if login succeeds
        if (rememberCredentials) {
          LoggerService.auth.info('Saving credentials securely');
          await _secureStorage.storeCredentials(credentials); // Active
          await _secureStorage.saveAccount(credentials); // History list
        }
        return true;
      }
      LoggerService.auth.warning('Authentication returned null result/token');
      return false;
    } catch (e, stackTrace) {
      LoggerService.auth.severe('Login failed', e, stackTrace);
      _jellyfinClientService.clear();
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    LoggerService.auth.info('Logging out user');
    _jellyfinClientService.clear();
    await _secureStorage.clearCredentials();
  }

  Future<void> removeAccount(String id) async {
    LoggerService.auth.info('Removing saved account: $id');
    await _secureStorage.removeAccount(id);
  }

  Future<bool> tryAutoLogin() async {
    try {
      final storedCredentials = await _secureStorage.retrieveCredentials();
      if (storedCredentials != null) {
        LoggerService.auth.info(
          'Found stored credentials for ${storedCredentials.username}, attempting login',
        );
        return await login(
          serverUrl: storedCredentials.serverName,
          username: storedCredentials.username,
          password: storedCredentials.password,
          rememberCredentials: true,
        );
      }
      return false;
    } catch (e, s) {
      LoggerService.auth.warning('Auto-login failed or cancelled', e, s);
      return false;
    }
  }
}
