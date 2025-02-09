import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../widgets/add_task_dialog.dart';

class StopwatchView extends StatefulWidget {
  const StopwatchView({super.key});

  @override
  State<StopwatchView> createState() => _StopwatchViewState();
}

class _StopwatchViewState extends State<StopwatchView> {
  final TaskController taskController = Get.find<TaskController>();
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
    setState(() {
      _isRunning = true;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
      _isRunning = false;
    });
  }

  String get _formattedTime {
    int hours = _seconds ~/ 3600;
    int minutes = (_seconds % 3600) ~/ 60;
    int secs = _seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showTaskSelectionDialog() {
    final minutes = _seconds ~/ 60;
    if (minutes == 0) {
      Get.snackbar('Uyarı', 'Ölçülen süre çok kısa');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Süreyi Kaydet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ölçülen süre: $minutes dakika'),
            const SizedBox(height: 16),
            Obx(() {
              final exerciseTasks = taskController.tasks
                  .where((task) =>
                      !task.isCompleted &&
                      (task.taskType == TaskType.exercise ||
                          task.taskType == TaskType.study))
                  .toList();

              return exerciseTasks.isEmpty
                  ? const Text('Uygun görev bulunamadı')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: exerciseTasks.length,
                      itemBuilder: (context, index) {
                        final task = exerciseTasks[index];
                        return ListTile(
                          title: Text(task.title),
                          subtitle: Text(
                              '${task.completedMinutes ?? 0}/${task.targetMinutes ?? 0} dk'),
                          onTap: () {
                            taskController.updateProgress(
                              task.id,
                              minutes: (task.completedMinutes ?? 0) + minutes,
                            );
                            Get.back();
                            _resetTimer();
                          },
                        );
                      },
                    );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.dialog(AddTaskDialog(initialMinutes: minutes));
            },
            child: const Text('Yeni Görev Oluştur'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formattedTime,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                onPressed: _isRunning ? _stopTimer : _startTimer,
                child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
              ),
              const SizedBox(width: 20),
              FloatingActionButton(
                onPressed: _resetTimer,
                child: const Icon(Icons.refresh),
              ),
              if (_seconds > 0 && !_isRunning) ...[
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: _showTaskSelectionDialog,
                  child: const Icon(Icons.save),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
