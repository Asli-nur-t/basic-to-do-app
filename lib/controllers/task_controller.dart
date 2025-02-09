import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class TaskController extends GetxController {
  final _box = Hive.box<Task>('tasks');
  final tasks = <Task>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
    // Box'taki değişiklikleri dinle
    _box.listenable().addListener(() {
      loadTasks();
    });
  }

  void addTask(Task task) {
    _box.add(task);
    loadTasks(); // Listeyi yenile
  }

  void removeTask(String id) {
    final index = _box.values.toList().indexWhere((task) => task.id == id);
    if (index != -1) {
      _box.deleteAt(index);
      loadTasks(); // Listeyi yenile
    }
  }

  void toggleTaskCompletion(String id) {
    final index = _box.values.toList().indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _box.values.toList()[index];
      task.isCompleted = !task.isCompleted;
      _box.putAt(index, task);
      loadTasks(); // Listeyi yenile
    }
  }

  void updateProgress(String id, {int? pages, int? questions, int? minutes}) {
    final index = _box.values.toList().indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _box.values.toList()[index];

      // Eğer görev tipi "other" ise ilerleme güncellemeyi atla
      if (task.taskType != TaskType.other) {
        if (pages != null) task.completedPages = pages;
        if (questions != null) task.completedQuestions = questions;
        if (minutes != null) task.completedMinutes = minutes;

        if (task.progressPercentage >= 1.0) {
          task.isCompleted = true;
        }
      }

      _box.putAt(index, task);
      loadTasks();
    }
  }

  void loadTasks() {
    tasks.assignAll(_box.values.toList());
    update();
  }
}
