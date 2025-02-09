import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../models/task.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime? _startTime;
  DateTime? _endTime;
  TaskType _selectedType = TaskType.study;
  final _targetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Görev Ekle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Başlık'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Açıklama'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Görev Tipi'),
              items: TaskType.values.map((type) {
                String label;
                switch (type) {
                  case TaskType.study:
                    label = 'Ders Çalışma';
                    break;
                  case TaskType.reading:
                    label = 'Kitap Okuma';
                    break;
                  case TaskType.exercise:
                    label = 'Egzersiz';
                    break;
                  case TaskType.other:
                    label = 'Diğer';
                    break;
                }
                return DropdownMenuItem(value: type, child: Text(label));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  _targetController.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            if (_selectedType != TaskType.other) ...[
              TextField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _getTargetLabel(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 16),
            _buildTimeRangePicker(),
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
            if (_titleController.text.isNotEmpty) {
              final task = Task(
                id: DateTime.now().toString(),
                title: _titleController.text,
                description: _descriptionController.text,
                deadline: _selectedDate,
                taskType: _selectedType,
                targetPages: _selectedType == TaskType.reading
                    ? int.tryParse(_targetController.text)
                    : null,
                targetQuestions: _selectedType == TaskType.study
                    ? int.tryParse(_targetController.text)
                    : null,
                targetMinutes: _selectedType == TaskType.exercise
                    ? int.tryParse(_targetController.text)
                    : null,
                startTime: _startTime,
                endTime: _endTime,
              );
              Get.find<TaskController>().addTask(task);
              Get.back();
            }
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }

  String _getTargetLabel() {
    switch (_selectedType) {
      case TaskType.study:
        return 'Hedef Soru Sayısı';
      case TaskType.reading:
        return 'Hedef Sayfa Sayısı';
      case TaskType.exercise:
        return 'Hedef Süre (Dakika)';
      case TaskType.other:
        return '';
    }
  }

  Widget _buildTimeRangePicker() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              const Text('Başlangıç'),
              TextButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      _startTime = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                },
                child: Text(_startTime != null
                    ? '${_startTime!.hour}:${_startTime!.minute.toString().padLeft(2, '0')}'
                    : 'Seç'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              const Text('Bitiş'),
              TextButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      _endTime = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                },
                child: Text(_endTime != null
                    ? '${_endTime!.hour}:${_endTime!.minute.toString().padLeft(2, '0')}'
                    : 'Seç'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }
}
