part of 'theme_bloc.dart';

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

final class SetInitialTheme extends ThemeEvent {}

final class SetLightTheme extends ThemeEvent {}

final class SetDarkTheme extends ThemeEvent {}

final class ToggleTheme extends ThemeEvent {}
