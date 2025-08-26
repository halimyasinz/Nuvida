import 'package:hive/hive.dart';

part 'exam.g.dart';

@HiveType(typeId: 2)
class Exam extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String courseName;

  @HiveField(3)
  final DateTime dateTime;

  @HiveField(4)
  final String location;

  @HiveField(5)
  final String? note;

  @HiveField(6)
  final DateTime createdAt;

  Exam({
    required this.id,
    required this.title,
    required this.courseName,
    required this.dateTime,
    required this.location,
    this.note,
    required this.createdAt,
  });

  Exam copyWith({
    String? id,
    String? title,
    String? courseName,
    DateTime? dateTime,
    String? location,
    String? note,
    DateTime? createdAt,
  }) {
    return Exam(
      id: id ?? this.id,
      title: title ?? this.title,
      courseName: courseName ?? this.courseName,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
