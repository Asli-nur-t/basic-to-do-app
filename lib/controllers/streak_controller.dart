import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StreakController extends GetxController {
  final _settingsBox = Hive.box('settings');
  final currentStreak = 0.obs;
  final longestStreak = 0.obs;
  final lastActivityDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadStreakData();
  }

  void _loadStreakData() {
    currentStreak.value = _settingsBox.get('currentStreak', defaultValue: 0);
    longestStreak.value = _settingsBox.get('longestStreak', defaultValue: 0);
    final lastDate = _settingsBox.get('lastActivityDate');
    if (lastDate != null) {
      lastActivityDate.value = DateTime.parse(lastDate);
    }
  }

  void recordActivity() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastActivityDate.value == null) {
      // İlk aktivite
      currentStreak.value = 1;
    } else {
      final lastDate = DateTime(
        lastActivityDate.value!.year,
        lastActivityDate.value!.month,
        lastActivityDate.value!.day,
      );

      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        // Ardışık gün
        currentStreak.value++;
      } else if (difference == 0) {
        // Aynı gün, streak'i koruyalım
        return;
      } else {
        // Streak kırıldı
        currentStreak.value = 1;
      }
    }

    // En uzun streak'i güncelle
    if (currentStreak.value > longestStreak.value) {
      longestStreak.value = currentStreak.value;
      _settingsBox.put('longestStreak', longestStreak.value);
    }

    // Verileri kaydet
    lastActivityDate.value = today;
    _settingsBox.put('currentStreak', currentStreak.value);
    _settingsBox.put('lastActivityDate', today.toIso8601String());
  }

  // Günlük kontrol - gece yarısında çağrılabilir
  void checkStreak() {
    if (lastActivityDate.value == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastActivityDate.value!.year,
      lastActivityDate.value!.month,
      lastActivityDate.value!.day,
    );

    final difference = today.difference(lastDate).inDays;
    if (difference > 1) {
      // Bir günden fazla aktivite olmamış, streak'i sıfırla
      currentStreak.value = 0;
      _settingsBox.put('currentStreak', 0);
    }
  }
}
