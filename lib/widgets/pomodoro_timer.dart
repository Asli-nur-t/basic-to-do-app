import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../controllers/pomodoro_settings_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer>
    with WidgetsBindingObserver {
  final settings = Get.put(PomodoroSettingsController());
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? _timer;
  int _secondsLeft = 0;
  bool _isRunning = false;
  bool _isBreak = false;
  int _pomodoroCount = 0;
  int _currentDuration = 25;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeNotifications();
    _loadTimerState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveTimerState();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveTimerState();
    } else if (state == AppLifecycleState.resumed) {
      _loadTimerState();
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Bildirime tıklandığında yapılacak işlemler
      },
    );
  }

  Future<void> _saveTimerState() async {
    if (!_isRunning) return; // Eğer timer çalışmıyorsa kaydetmeye gerek yok

    final box = Hive.box('settings');
    box.put('secondsLeft', _secondsLeft);
    box.put('isRunning', _isRunning);
    box.put('isBreak', _isBreak);
    box.put('pomodoroCount', _pomodoroCount);
    box.put('lastActiveTime', DateTime.now().millisecondsSinceEpoch);
    box.put('currentDuration', _currentDuration);
  }

  Future<void> _loadTimerState() async {
    final box = Hive.box('settings');

    setState(() {
      _isRunning = box.get('isRunning', defaultValue: false);
      _isBreak = box.get('isBreak', defaultValue: false);
      _pomodoroCount = box.get('pomodoroCount', defaultValue: 0);
      _currentDuration =
          box.get('currentDuration', defaultValue: settings.workDuration.value);

      if (_isRunning) {
        final lastActiveTime = box.get('lastActiveTime',
            defaultValue: DateTime.now().millisecondsSinceEpoch);
        final now = DateTime.now().millisecondsSinceEpoch;
        final timeDifference = (now - lastActiveTime) ~/ 1000;

        _secondsLeft =
            box.get('secondsLeft', defaultValue: _currentDuration * 60);
        if (timeDifference > 0) {
          _secondsLeft = _secondsLeft - timeDifference;

          // Eğer süre bitmişse
          if (_secondsLeft <= 0) {
            _pomodoroCount++;
            if (_isBreak) {
              _secondsLeft = _currentDuration * 60;
              _isBreak = false;
            } else {
              if (_pomodoroCount % 4 == 0) {
                _secondsLeft = settings.longBreakDuration.value * 60;
              } else {
                _secondsLeft = settings.shortBreakDuration.value * 60;
              }
              _isBreak = true;
            }
          }
        }
      } else {
        _secondsLeft =
            box.get('secondsLeft', defaultValue: _currentDuration * 60);
      }
    });

    if (_isRunning) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _pomodoroCount++;

          if (_isBreak) {
            _secondsLeft = _currentDuration * 60;
            _isBreak = false;
            _showNotification('Mola Bitti!', 'Çalışmaya devam et');
          } else {
            if (_pomodoroCount % 4 == 0) {
              _secondsLeft = settings.longBreakDuration.value * 60;
              _showNotification('Uzun Mola Zamanı!', '15 dakika mola ver');
            } else {
              _secondsLeft = settings.shortBreakDuration.value * 60;
              _showNotification('Pomodoro Tamamlandı!', '5 dakika mola ver');
            }
            _isBreak = true;
          }
        }
      });
    });
  }

  void _toggleTimer() {
    if (_secondsLeft == 0) {
      setState(() {
        if (_isBreak) {
          _secondsLeft = settings.shortBreakDuration.value * 60;
        } else {
          _secondsLeft = _currentDuration * 60;
        }
      });
    }

    if (_isRunning) {
      _timer?.cancel();
    } else {
      _startTimer();
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      if (_isBreak) {
        _secondsLeft = settings.shortBreakDuration.value * 60;
      } else {
        _secondsLeft = _currentDuration * 60;
      }
      _isRunning = false;
      _pomodoroCount = 0;
    });
  }

  String get _timerText {
    final minutes = (_secondsLeft / 60).floor();
    final seconds = _secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Bildirimleri',
      channelDescription: 'Pomodoro zamanlayıcı bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );

    // SnackBar'ı da göster
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title\n$body'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isBreak ? 'Mola Zamanı' : 'Çalışma Zamanı',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Text(
            _timerText,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _toggleTimer,
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                label: Text(_isRunning ? 'Duraklat' : 'Başlat'),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh),
                label: const Text('Sıfırla'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Tamamlanan Pomodoro: $_pomodoroCount',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    final workController =
        TextEditingController(text: settings.workDuration.toString());
    final shortBreakController =
        TextEditingController(text: settings.shortBreakDuration.toString());
    final longBreakController =
        TextEditingController(text: settings.longBreakDuration.toString());

    Get.dialog(
      AlertDialog(
        title: const Text('Pomodoro Ayarları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: workController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Çalışma Süresi (dakika)',
              ),
            ),
            TextField(
              controller: shortBreakController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kısa Mola Süresi (dakika)',
              ),
            ),
            TextField(
              controller: longBreakController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Uzun Mola Süresi (dakika)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              int? newWorkDuration = int.tryParse(workController.text);
              if (newWorkDuration != null) {
                _currentDuration = newWorkDuration;
              }

              settings.updateSettings(
                work: newWorkDuration,
                shortBreak: int.tryParse(shortBreakController.text),
                longBreak: int.tryParse(longBreakController.text),
              );

              if (!_isRunning) {
                setState(() {
                  if (_isBreak) {
                    _secondsLeft = settings.shortBreakDuration.value * 60;
                  } else {
                    _secondsLeft = _currentDuration * 60;
                  }
                });
              }
              Get.back();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
