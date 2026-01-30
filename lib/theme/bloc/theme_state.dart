part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  final Color themeColor;

  const ThemeState({this.themeColor = AppTheme.avocadoGreen});

  ThemeState copyWith({Color? themeColor}) {
    return ThemeState(themeColor: themeColor ?? this.themeColor);
  }

  @override
  List<Object> get props => [themeColor];
}
