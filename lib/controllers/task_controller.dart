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
  }

  void addTask(Task task) {
    tasks.add(task);
    _box.add(task);
  }

  void removeTask(String id) {
    tasks.removeWhere((task) => task.id == id);
    final index = _box.values.toList().indexWhere((task) => task.id == id);
    if (index != -1) {
      _box.deleteAt(index);
    }
  }

  void toggleTaskCompletion(String id) {
    final task = tasks.firstWhere((task) => task.id == id);
    task.isCompleted = !task.isCompleted;
    final index = _box.values.toList().indexWhere((t) => t.id == id);
    if (index != -1) {
      _box.putAt(index, task);
    }
    update();
  }

  void loadTasks() {
    final taskList = _box.values.toList();
    tasks.assignAll(taskList);
  }
}
