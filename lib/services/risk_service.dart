enum RiskLevel { low, medium, high }

class RiskService {
  // weights basit sabitler olabilir
  static RiskLevel compute({
    required DateTime examDate,
    required int goalProgress,   // 0..100 (ilgili hedef bulunamazsa 0 say)
    required int habitStreak,    // 0..∞  (ilgili çalışma alışkanlığı yoksa 0 say)
  }) {
    final daysLeft = examDate.difference(DateTime.now()).inDays;
    int score = 0;
    
    if (daysLeft < 7) score += 3;
    if (goalProgress < 50) score += 3;
    if (habitStreak < 3) score += 2;
    
    if (score >= 7) return RiskLevel.high;
    if (score >= 4) return RiskLevel.medium;
    return RiskLevel.low;
  }
}
