import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../services/hive_service.dart';

class CourseProvider with ChangeNotifier {
  List<Course> _courses = [];
  bool _isLoading = false;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;

  // Uygulama başladığında verileri yükle
  Future<void> loadCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      _courses = HiveService.getAllCourses();
    } catch (e) {
      if (kDebugMode) {
        print('Course yükleme hatası: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Yeni ders ekle
  Future<void> addCourse(Course course) async {
    try {
      await HiveService.addCourse(course);
      _courses.add(course);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Course ekleme hatası: $e');
      }
      rethrow;
    }
  }

  // Ders güncelle
  Future<void> updateCourse(Course course) async {
    try {
      await HiveService.updateCourse(course);
      final index = _courses.indexWhere((c) => c.id == course.id);
      if (index != -1) {
        _courses[index] = course;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Course güncelleme hatası: $e');
      }
      rethrow;
    }
  }

  // Ders sil
  Future<void> deleteCourse(String id) async {
    try {
      await HiveService.deleteCourse(id);
      _courses.removeWhere((course) => course.id == id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Course silme hatası: $e');
      }
      rethrow;
    }
  }

  // Belirli bir güne ait dersleri getir
  List<Course> getCoursesByDay(String day) {
    return _courses.where((course) => course.day == day).toList();
  }

  // Toplam ders sayısı
  int get totalCoursesCount => _courses.length;

  // Günlere göre ders sayıları
  Map<String, int> get coursesByDayCount {
    final Map<String, int> count = {};
    for (final course in _courses) {
      count[course.day] = (count[course.day] ?? 0) + 1;
    }
    return count;
  }
}
