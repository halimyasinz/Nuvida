import 'package:flutter/material.dart';
import '../services/risk_service.dart';

class RiskBadge extends StatelessWidget {
  final RiskLevel riskLevel;

  const RiskBadge({
    super.key,
    required this.riskLevel,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;
    String emoji;

    switch (riskLevel) {
      case RiskLevel.low:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        text = 'Düşük';
        emoji = '🟢';
        break;
      case RiskLevel.medium:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        text = 'Orta';
        emoji = '🟡';
        break;
      case RiskLevel.high:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        text = 'Yüksek';
        emoji = '🔴';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
