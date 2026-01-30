import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/services/preferences_service.dart';
import 'package:playcado/theme/app_theme.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final PreferencesService _preferencesService;

  ThemeBloc({
    required PreferencesService preferencesService,
    Color? initialColor,
  }) : _preferencesService = preferencesService,
       super(ThemeState(themeColor: initialColor ?? AppTheme.avocadoGreen)) {
    on<ChangeThemeColor>(_onChangeThemeColor);
  }

  Future<void> _onChangeThemeColor(
    ChangeThemeColor event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(themeColor: event.color));
    await _preferencesService.saveThemeColor(event.color);
  }
}
