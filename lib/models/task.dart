import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
enum TaskType {
  @HiveField(0)
  study,
  @HiveField(1)
  reading,
  @HiveField(2)
  exercise,
  @HiveField(3)
  other
}

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime deadline;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  TaskType taskType;

  @HiveField(6)
  int? targetPages;

  @HiveField(7)
  int? targetQuestions;

  @HiveField(8)
  int? targetMinutes;

  @HiveField(9)
  DateTime? startTime;

  @HiveField(10)
  DateTime? endTime;

  @HiveField(11)
  int? completedPages;

  @HiveField(12)
  int? completedQuestions;

  @HiveField(13)
  int? completedMinutes;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.taskType,
    this.isCompleted = false,
    this.targetPages,
    this.targetQuestions,
    this.targetMinutes,
    this.startTime,
    this.endTime,
    this.completedPages = 0,
    this.completedQuestions = 0,
    this.completedMinutes = 0,
  });

  double get progressPercentage {
    switch (taskType) {
      case TaskType.reading:
        return targetPages != null && targetPages! > 0
            ? (completedPages ?? 0) / targetPages!
            : 0;
      case TaskType.study:
        return targetQuestions != null && targetQuestions! > 0
            ? (completedQuestions ?? 0) / targetQuestions!
            : 0;
      case TaskType.exercise:
        return targetMinutes != null && targetMinutes! > 0
            ? (completedMinutes ?? 0) / targetMinutes!
            : 0;
      default:
        return 0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted,
      'taskType': taskType.index,
      'targetPages': targetPages,
      'targetQuestions': targetQuestions,
      'targetMinutes': targetMinutes,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      isCompleted: json['isCompleted'],
      taskType: TaskType.values[json['taskType']],
      targetPages: json['targetPages'],
      targetQuestions: json['targetQuestions'],
      targetMinutes: json['targetMinutes'],
    );
  }
}
