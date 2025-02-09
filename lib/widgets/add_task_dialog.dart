import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';

class AddTaskDialog extends StatefulWidget {
  final int? initialMinutes;

  const AddTaskDialog({
    super.key,
    this.initialMinutes,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskType _selectedType = TaskType.exercise;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialMinutes != null) {
      _selectedType = TaskType.exercise;
    }
  }

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
              decoration: const InputDecoration(
                labelText: 'Başlık',
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskType>(
              value: _selectedType,
              items: TaskType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_selectedDate == null
                  ? 'Tarih Seç'
                  : 'Tarih: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
            if (widget.initialMinutes != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Ölçülen süre: ${widget.initialMinutes} dakika',
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
            if (_titleController.text.isNotEmpty) {
              final task = Task(
                id: DateTime.now().toString(),
                title: _titleController.text,
                description: _descriptionController.text,
                deadline: DateTime.now(),
                taskType: _selectedType,
                targetMinutes: widget.initialMinutes,
                completedMinutes: widget.initialMinutes,
                dueDate: _selectedDate,
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
}
