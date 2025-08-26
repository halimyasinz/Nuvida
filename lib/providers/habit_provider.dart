import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../services/hive_service.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  bool _isLoading = false;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;

  // Uygulama başladığında verileri yükle
  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = HiveService.getAllHabits();
    } catch (e) {
      if (kDebugMode) {
        print('Habit yükleme hatası: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Yeni alışkanlık ekle
  Future<void> addHabit(Habit habit) async {
    try {
      await HiveService.addHabit(habit);
      _habits.add(habit);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Habit ekleme hatası: $e');
      }
      rethrow;
    }
  }

  // Alışkanlık güncelle
  Future<void> updateHabit(Habit habit) async {
    try {
      await HiveService.updateHabit(habit);
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Habit güncelleme hatası: $e');
      }
      rethrow;
    }
  }

  // Alışkanlık sil
  Future<void> deleteHabit(String id) async {
    try {
      await HiveService.deleteHabit(id);
      _habits.removeWhere((habit) => habit.id == id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Habit silme hatası: $e');
      }
      rethrow;
    }
  }

  // Alışkanlık durumunu değiştir
  Future<void> toggleHabit(String id) async {
    final habit = _habits.firstWhere((h) => h.id == id);
    final updatedHabit = habit.copyWith(completed: !habit.completed);
    await updateHabit(updatedHabit);
  }

  // Tamamlanan alışkanlık sayısı
  int get completedHabitsCount => _habits.where((h) => h.completed).length;

  // Toplam alışkanlık sayısı
  int get totalHabitsCount => _habits.length;

  // Tamamlanma yüzdesi
  double get completionPercentage {
    if (_habits.isEmpty) return 0.0;
    return (completedHabitsCount / totalHabitsCount) * 100;
  }
}
