import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/exam.dart';
import '../models/goal.dart';
import '../models/habit.dart';
import '../services/hive_service.dart';
import '../theme/app_theme.dart';

class DailyBriefCard extends StatelessWidget {
  final List<Course>? courses;
  
  const DailyBriefCard({super.key, this.courses});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayString = _getDayString(today.weekday);
    
    // Bugünkü verileri al
    final todayCourses = _getTodayCourses(todayString);
    final todayExams = _getTodayExams(today);
    final todayGoals = _getTodayGoals(today);
    final todayHabits = _getTodayHabits();

    return Card(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      shadowColor: AppTheme.cardShadow.first.color,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppTheme.lightPurple,
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: AppTheme.primaryPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    'Bugün seni neler bekliyor?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            _buildSummaryRow(
              context,
              Icons.book,
              '${todayCourses.length} ders',
              AppTheme.primaryPurple,
            ),
            _buildSummaryRow(
              context,
              Icons.assignment,
              '${todayExams.length} sınav',
              AppTheme.highRisk,
            ),
            _buildSummaryRow(
              context,
              Icons.flag,
              '${todayGoals.length} hedef',
              AppTheme.mediumRisk,
            ),
            _buildSummaryRow(
              context,
              Icons.repeat,
              '${todayHabits.length} alışkanlık',
              AppTheme.lowRisk,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      padding: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayString(int weekday) {
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

  List<Course> _getTodayCourses(String day) {
    // Eğer courses parametresi verilmişse onu kullan, yoksa Hive'dan al
    final allCourses = courses ?? HiveService.getAllCourses();
    
    return allCourses
        .where((course) => course.day == day)
        .toList();
  }

  List<Exam> _getTodayExams(DateTime today) {
    return HiveService.getAllExams()
        .where((exam) => _isSameDay(exam.dateTime, today))
        .toList();
  }

  List<Goal> _getTodayGoals(DateTime today) {
    return HiveService.getAllGoals()
        .where((goal) => _isSameDay(goal.targetDate, today))
        .toList();
  }

  List<Habit> _getTodayHabits() {
    // MVP: Tüm alışkanlıkları döndür, ileride günlük takip eklenebilir
    return HiveService.getAllHabits();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
