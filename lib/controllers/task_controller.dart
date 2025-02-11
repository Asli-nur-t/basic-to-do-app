import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class TaskController extends GetxController {
  final _box = Hive.box<Task>('tasks');
  final _tasks = <Task>[].obs;
  List<Task> get tasks => _tasks;

  // Filtreleme için
  final selectedCategory = 'Tümü'.obs;
  final selectedPriority = 0.obs; // 0: Tümü, 1: Düşük, 2: Orta, 3: Yüksek

  // Kategorileri yönet
  final categories = <String>['Tümü', 'Genel', 'Okul', 'İş', 'Kişisel'].obs;

  // Filtrelenmiş görevleri getir
  List<Task> get filteredTasks {
    return _tasks.where((task) {
      bool categoryMatch = selectedCategory.value == 'Tümü' ||
          task.category == selectedCategory.value;
      bool priorityMatch = selectedPriority.value == 0 ||
          task.priority == selectedPriority.value;
      return categoryMatch && priorityMatch;
    }).toList();
  }

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

  void toggleTaskStatus(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      update();
    }
  }

  void loadTasks() {
    _tasks.assignAll(_box.values.toList());
    update();
  }

  // Görevi güncelle
  void updateTask(
    String id, {
    String? title,
    String? description,
    DateTime? deadline,
    TaskType? taskType,
    int? priority,
    String? category,
    int? dailyTarget,
    int? weeklyTarget,
  }) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      if (title != null) task.title = title;
      if (description != null) task.description = description;
      if (deadline != null) task.deadline = deadline;
      if (taskType != null) task.taskType = taskType;
      if (priority != null) task.priority = priority;
      if (category != null) task.category = category;
      if (dailyTarget != null) task.dailyTarget = dailyTarget;
      if (weeklyTarget != null) task.weeklyTarget = weeklyTarget;
      task.lastUpdated = DateTime.now();

      _box.put(task.id, task);
      update();
    }
  }

  // Yeni kategori ekle
  void addCategory(String category) {
    if (!categories.contains(category)) {
      categories.add(category);
      update();
    }
  }
}
