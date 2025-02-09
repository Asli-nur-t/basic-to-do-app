import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../controllers/pomodoro_settings_controller.dart';
import 'package:get/get.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer>
    with WidgetsBindingObserver {
  final settings = Get.put(PomodoroSettingsController());

  static const workDuration = 25 * 60;
  static const breakDuration = 5 * 60;
  static const longBreakDuration = 15 * 60;

  Timer? _timer;
  int _secondsLeft = workDuration;
  bool _isRunning = false;
  bool _isBreak = false;
  int _pomodoroCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    if (state == AppLifecycleState.paused) {
      _saveTimerState();
    } else if (state == AppLifecycleState.resumed) {
      _loadTimerState();
    }
  }

  Future<void> _saveTimerState() async {
    final box = Hive.box('settings');
    box.put('secondsLeft', _secondsLeft);
    box.put('isRunning', _isRunning);
    box.put('isBreak', _isBreak);
    box.put('pomodoroCount', _pomodoroCount);
  }

  Future<void> _loadTimerState() async {
    final box = Hive.box('settings');
    setState(() {
      _secondsLeft = box.get('secondsLeft',
          defaultValue: settings.workDuration.value * 60);
      _isRunning = box.get('isRunning', defaultValue: false);
      _isBreak = box.get('isBreak', defaultValue: false);
      _pomodoroCount = box.get('pomodoroCount', defaultValue: 0);
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
            _secondsLeft = workDuration;
            _isBreak = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mola Bitti! Çalışmaya devam et')),
            );
          } else {
            if (_pomodoroCount % 4 == 0) {
              _secondsLeft = longBreakDuration;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Uzun Mola Zamanı! 15 dakika mola ver')),
              );
            } else {
              _secondsLeft = breakDuration;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Pomodoro Tamamlandı! 5 dakika mola ver')),
              );
            }
            _isBreak = true;
          }
        }
      });
    });
  }

  void _toggleTimer() {
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
      _secondsLeft = settings.workDuration.value * 60;
      _isRunning = false;
      _isBreak = false;
      _pomodoroCount = 0;
    });
  }

  String get _timerText {
    final minutes = (_secondsLeft / 60).floor();
    final seconds = _secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
              settings.updateSettings(
                work: int.tryParse(workController.text),
                shortBreak: int.tryParse(shortBreakController.text),
                longBreak: int.tryParse(longBreakController.text),
              );
              _resetTimer();
              Get.back();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
