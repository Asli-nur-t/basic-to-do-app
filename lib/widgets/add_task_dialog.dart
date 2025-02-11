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
  final _dailyTargetController = TextEditingController();
  final _weeklyTargetController = TextEditingController();
  final _targetPagesController = TextEditingController();
  final _targetQuestionsController = TextEditingController();
  final _targetMinutesController = TextEditingController();
  final _completedQuestionsController = TextEditingController();

  TaskType _selectedType = TaskType.exercise;
  String _selectedCategory = 'Genel';
  int _selectedPriority = 2;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String _selectedRepeatType =
      'Bir Kez'; // Bir Kez, Her Gün, Hafta İçi, Hafta Sonu
  List<bool> _selectedDays = List.filled(7, false); // Pazartesi'den Pazar'a

  @override
  void initState() {
    super.initState();
    if (widget.initialMinutes != null) {
      _targetMinutesController.text = widget.initialMinutes.toString();
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
            // Temel Bilgiler
            _buildBasicInfo(),

            // Görev Tipi ve Hedefler
            _buildTaskTypeAndTargets(),

            // Tekrarlama Seçenekleri
            _buildRepeatOptions(),

            // Tamamlanan İlerleme (varsa)
            if (widget.initialMinutes != null) _buildCompletedProgress(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: const Text('Ekle'),
        ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Column(
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
        DropdownButtonFormField<String>(
          value: _selectedCategory,
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
            setState(() => _selectedCategory = value!);
          },
          decoration: const InputDecoration(labelText: 'Kategori'),
        ),
        DropdownButtonFormField<int>(
          value: _selectedPriority,
          items: const [
            DropdownMenuItem(value: 1, child: Text('Düşük Öncelik')),
            DropdownMenuItem(value: 2, child: Text('Orta Öncelik')),
            DropdownMenuItem(value: 3, child: Text('Yüksek Öncelik')),
          ],
          onChanged: (value) {
            setState(() => _selectedPriority = value!);
          },
          decoration: const InputDecoration(labelText: 'Öncelik'),
        ),
      ],
    );
  }

  Widget _buildTaskTypeAndTargets() {
    return Column(
      children: [
        DropdownButtonFormField<TaskType>(
          value: _selectedType,
          items: TaskType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_getTaskTypeName(type)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedType = value!);
          },
          decoration: const InputDecoration(labelText: 'Görev Tipi'),
        ),
        if (_selectedType == TaskType.reading)
          TextField(
            controller: _targetPagesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Hedef Sayfa Sayısı'),
          ),
        if (_selectedType == TaskType.study)
          TextField(
            controller: _targetQuestionsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Hedef Soru Sayısı'),
          ),
        TextField(
          controller: _targetMinutesController,
          keyboardType: TextInputType.number,
          decoration:
              const InputDecoration(labelText: 'Hedef Çalışma Süresi (dk)'),
        ),
      ],
    );
  }

  Widget _buildRepeatOptions() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedRepeatType,
          items: ['Bir Kez', 'Her Gün', 'Hafta İçi', 'Hafta Sonu', 'Özel']
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedRepeatType = value!;
              _updateSelectedDays();
            });
          },
          decoration: const InputDecoration(labelText: 'Tekrarlama'),
        ),
        if (_selectedRepeatType == 'Özel') _buildWeekDaySelector(),
        _buildDateRangePicker(),
      ],
    );
  }

  Widget _buildCompletedProgress() {
    return Column(
      children: [
        Text('Tamamlanan Süre: ${widget.initialMinutes} dakika'),
        if (_selectedType == TaskType.study)
          TextField(
            controller: _completedQuestionsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Tamamlanan Soru Sayısı',
            ),
          ),
      ],
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
      default:
        return '';
    }
  }

  Widget _buildDateRangePicker() {
    return Column(
      children: [
        ListTile(
          title: Text(_selectedStartDate == null
              ? 'Başlangıç Tarihi Seç'
              : 'Başlangıç: ${DateFormat('dd/MM/yyyy').format(_selectedStartDate!)}'),
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
                _selectedStartDate = date;
              });
            }
          },
        ),
        if (_selectedRepeatType == 'Bir Kez')
          ListTile(
            title: Text(_selectedEndDate == null
                ? 'Bitiş Tarihi Seç'
                : 'Bitiş: ${DateFormat('dd/MM/yyyy').format(_selectedEndDate!)}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedStartDate ?? DateTime.now(),
                firstDate: _selectedStartDate ?? DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _selectedEndDate = date;
                });
              }
            },
          ),
      ],
    );
  }

  Widget _buildWeekDaySelector() {
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return Wrap(
      spacing: 8.0,
      children: List.generate(7, (index) {
        return FilterChip(
          label: Text(days[index]),
          selected: _selectedDays[index],
          onSelected: (bool selected) {
            setState(() {
              _selectedDays[index] = selected;
            });
          },
        );
      }),
    );
  }

  void _updateSelectedDays() {
    switch (_selectedRepeatType) {
      case 'Her Gün':
        _selectedDays = List.filled(7, true);
        break;
      case 'Hafta İçi':
        _selectedDays = [true, true, true, true, true, false, false];
        break;
      case 'Hafta Sonu':
        _selectedDays = [false, false, false, false, false, true, true];
        break;
      case 'Özel':
        // Mevcut seçimi koru
        break;
      default:
        _selectedDays = List.filled(7, false);
    }
  }

  void _saveTask() {
    if (_titleController.text.isNotEmpty) {
      final task = Task(
        id: DateTime.now().toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        deadline: DateTime.now(),
        taskType: _selectedType,
        category: _selectedCategory,
        priority: _selectedPriority,
        dailyTarget: int.tryParse(_dailyTargetController.text),
        weeklyTarget: int.tryParse(_weeklyTargetController.text),
        targetMinutes: int.tryParse(_targetMinutesController.text),
        completedMinutes: widget.initialMinutes,
        dueDate: _selectedStartDate,
      );
      Get.find<TaskController>().addTask(task);
      Get.back();
    }
  }
}
