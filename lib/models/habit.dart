import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  bool completed;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final String? category;

  Habit({
    required this.id,
    required this.title,
    this.completed = false,
    required this.createdAt,
    this.description,
    this.category,
  });

  Habit copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? createdAt,
    String? description,
    String? category,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }
}
