import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PomodoroSettingsController extends GetxController {
  final _settingsBox = Hive.box('settings');
  final workDuration = 25.obs;
  final shortBreakDuration = 5.obs;
  final longBreakDuration = 15.obs;
  final autoStartBreaks = false.obs;
  final autoStartPomodoros = false.obs;
  final soundEnabled = true.obs;
  final dailyPomodoroTarget = 8.obs;
  final weeklyPomodoroTarget = 40.obs;

  // Pomodoro istatistikleri
  final dailyCompletedPomodoros = 0.obs;
  final weeklyCompletedPomodoros = 0.obs;
  final lastPomodoroDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _loadStatistics();
    // Her gün gece yarısı istatistikleri sıfırla
    _setupDailyReset();
  }

  void _setupDailyReset() {
    // Günlük istatistikleri sıfırlama mantığı
  }

  void updateStatistics() {
    final now = DateTime.now();
    lastPomodoroDate.value = now;
    _settingsBox.put('lastPomodoroDate', now.toIso8601String());

    dailyCompletedPomodoros.value++;
    weeklyCompletedPomodoros.value++;

    _settingsBox.put('dailyCompletedPomodoros', dailyCompletedPomodoros.value);
    _settingsBox.put(
        'weeklyCompletedPomodoros', weeklyCompletedPomodoros.value);
  }

  void _loadSettings() {
    // Kaydedilmiş değerleri yükle
    workDuration.value = _settingsBox.get('workDuration', defaultValue: 25);
    shortBreakDuration.value =
        _settingsBox.get('shortBreakDuration', defaultValue: 5);
    longBreakDuration.value =
        _settingsBox.get('longBreakDuration', defaultValue: 15);
    autoStartBreaks.value =
        _settingsBox.get('autoStartBreaks', defaultValue: false);
    autoStartPomodoros.value =
        _settingsBox.get('autoStartPomodoros', defaultValue: false);
    soundEnabled.value = _settingsBox.get('soundEnabled', defaultValue: true);
    dailyPomodoroTarget.value =
        _settingsBox.get('dailyPomodoroTarget', defaultValue: 8);
    weeklyPomodoroTarget.value =
        _settingsBox.get('weeklyPomodoroTarget', defaultValue: 40);
  }

  void updateSettings({
    int? work,
    int? shortBreak,
    int? longBreak,
    bool? autoStart,
    bool? autoStartBreak,
    bool? sound,
    int? dailyTarget,
    int? weeklyTarget,
  }) {
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
    if (autoStart != null) {
      autoStartPomodoros.value = autoStart;
      _settingsBox.put('autoStartPomodoros', autoStart);
    }
    if (autoStartBreak != null) {
      autoStartBreaks.value = autoStartBreak;
      _settingsBox.put('autoStartBreaks', autoStartBreak);
    }
    if (sound != null) {
      soundEnabled.value = sound;
      _settingsBox.put('soundEnabled', sound);
    }
    if (dailyTarget != null) {
      dailyPomodoroTarget.value = dailyTarget;
      _settingsBox.put('dailyPomodoroTarget', dailyTarget);
    }
    if (weeklyTarget != null) {
      weeklyPomodoroTarget.value = weeklyTarget;
      _settingsBox.put('weeklyPomodoroTarget', weeklyTarget);
    }
  }

  void _loadStatistics() {
    dailyCompletedPomodoros.value =
        _settingsBox.get('dailyCompletedPomodoros', defaultValue: 0);
    weeklyCompletedPomodoros.value =
        _settingsBox.get('weeklyCompletedPomodoros', defaultValue: 0);
    final lastDate = _settingsBox.get('lastPomodoroDate');
    lastPomodoroDate.value = lastDate != null ? DateTime.parse(lastDate) : null;
  }
}
