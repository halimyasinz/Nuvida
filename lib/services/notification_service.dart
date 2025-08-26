import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/course.dart';
import '../models/exam.dart';
import '../models/goal.dart';
import '../models/habit.dart';
import '../models/event.dart';
import '../services/hive_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;

  static Future<void> init() async {
    // Eğer zaten başlatılmışsa, tekrar başlatma
    if (_isInitialized) {
      print('NotificationService zaten başlatılmış');
      return;
    }

    // Timezone'ları başlat
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    
    // Android için kanal oluştur
    const androidChannel = AndroidNotificationChannel(
      'daily_brief',
      'Günlük Özet',
      description: 'Günlük özet bildirimleri',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
    
    _isInitialized = true;
    print('NotificationService başarıyla başlatıldı');
  }

  static Future<void> scheduleDailyBrief() async {
    // Eğer bildirim zaten planlanmışsa, tekrar planlama
    final pendingNotifications = await _notifications.pendingNotificationRequests();
    if (pendingNotifications.any((notification) => notification.id == 0)) {
      print('Günlük özet bildirimi zaten planlanmış');
      return;
    }

    // Her gün 08:00'de bildirim planla
    const androidDetails = AndroidNotificationDetails(
      'daily_brief',
      'Günlük Özet',
      channelDescription: 'Günlük özet bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    try {
      // Exact alarm ile planlamayı dene
      await _notifications.zonedSchedule(
        0, // Unique ID
        'Günlük Özet',
        _generateDailyBriefMessage(),
        _nextInstanceOfEightAM(),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // Exact alarm izni yoksa, inexact alarm kullan
      if (e.toString().contains('exact_alarms_not_permitted')) {
        await _notifications.periodicallyShow(
          0, // Unique ID
          'Günlük Özet',
          _generateDailyBriefMessage(),
          RepeatInterval.daily,
          notificationDetails,
        );
      } else {
        // Diğer hataları yeniden fırlat
        rethrow;
      }
    }
  }

  static String _generateDailyBriefMessage() {
    final today = DateTime.now();
    final todayString = _getDayString(today.weekday);
    
    // Bugünkü verileri al
    final todayCourses = _getTodayCourses(todayString);
    final todayExams = _getTodayExams(today);
    final todayGoals = _getTodayGoals(today);
    final todayHabits = _getTodayHabits();

    return '📚 ${todayCourses.length} ders • 📝 ${todayExams.length} sınav • 🎯 ${todayGoals.length} hedef • 🔄 ${todayHabits.length} alışkanlık';
  }

  static tz.TZDateTime _nextInstanceOfEightAM() {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // Yardımcı metodlar
  static String _getDayString(int weekday) {
    switch (weekday) {
      case 1:
        return 'Pazartesi';
      case 2:
        return 'Salı';
      case 3:
        return 'Çarşamba';
      case 4:
        return 'Perşembe';
      case 5:
        return 'Cuma';
      case 6:
        return 'Cumartesi';
      case 7:
        return 'Pazar';
      default:
        return 'Pazartesi';
    }
  }

  static List<Course> _getTodayCourses(String day) {
    return HiveService.getAllCourses()
        .where((course) => course.day == day)
        .toList();
  }

  static List<Exam> _getTodayExams(DateTime today) {
    return HiveService.getAllExams()
        .where((exam) => _isSameDay(exam.dateTime, today))
        .toList();
  }

  static List<Goal> _getTodayGoals(DateTime today) {
    return HiveService.getAllGoals()
        .where((goal) => _isSameDay(goal.targetDate, today))
        .toList();
  }

  static List<Habit> _getTodayHabits() {
    // MVP: Tüm alışkanlıkları döndür
    return HiveService.getAllHabits();
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
