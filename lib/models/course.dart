import 'package:hive/hive.dart';

part 'course.g.dart';

@HiveType(typeId: 1)
class Course extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String day;

  @HiveField(3)
  final String startTime;

  @HiveField(4)
  final String endTime;

  @HiveField(5)
  final String instructor;

  @HiveField(6)
  final String location;

  @HiveField(7)
  final DateTime createdAt;

  Course({
    required this.id,
    required this.name,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.instructor = 'Belirtilmemiş',
    this.location = 'Belirtilmemiş',
    required this.createdAt,
  });

  Course copyWith({
    String? id,
    String? name,
    String? day,
    String? startTime,
    String? endTime,
    String? instructor,
    String? location,
    DateTime? createdAt,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      instructor: instructor ?? this.instructor,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
