import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PomodoroSettingsController extends GetxController {
  final _settingsBox = Hive.box('settings');
  final workDuration = 25.obs;
  final shortBreakDuration = 5.obs;
  final longBreakDuration = 15.obs;

  @override
  void onInit() {
    super.onInit();
    // Kaydedilmiş değerleri yükle
    workDuration.value = _settingsBox.get('workDuration', defaultValue: 25);
    shortBreakDuration.value =
        _settingsBox.get('shortBreakDuration', defaultValue: 5);
    longBreakDuration.value =
        _settingsBox.get('longBreakDuration', defaultValue: 15);
  }

  void updateSettings({int? work, int? shortBreak, int? longBreak}) {
    if (work != null) {
      workDuration.value = work;
      _settingsBox.put('workDuration', work);
    }
    if (shortBreak != null) {
      shortBreakDuration.value = shortBreak;
      _settingsBox.put('shortBreakDuration', shortBreak);
    }
    if (longBreak != null) {
      longBreakDuration.value = longBreak;
      _settingsBox.put('longBreakDuration', longBreak);
    }
  }
}
