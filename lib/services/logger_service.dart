import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class LoggerService {
  static final Logger _preferencesServiceLogger = Logger('AppPrefs');
  static final Logger _authRepositoryLogger = Logger('AuthRepo');
  static final Logger _castServiceLogger = Logger('CastService');
  static final Logger _mediaBlocLogger = Logger('MediaBloc');
  static final Logger _mediaRepositoryLogger = Logger('MediaRepo');
  static final Logger _homeScreenLogger = Logger('HomeScreen');
  static final Logger _downloadsLogger = Logger('Downloads');
  static final Logger _playerLogger = Logger('Player');
  static final Logger _systemLogger = Logger('System');
  static final Logger _blocLogger = Logger('Bloc');
  static final Logger _secureStorageLogger = Logger('SecureStore');
  static final Logger _uiLogger = Logger('UI');

  static void initializeLogging() {
    // Enable hierarchical logging to allow distinct control if needed,
    // but primarily to reset the root logger cleanly.
    hierarchicalLoggingEnabled = true;
    Logger.root.level = Level.INFO;

    // Remove any existing listeners (fixes duplicate logs on hot restart)
    Logger.root.clearListeners();

    Logger.root.onRecord.listen((record) {
      // Format: 10:53:03.566
      final time = record.time.toIso8601String().split('T').last;
      final timestamp = time.substring(0, 12);

      final level = record.level.name.padRight(7);
      final name = record.loggerName.padRight(12);

      // Don't print the 'flutter:' prefix here, debugPrint handles the system output
      // We format strictly: TIME LEVEL [TAG] MESSAGE
      final message = '$timestamp $level $name ${record.message}';

      if (record.error != null) {
        debugPrint('$message\nError: ${record.error}');
        if (record.stackTrace != null) {
          debugPrint('Stack: ${record.stackTrace}');
        }
      } else {
        debugPrint(message);
      }
    });
  }

  static Logger get preferencesService => _preferencesServiceLogger;
  static Logger get auth => _authRepositoryLogger;
  static Logger get castService => _castServiceLogger;
  static Logger get media => _mediaBlocLogger;
  static Logger get api => _mediaRepositoryLogger;
  static Logger get home => _homeScreenLogger;
  static Logger get downloads => _downloadsLogger;
  static Logger get player => _playerLogger;
  static Logger get system => _systemLogger;
  static Logger get bloc => _blocLogger;
  static Logger get secureStorage => _secureStorageLogger;
  static Logger get ui => _uiLogger;
}
