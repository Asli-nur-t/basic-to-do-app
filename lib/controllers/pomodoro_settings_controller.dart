import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';

class PomodoroSettingsController extends GetxController {
  final _settingsBox = Hive.box('settings');

  // Temel ayarlar
  final workDuration = 25.obs;
  final shortBreakDuration = 5.obs;
  final longBreakDuration = 15.obs;
  final autoStartBreaks = false.obs;
  final autoStartPomodoros = false.obs;
  final soundEnabled = true.obs;

  // Hedefler ve istatistikler
  final dailyPomodoroTarget = 8.obs;
  final weeklyPomodoroTarget = 40.obs;
  final dailyCompletedPomodoros = 0.obs;
  final weeklyCompletedPomodoros = 0.obs;
  final lastPomodoroDate = Rx<DateTime?>(null);

  // Timer değişkenleri
  final isRunning = false.obs;
  final isBreak = false.obs;
  final remainingSeconds = 0.obs;
  Timer? _timer;

  // Ses oynatıcı
  late final AudioPlayer _audioPlayer;

  // Getter'lar
  int get breakDuration =>
      isBreak.value ? shortBreakDuration.value : workDuration.value;
  double get progress => remainingSeconds.value / (workDuration.value * 60);

  @override
  void onInit() {
    super.onInit();
    _audioPlayer = AudioPlayer();
    _loadSettings();
    _loadStatistics();
    reset();
    _initAudio();
  }

  void start() {
    if (!isRunning.value) {
      isRunning.value = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingSeconds.value > 0) {
          remainingSeconds.value--;
        } else {
          _onPeriodComplete();
        }
      });
    }
  }

  void pause() {
    _timer?.cancel();
    isRunning.value = false;
  }

  void reset() {
    pause();
    isBreak.value = false;
    remainingSeconds.value = workDuration.value * 60;
  }

  void _onPeriodComplete() {
    pause();
    if (!isBreak.value) {
      // Çalışma periyodu bitti
      updateStatistics();
      isBreak.value = true;
      remainingSeconds.value = shortBreakDuration.value * 60;

      // Bildirim gönder
      _showNotification(
        'Pomodoro Tamamlandı!',
        'Tebrikler! Şimdi ${shortBreakDuration.value} dakikalık mola zamanı.',
      );

      // Ses çal
      _playSound();

      // Otomatik mola başlatma
      if (autoStartBreaks.value) {
        Future.delayed(const Duration(seconds: 1), () {
          start();
        });
      }
    } else {
      // Mola bitti
      isBreak.value = false;
      remainingSeconds.value = workDuration.value * 60;

      // Bildirim gönder
      _showNotification(
        'Mola Bitti!',
        'Yeni bir pomodoro başlatmaya hazır mısın?',
      );

      // Ses çal
      _playSound();

      // Otomatik çalışma başlatma
      if (autoStartPomodoros.value) {
        Future.delayed(const Duration(seconds: 1), () {
          start();
        });
      }
    }
    update();
  }

  void skip() {
    pause();
    if (isBreak.value) {
      isBreak.value = false;
      remainingSeconds.value = workDuration.value * 60;
    } else {
      isBreak.value = true;
      remainingSeconds.value = shortBreakDuration.value * 60;
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    super.onClose();
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
      if (!isBreak.value && !isRunning.value) {
        remainingSeconds.value = work * 60;
      }
      _settingsBox.put('workDuration', work);
    }
    if (shortBreak != null) {
      shortBreakDuration.value = shortBreak;
      if (isBreak.value && !isRunning.value) {
        remainingSeconds.value = shortBreak * 60;
      }
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
    update();
  }

  void _loadStatistics() {
    dailyCompletedPomodoros.value =
        _settingsBox.get('dailyCompletedPomodoros', defaultValue: 0);
    weeklyCompletedPomodoros.value =
        _settingsBox.get('weeklyCompletedPomodoros', defaultValue: 0);
    final lastDate = _settingsBox.get('lastPomodoroDate');
    lastPomodoroDate.value = lastDate != null ? DateTime.parse(lastDate) : null;
  }

  // Bildirim gösterme metodu
  void _showNotification(String title, String body) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Bildirimleri',
      channelDescription: 'Pomodoro zamanlayıcı bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Ses dosyalarını yükle
  void _initAudio() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/notification.wav');
    } catch (e) {
      debugPrint('Ses dosyası yüklenirken hata: $e');
    }
  }

  // Ses çalma metodu
  void _playSound() async {
    if (soundEnabled.value) {
      try {
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.play();
      } catch (e) {
        debugPrint('Ses çalma hatası: $e');
      }
    }
  }
}
