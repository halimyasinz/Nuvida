import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../models/course.dart';
import '../models/exam.dart';
import '../models/goal.dart';
import '../models/note.dart';
import '../models/event.dart';

class HiveService {
  static const String _habitBoxName = 'habits';
  static const String _courseBoxName = 'courses';
  static const String _examBoxName = 'exams';
  static const String _goalBoxName = 'goals';
  static const String _noteBoxName = 'notes';
  static const String _eventBoxName = 'events';
  
  static bool _isInitialized = false;

  static Future<void> init() async {
    // Eğer zaten başlatılmışsa, tekrar başlatma
    if (_isInitialized) {
      print('HiveService zaten başlatılmış');
      return;
    }

    await Hive.initFlutter();

    // Model adaptörlerini güvenli bir şekilde kaydet
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CourseAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ExamAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(GoalAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(NoteAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(EventAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(EventTypeAdapter());
    }

    // Box'ları aç
    await Hive.openBox<Habit>(_habitBoxName);
    await Hive.openBox<Course>(_courseBoxName);
    await Hive.openBox<Exam>(_examBoxName);
    await Hive.openBox<Goal>(_goalBoxName);
    await Hive.openBox<Note>(_noteBoxName);
    await Hive.openBox<Event>(_eventBoxName);
    
    _isInitialized = true;
    print('HiveService başarıyla başlatıldı');
  }

  // Habit işlemleri
  static Box<Habit> get habitBox => Hive.box<Habit>(_habitBoxName);

  static List<Habit> getAllHabits() {
    return habitBox.values.toList();
  }

  static Future<void> addHabit(Habit habit) async {
    await habitBox.put(habit.id, habit);
  }

  static Future<void> updateHabit(Habit habit) async {
    await habitBox.put(habit.id, habit);
  }

  static Future<void> deleteHabit(String id) async {
    await habitBox.delete(id);
  }

  // Course işlemleri
  static Box<Course> get courseBox => Hive.box<Course>(_courseBoxName);

  static List<Course> getAllCourses() {
    return courseBox.values.toList();
  }

  static Future<void> addCourse(Course course) async {
    await courseBox.put(course.id, course);
  }

  static Future<void> updateCourse(Course course) async {
    await courseBox.put(course.id, course);
  }

  static Future<void> deleteCourse(String id) async {
    await courseBox.delete(id);
  }

  // Exam işlemleri
  static Box<Exam> get examBox => Hive.box<Exam>(_examBoxName);

  static List<Exam> getAllExams() {
    return examBox.values.toList();
  }

  static Future<void> addExam(Exam exam) async {
    await examBox.put(exam.id, exam);
  }

  static Future<void> updateExam(Exam exam) async {
    await examBox.put(exam.id, exam);
  }

  static Future<void> deleteExam(String id) async {
    await examBox.delete(id);
  }

  // Goal işlemleri
  static Box<Goal> get goalBox => Hive.box<Goal>(_goalBoxName);

  static List<Goal> getAllGoals() {
    return goalBox.values.toList();
  }

  static Future<void> addGoal(Goal goal) async {
    await goalBox.put(goal.id, goal);
  }

  static Future<void> updateGoal(Goal goal) async {
    await goalBox.put(goal.id, goal);
  }

  static Future<void> deleteGoal(String id) async {
    await goalBox.delete(id);
  }

  // Note işlemleri
  static Box<Note> get noteBox => Hive.box<Note>(_noteBoxName);

  static List<Note> getAllNotes() {
    try {
      print('HiveService.getAllNotes: Note box\'tan veriler alınıyor...');
      
      // Box'ın açık olduğundan emin ol
      if (!noteBox.isOpen) {
        print('Note box kapalı, açılıyor...');
        Hive.openBox<Note>(_noteBoxName);
      }
      
      final notes = noteBox.values.toList();
      print('HiveService.getAllNotes: ${notes.length} not bulundu');
      
      // Her notun detaylarını yazdır
      for (int i = 0; i < notes.length; i++) {
        final note = notes[i];
        print('Not $i: ID=${note.id}, Title=${note.title}, Category=${note.category}');
      }
      
      return notes;
    } catch (e) {
      print('HiveService.getAllNotes hatası: $e');
      rethrow;
    }
  }

  static Future<void> addNote(Note note) async {
    print('HiveService.addNote başladı: ${note.title}');
    print('Note detayları: ID=${note.id}, Category=${note.category}, Tags=${note.tags}');
    
    try {
      // Box'ın açık olduğundan emin ol
      if (!noteBox.isOpen) {
        print('Note box kapalı, açılıyor...');
        await Hive.openBox<Note>(_noteBoxName);
      }
      
      await noteBox.put(note.id, note);
      print('Note başarıyla Hive box\'a kaydedildi: ${note.id}');
      
      // Kaydedilen notu kontrol et
      final savedNote = noteBox.get(note.id);
      if (savedNote != null) {
        print('Kaydedilen not doğrulandı: ${savedNote.title}');
      } else {
        print('UYARI: Kaydedilen not bulunamadı!');
      }
    } catch (e) {
      print('HiveService.addNote hatası: $e');
      rethrow;
    }
  }

  static Future<void> updateNote(Note note) async {
    await noteBox.put(note.id, note);
  }

  static Future<void> deleteNote(String id) async {
    await noteBox.delete(id);
  }

  // Event işlemleri
  static Box<Event> get eventBox => Hive.box<Event>(_eventBoxName);

  static List<Event> getAllEvents() {
    try {
      print('HiveService.getAllEvents: Event box\'tan veriler alınıyor...');
      final events = eventBox.values.toList();
      print('HiveService.getAllEvents: ${events.length} event bulundu');
      return events;
    } catch (e) {
      print('HiveService.getAllEvents hatası: $e');
      rethrow;
    }
  }

  static Future<void> addEvent(Event event) async {
    print('HiveService.addEvent başladı: ${event.title}');
    try {
      await eventBox.put(event.id, event);
      print('Event başarıyla Hive box\'a kaydedildi: ${event.id}');
    } catch (e) {
      print('HiveService.addEvent hatası: $e');
      rethrow;
    }
  }

  static Future<void> updateEvent(Event event) async {
    await eventBox.put(event.id, event);
  }

  static Future<void> deleteEvent(String id) async {
    await eventBox.delete(id);
  }

  // Tüm verileri temizle (test için)
  static Future<void> clearAllData() async {
    await habitBox.clear();
    await courseBox.clear();
    await examBox.clear();
    await goalBox.clear();
    await noteBox.clear();
    await eventBox.clear();
  }

  // Eski notları güncelle (category field'ı ekle)
  static Future<void> updateExistingNotes() async {
    try {
      final notes = getAllNotes();
      for (final note in notes) {
        if (note.category == null) {
          final updatedNote = note.copyWith(category: 'Genel');
          await updateNote(updatedNote);
        }
      }
      print('Mevcut notlar güncellendi');
    } catch (e) {
      print('Not güncelleme hatası: $e');
    }
  }

  // Örnek notlar ekle (test için)
  static Future<void> addSampleNotes() async {
    final sampleNotes = [
      Note(
        id: '1',
        title: 'Matematik Formülleri',
        content: 'Kare, küp, kök alma formülleri ve temel matematik kuralları.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        lastModified: DateTime.now().subtract(const Duration(days: 1)),
        courseName: 'Matematik 101',
        tags: ['matematik', 'formül', 'önemli'],
        isImportant: true,
        category: 'Ders',
      ),
      Note(
        id: '2',
        title: 'Flutter Proje Planı',
        content: 'Flutter uygulaması geliştirme süreci ve yapılacaklar listesi.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        lastModified: DateTime.now().subtract(const Duration(days: 3)),
        courseName: 'Yazılım Geliştirme',
        tags: ['proje', 'flutter', 'plan'],
        isImportant: false,
        category: 'Kişisel',
      ),
      Note(
        id: '3',
        title: 'Kişisel Hedefler',
        content: 'Bu yıl için belirlenen kişisel ve akademik hedefler.',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        lastModified: DateTime.now().subtract(const Duration(days: 7)),
        courseName: null,
        tags: ['hedef', 'kişisel', 'planlama'],
        isImportant: true,
        category: 'Kişisel',
      ),
      Note(
        id: '4',
        title: 'Sınav Çalışma Planı',
        content: 'Final sınavı için önemli konular ve çalışma planı.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        lastModified: DateTime.now(),
        courseName: 'Genel Kimya',
        tags: ['sınav', 'kimya', 'final', 'önemli'],
        isImportant: true,
        category: 'Ders',
      ),
      Note(
        id: '5',
        title: 'Okuma Listesi',
        content: 'Bu ay okunacak kitaplar ve makaleler.',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastModified: DateTime.now().subtract(const Duration(days: 12)),
        courseName: null,
        tags: ['okuma', 'kitap', 'makale'],
        isImportant: false,
        category: 'Okuma',
      ),
      Note(
        id: '6',
        title: 'Fitness Rutini',
        content: 'Haftalık egzersiz programı ve sağlık hedefleri.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        lastModified: DateTime.now(),
        courseName: null,
        tags: ['fitness', 'egzersiz', 'sağlık'],
        isImportant: true,
        category: 'Spor / Sağlık',
      ),
      Note(
        id: '7',
        title: 'Konser Etkinliği',
        content: 'Gelecek hafta gidilecek konser için detaylar ve plan.',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        lastModified: DateTime.now().subtract(const Duration(days: 6)),
        courseName: null,
        tags: ['konser', 'etkinlik', 'eğlence'],
        isImportant: false,
        category: 'Etkinlik',
      ),
    ];

    for (final note in sampleNotes) {
      await addNote(note);
    }
    print('Örnek notlar başarıyla eklendi');
  }
}
