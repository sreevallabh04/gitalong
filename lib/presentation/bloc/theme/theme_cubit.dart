import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system) {
    _load();
  }

  static const _key = AppConstants.themeKey;

  Future<void> _load() async {
    final box = await Hive.openBox(AppConstants.settingsBox);
    final stored = box.get(_key, defaultValue: 'system') as String;
    emit(_fromString(stored));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    final box = await Hive.openBox(AppConstants.settingsBox);
    await box.put(_key, _toString(mode));
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  static ThemeMode _fromString(String value) => switch (value) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };

  static String _toString(ThemeMode mode) => switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
      };
}
