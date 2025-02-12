import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class FontController extends GetxController {
  final _settingsBox = Hive.box('settings');
  final _currentFontIndex = 0.obs;

  static const fontOptions = [
    'BubblegumSans',
    'ComicNeue',
    'Comfortaa',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadFont();
  }

  void _loadFont() {
    _currentFontIndex.value = _settingsBox.get('fontIndex', defaultValue: 0);
  }

  TextStyle getFontStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    switch (_currentFontIndex.value) {
      case 0:
        return GoogleFonts.bubblegumSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case 1:
        return GoogleFonts.comicNeue(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case 2:
        return GoogleFonts.comfortaa(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      default:
        return GoogleFonts.bubblegumSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
    }
  }

  void setFont(int index) {
    if (index >= 0 && index < fontOptions.length) {
      _currentFontIndex.value = index;
      _settingsBox.put('fontIndex', index);
      Get.forceAppUpdate();
      update();
    }
  }

  String get currentFontName => fontOptions[_currentFontIndex.value];
}
