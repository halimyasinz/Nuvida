import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 4)
class Note extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime lastModified;

  @HiveField(5)
  final String? courseName;

  @HiveField(6)
  final List<String> tags;

  @HiveField(7)
  bool isImportant;

  @HiveField(8)
  String? category;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.lastModified,
    this.courseName,
    this.tags = const [],
    this.isImportant = false,
    this.category,
  }) {
    print('Note constructor: $title, category: $category, tags: $tags, isImportant: $isImportant');
    print('Note ID: $id, createdAt: $createdAt, lastModified: $lastModified');
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? lastModified,
    String? courseName,
    List<String>? tags,
    bool? isImportant,
    String? category,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      courseName: courseName ?? this.courseName,
      tags: tags ?? this.tags,
      isImportant: isImportant ?? this.isImportant,
      category: category ?? this.category,
    );
  }
}
