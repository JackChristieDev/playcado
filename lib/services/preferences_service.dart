import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:path_provider/path_provider.dart';
import 'package:playcado/services/logger_service.dart';

class PreferencesService {
  static const String _firstRunFileName = '.onboarding_completed';
  static const String _settingsFileName = 'app_settings.json';

  static const String _themeColorKey = 'themeColor';

  Future<File> get _firstRunFile async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_firstRunFileName');
  }

  Future<File> get _settingsFile async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_settingsFileName');
  }

  Future<bool> isFirstRun() async {
    try {
      final file = await _firstRunFile;
      // If the file does NOT exist, it IS the first run.
      return !await file.exists();
    } catch (e, s) {
      LoggerService.preferencesService.warning(
        'Failed to check first run status',
        e,
        s,
      );
      return true; // Default to showing onboarding if check fails
    }
  }

  Future<void> setFirstRunCompleted() async {
    LoggerService.preferencesService.info('Setting first run as completed');
    try {
      final file = await _firstRunFile;
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
    } catch (e, s) {
      LoggerService.preferencesService.severe(
        'Failed to set first run status',
        e,
        s,
      );
    }
  }

  Future<void> saveThemeColor(Color color) async {
    try {
      final file = await _settingsFile;
      Map<String, dynamic> settings = {};

      if (await file.exists()) {
        try {
          final content = await file.readAsString();
          settings = jsonDecode(content) as Map<String, dynamic>;
        } catch (_) {
          // Ignore parse errors, just overwrite
        }
      }

      settings[_themeColorKey] = color.toARGB32();
      await file.writeAsString(jsonEncode(settings));
    } catch (e, s) {
      LoggerService.preferencesService.severe(
        'Failed to save theme color',
        e,
        s,
      );
    }
  }

  Future<Color?> getThemeColor() async {
    try {
      final file = await _settingsFile;

      if (await file.exists()) {
        final content = await file.readAsString();
        final Map<String, dynamic> settings = jsonDecode(content);
        if (settings.containsKey(_themeColorKey)) {
          return Color(settings[_themeColorKey] as int);
        }
      }
    } catch (e, s) {
      LoggerService.preferencesService.warning(
        'Failed to load theme color',
        e,
        s,
      );
    }
    return null;
  }

  Future<void> resetAll() async {
    try {
      final firstRunFile = await _firstRunFile;
      if (await firstRunFile.exists()) {
        await firstRunFile.delete();
      }
      final settingsFile = await _settingsFile;
      if (await settingsFile.exists()) {
        await settingsFile.delete();
      }
    } catch (e, s) {
      LoggerService.preferencesService.warning(
        'Failed to reset app preferences',
        e,
        s,
      );
    }
  }
}
