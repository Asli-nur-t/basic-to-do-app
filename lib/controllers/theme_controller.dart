import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeController extends GetxController {
  final _settingsBox = Hive.box('settings');
  final _isDarkMode = false.obs;
  final _themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final savedThemeMode =
        _settingsBox.get('themeMode', defaultValue: ThemeMode.system.index);
    _themeMode.value = ThemeMode.values[savedThemeMode];
    _isDarkMode.value = _themeMode.value == ThemeMode.dark;
    Get.changeThemeMode(_themeMode.value);
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    _themeMode.value = _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
    _settingsBox.put('isDarkMode', _isDarkMode.value);
    _settingsBox.put('themeMode', _themeMode.value.index);
    Get.changeThemeMode(_themeMode.value);
  }

  bool get isDarkMode => _isDarkMode.value;
  ThemeMode get themeMode => _themeMode.value;

  IconData get themeIcon =>
      _isDarkMode.value ? Icons.light_mode : Icons.dark_mode;
  String get themeText => _isDarkMode.value ? 'Aydınlık Mod' : 'Karanlık Mod';

  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    _isDarkMode.value = mode == ThemeMode.dark;
    Get.changeThemeMode(mode);
    _settingsBox.put('themeMode', mode.index);
    _settingsBox.put('isDarkMode', _isDarkMode.value);
    update();
  }
}
