import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../models/task.dart';

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.put(TaskController());

    return Obx(() => ListView.builder(
          itemCount: taskController.tasks.length,
          itemBuilder: (context, index) {
            final task = taskController.tasks[index];
            return GestureDetector(
              onLongPress: () {
                Get.bottomSheet(
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.check_circle),
                          title: const Text('Görevi Tamamlandı İşaretle'),
                          onTap: () {
                            taskController.toggleTaskCompletion(task.id);
                            Get.back();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: const Text('Görevi Sil',
                              style: TextStyle(color: Colors.red)),
                          onTap: () {
                            taskController.removeTask(task.id);
                            Get.back();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.description),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: task.progressPercentage,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              task.isCompleted ? Colors.green : Colors.blue,
                            ),
                          ),
                          Text(
                            _getProgressText(task),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            task.isCompleted
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color:
                                task.isCompleted ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          if (task.taskType != TaskType.other)
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () =>
                                  _showProgressDialog(context, task),
                            ),
                        ],
                      ),
                    ),
                    if (task.deadline != null)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Bitiş: ${task.deadline.day}/${task.deadline.month}/${task.deadline.year}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ));
  }

  String _getProgressText(Task task) {
    if (task.taskType == TaskType.other) {
      return '';
    }

    switch (task.taskType) {
      case TaskType.reading:
        return '${task.completedPages ?? 0}/${task.targetPages} sayfa';
      case TaskType.study:
        return '${task.completedQuestions ?? 0}/${task.targetQuestions} soru';
      case TaskType.exercise:
        return '${task.completedMinutes ?? 0}/${task.targetMinutes} dakika';
      default:
        return '';
    }
  }

  void _showProgressDialog(BuildContext context, Task task) {
    final controller = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('İlerleme Güncelle'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: _getProgressLabel(task),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null) {
                switch (task.taskType) {
                  case TaskType.reading:
                    Get.find<TaskController>()
                        .updateProgress(task.id, pages: value);
                    break;
                  case TaskType.study:
                    Get.find<TaskController>()
                        .updateProgress(task.id, questions: value);
                    break;
                  case TaskType.exercise:
                    Get.find<TaskController>()
                        .updateProgress(task.id, minutes: value);
                    break;
                  default:
                    break;
                }
                Get.back();
              }
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  String _getProgressLabel(Task task) {
    switch (task.taskType) {
      case TaskType.reading:
        return 'Okunan Sayfa Sayısı';
      case TaskType.study:
        return 'Çözülen Soru Sayısı';
      case TaskType.exercise:
        return 'Tamamlanan Dakika';
      default:
        return '';
    }
  }
}
