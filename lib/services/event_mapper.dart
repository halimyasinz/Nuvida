import '../models/course.dart';
import '../models/exam.dart';
// import '../models/event.dart'; // TODO: Event model hazır olduktan sonra aktif et

class EventMapper {
  /// Mevcut Course verilerinden Event listesi üretir - TODO: Event model hazır olduktan sonra aktif et
  /*
  static List<Event> coursesToEvents(List<Course> courses) {
    final events = <Event>[];
    final now = DateTime.now();
    
    for (final course in courses) {
      // Bu hafta için event oluştur
      final courseDate = _getNextWeekday(course.day, now);
      if (courseDate != null) {
        final startTime = _parseTime(course.startTime);
        final endTime = _parseTime(course.endTime);
        
        final start = DateTime(
          courseDate.year,
          courseDate.month,
          courseDate.day,
          startTime.hour,
          startTime.minute,
        );
        
        final end = DateTime(
          courseDate.year,
          courseDate.month,
          courseDate.day,
          endTime.hour,
          endTime.minute,
        );
        
        events.add(Event(
          id: 'course_${course.id}',
          type: EventType.lesson,
          title: course.name,
          start: start,
          end: end,
          location: course.location,
          note: 'Öğretmen: ${course.instructor}',
          tags: ['ders', course.day.toLowerCase()],
        ));
      }
    }
    
    return events;
  }
  */
  
  /// Mevcut Exam verilerinden Event listesi üretir - TODO: Event model hazır olduktan sonra aktif et
  /*
  static List<Event> examsToEvents(List<Exam> exams) {
    return exams.map((exam) => Event(
      id: 'exam_${exam.id}',
      type: EventType.exam,
      title: exam.title,
      start: exam.dateTime,
      end: exam.dateTime.add(const Duration(hours: 2)), // Varsayılan 2 saat
      location: exam.location,
      note: exam.note,
      tags: ['sınav', exam.courseName.toLowerCase()],
    )).toList();
  }
  */
  
  /// Tüm mevcut verilerden Event listesi üretir - TODO: Event model hazır olduktan sonra aktif et
  /*
  static List<Event> allToEvents({
    required List<Course> courses,
    required List<Exam> exams,
  }) {
    final courseEvents = coursesToEvents(courses);
    final examEvents = examsToEvents(exams);
    
    return [...courseEvents, ...examEvents];
  }
  */
  
  /// Belirli bir gün için event'leri filtreler - TODO: Event model hazır olduktan sonra aktif et
  /*
  static List<Event> filterByDate(List<Event> events, DateTime date) {
    return events.where((event) => _isSameDay(event.start, date)).toList();
  }
  
  /// Belirli bir tür için event'leri filtreler
  static List<Event> filterByType(List<Event> events, List<EventType> types) {
    return events.where((event) => types.contains(event.type)).toList();
  }
  */
  
  /// Yardımcı metodlar
  static DateTime? _getNextWeekday(String dayName, DateTime fromDate) {
    final dayMap = {
      'Pazartesi': 1,
      'Salı': 2,
      'Çarşamba': 3,
      'Perşembe': 4,
      'Cuma': 5,
      'Cumartesi': 6,
      'Pazar': 7,
    };
    
    final targetWeekday = dayMap[dayName];
    if (targetWeekday == null) return null;
    
    final currentWeekday = fromDate.weekday;
    int daysToAdd = targetWeekday - currentWeekday;
    
    if (daysToAdd <= 0) {
      daysToAdd += 7; // Gelecek haftaya
    }
    
    return fromDate.add(Duration(days: daysToAdd));
  }
  
  static DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
    
    return DateTime(2024, 1, 1, hour, minute);
  }
  
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
