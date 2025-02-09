import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeController extends GetxController {
  final _settingsBox = Hive.box('settings');
  final _isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  void _loadThemeMode() {
    _isDarkMode.value = _settingsBox.get('isDarkMode', defaultValue: false);
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    _settingsBox.put('isDarkMode', _isDarkMode.value);
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  bool get isDarkMode => _isDarkMode.value;
  ThemeMode get themeMode =>
      _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  IconData get themeIcon =>
      _isDarkMode.value ? Icons.light_mode : Icons.dark_mode;
  String get themeText => _isDarkMode.value ? 'Aydınlık Mod' : 'Karanlık Mod';
}
