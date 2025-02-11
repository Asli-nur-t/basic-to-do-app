import 'package:get/get.dart';
import 'dart:async';

class StopwatchController extends GetxController {
  Timer? _timer;
  final _seconds = 0.obs;
  final _isRunning = false.obs;
  final _laps = <String>[].obs;

  bool get isRunning => _isRunning.value;
  List<String> get laps => _laps;

  int get hours => _seconds.value ~/ 3600;
  int get minutes => (_seconds.value % 3600) ~/ 60;
  int get seconds => _seconds.value % 60;

  void start() {
    if (!_isRunning.value) {
      _isRunning.value = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _seconds.value++;
        update();
      });
    }
  }

  void stop() {
    _timer?.cancel();
    _isRunning.value = false;
    update();
  }

  void reset() {
    stop();
    _seconds.value = 0;
    _laps.clear();
    update();
  }

  void lap() {
    final currentTime =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    _laps.add(currentTime);
    update();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
