import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task.dart';
import '../controllers/task_controller.dart';
import 'package:intl/intl.dart';

class TaskDetailsDialog extends StatelessWidget {
  final Task task;

  const TaskDetailsDialog({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(task.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Açıklama
            if (task.description?.isNotEmpty ?? false) ...[
              const Text('Açıklama:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(task.description!),
              const SizedBox(height: 16),
            ],

            // Kategori ve Öncelik
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kategori:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(task.category),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Öncelik:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_getPriorityText(task.priority)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hedefler
            const Text('Hedefler:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            _buildTargetInfo(task),
            const SizedBox(height: 16),

            // Tarihler
            if (task.dueDate != null) ...[
              const Text('Tarih Bilgileri:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  'Başlangıç: ${DateFormat('dd/MM/yyyy').format(task.dueDate!)}'),
              if (task.deadline != task.dueDate)
                Text(
                    'Bitiş: ${DateFormat('dd/MM/yyyy').format(task.deadline)}'),
              const SizedBox(height: 16),
            ],

            // İlerleme
            const Text('İlerleme:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            LinearProgressIndicator(
              value: task.progressPercentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                task.isCompleted ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(_getProgressText(task)),
          ],
        ),
      ),
      actions: [
        // Düzenleme Butonu
        TextButton(
          onPressed: () {
            Get.back();
            _showEditDialog(context, task);
          },
          child: const Text('Düzenle'),
        ),
        // İlerleme Güncelleme Butonu
        TextButton(
          onPressed: () {
            Get.back();
            _showProgressUpdateDialog(context, task);
          },
          child: const Text('İlerleme Güncelle'),
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Kapat'),
        ),
      ],
    );
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Düşük';
      case 2:
        return 'Orta';
      case 3:
        return 'Yüksek';
      default:
        return 'Belirsiz';
    }
  }

  Widget _buildTargetInfo(Task task) {
    final List<Widget> targets = [];

    if (task.targetMinutes != null) {
      targets.add(Text('Hedef Süre: ${task.targetMinutes} dakika'));
    }

    switch (task.taskType) {
      case TaskType.reading:
        if (task.targetPages != null) {
          targets.add(Text('Hedef Sayfa: ${task.targetPages}'));
        }
        break;
      case TaskType.study:
        if (task.targetQuestions != null) {
          targets.add(Text('Hedef Soru: ${task.targetQuestions}'));
        }
        break;
      default:
        break;
    }

    if (task.dailyTarget != null) {
      targets.add(Text('Günlük Hedef: ${task.dailyTarget}'));
    }
    if (task.weeklyTarget != null) {
      targets.add(Text('Haftalık Hedef: ${task.weeklyTarget}'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: targets,
    );
  }

  String _getProgressText(Task task) {
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

  void _showProgressUpdateDialog(BuildContext context, Task task) {
    final pagesController = TextEditingController();
    final questionsController = TextEditingController();
    final minutesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('İlerleme Güncelle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Her görev için dakika girişi
              TextField(
                controller: minutesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tamamlanan Dakika',
                  hintText: 'Çalışılan süreyi girin',
                ),
              ),
              const SizedBox(height: 8),

              // Görev tipine göre ek alanlar
              if (task.taskType == TaskType.reading)
                TextField(
                  controller: pagesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Okunan Sayfa',
                    hintText: 'Okunan sayfa sayısını girin',
                  ),
                )
              else if (task.taskType == TaskType.study)
                TextField(
                  controller: questionsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Çözülen Soru',
                    hintText: 'Çözülen soru sayısını girin',
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final minutes = int.tryParse(minutesController.text);
              final pages = int.tryParse(pagesController.text);
              final questions = int.tryParse(questionsController.text);

              Get.find<TaskController>().updateProgress(
                task.id,
                minutes: minutes,
                pages: pages,
                questions: questions,
              );
              Get.back();
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    final dailyTargetController =
        TextEditingController(text: task.dailyTarget?.toString() ?? '');
    final weeklyTargetController =
        TextEditingController(text: task.weeklyTarget?.toString() ?? '');

    var selectedCategory = task.category;
    var selectedPriority = task.priority;
    var selectedType = task.taskType;

    Get.dialog(
      AlertDialog(
        title: const Text('Görevi Düzenle'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Başlık'),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Açıklama'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Kategori Seçimi
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: Get.find<TaskController>()
                        .categories
                        .where((c) => c != 'Tümü')
                        .map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedCategory = value!);
                    },
                    decoration: const InputDecoration(labelText: 'Kategori'),
                  ),

                  // Öncelik Seçimi
                  DropdownButtonFormField<int>(
                    value: selectedPriority,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Düşük Öncelik')),
                      DropdownMenuItem(value: 2, child: Text('Orta Öncelik')),
                      DropdownMenuItem(value: 3, child: Text('Yüksek Öncelik')),
                    ],
                    onChanged: (value) {
                      setState(() => selectedPriority = value!);
                    },
                    decoration: const InputDecoration(labelText: 'Öncelik'),
                  ),

                  // Görev Tipi Seçimi
                  DropdownButtonFormField<TaskType>(
                    value: selectedType,
                    items: TaskType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getTaskTypeName(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedType = value!);
                    },
                    decoration: const InputDecoration(labelText: 'Görev Tipi'),
                  ),

                  // Hedefler
                  TextField(
                    controller: dailyTargetController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Günlük Hedef'),
                  ),
                  TextField(
                    controller: weeklyTargetController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Haftalık Hedef'),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.find<TaskController>().updateTask(
                task.id,
                title: titleController.text,
                description: descController.text,
                taskType: selectedType,
                priority: selectedPriority,
                category: selectedCategory,
                dailyTarget: int.tryParse(dailyTargetController.text),
                weeklyTarget: int.tryParse(weeklyTargetController.text),
              );
              Get.back();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  String _getTaskTypeName(TaskType type) {
    switch (type) {
      case TaskType.reading:
        return 'Okuma';
      case TaskType.study:
        return 'Çalışma';
      case TaskType.exercise:
        return 'Egzersiz';
      case TaskType.work:
        return 'İş';
      default:
        return 'Diğer';
    }
  }
}
