part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ChangeThemeColor extends ThemeEvent {
  final Color color;

  const ChangeThemeColor(this.color);

  @override
  List<Object> get props => [color];
}
