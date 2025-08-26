import 'package:hive/hive.dart';

part 'event.g.dart';

@HiveType(typeId: 6)
enum EventType { 
  @HiveField(0)
  lesson, 
  @HiveField(1)
  exam, 
  @HiveField(2)
  club, 
  @HiveField(3)
  other 
}

@HiveType(typeId: 5)
class Event {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final EventType type;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final DateTime start;

  @HiveField(4)
  final DateTime end;

  @HiveField(5)
  final String? location;

  @HiveField(6)
  final String? note;

  @HiveField(7)
  final List<String> tags;

  Event({
    required this.id,
    required this.type,
    required this.title,
    required this.start,
    required this.end,
    this.location,
    this.note,
    this.tags = const [],
  });

  Event copyWith({
    String? id,
    EventType? type,
    String? title,
    DateTime? start,
    DateTime? end,
    String? location,
    String? note,
    List<String>? tags,
  }) {
    return Event(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
      location: location ?? this.location,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }
}
