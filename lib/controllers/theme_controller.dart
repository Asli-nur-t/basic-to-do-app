import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeController extends GetxController {
  final _box = Hive.box('settings');
  var _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _box.put('isDarkMode', _themeMode == ThemeMode.dark);
    update();
  }

  void _loadTheme() {
    final isDarkMode = _box.get('isDarkMode', defaultValue: false);
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    update();
  }
}
