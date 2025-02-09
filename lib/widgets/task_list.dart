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
            return Dismissible(
              key: Key(task.id),
              onDismissed: (_) => taskController.removeTask(task.id),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
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
                      Text(
                        'Bitiş: ${task.deadline.day}/${task.deadline.month}/${task.deadline.year} '
                        '${task.deadline.hour}:${task.deadline.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (task.targetPages != null)
                        Text('Hedef: ${task.targetPages} sayfa'),
                      if (task.targetQuestions != null)
                        Text('Hedef: ${task.targetQuestions} soru'),
                      if (task.targetMinutes != null)
                        Text('Hedef: ${task.targetMinutes} dakika'),
                    ],
                  ),
                  trailing: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) =>
                        taskController.toggleTaskCompletion(task.id),
                  ),
                ),
              ),
            );
          },
        ));
  }
}
