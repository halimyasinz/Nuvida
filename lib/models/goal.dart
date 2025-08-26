import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 3)
class Goal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime targetDate;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  final String category;

  @HiveField(7)
  int progress;

  @HiveField(8)
  final List<String> milestones;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetDate,
    required this.createdAt,
    this.isCompleted = false,
    required this.category,
    this.progress = 0,
    this.milestones = const [],
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? targetDate,
    DateTime? createdAt,
    bool? isCompleted,
    String? category,
    int? progress,
    List<String>? milestones,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      progress: progress ?? this.progress,
      milestones: milestones ?? this.milestones,
    );
  }
}
