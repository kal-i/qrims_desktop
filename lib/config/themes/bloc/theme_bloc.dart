import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_theme.dart';

part 'theme_event.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeData> {
  ThemeBloc() : super(AppTheme.light) {
    on<SetInitialTheme>(_onSetInitialTheme);
    on<SetLightTheme>(_onSetLightTheme);
    on<SetDarkTheme>(_onSetDarkTheme);
    on<ToggleTheme>(_onToggleTheme);
  }

  void _onSetInitialTheme(SetInitialTheme event, Emitter<ThemeData> emit) async {
    bool hasDarkTheme = await isDark();
    emit(hasDarkTheme ? AppTheme.dark : AppTheme.light);
  }

  void _onSetLightTheme(SetLightTheme event, Emitter<ThemeData> emit) async {
    emit(AppTheme.light);
    setTheme(false);
  }

  void _onSetDarkTheme(SetDarkTheme event, Emitter<ThemeData> emit) async {
    emit(AppTheme.dark);
    setTheme(true);
  }

  void _onToggleTheme(ToggleTheme event, Emitter<ThemeData> emit) async {
    bool isDark = state == AppTheme.dark;
    emit(state == AppTheme.light ? AppTheme.dark : AppTheme.light);
    setTheme(!isDark);
  }
}

Future<bool> isDark() async {
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getBool('is_dark') ?? false;
}

Future<void> setTheme(bool isDark) async {
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setBool('is_dark', isDark);
}