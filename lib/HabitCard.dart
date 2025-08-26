import 'package:flutter/material.dart';

class HabitCard extends StatefulWidget {
  final String title;

  const HabitCard({super.key, required this.title});

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool isCompleted = false;

  void toggleCompleted() {
    setState(() {
      isCompleted = !isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleCompleted,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isCompleted ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    decoration:
                    isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16)
            ],
          ),
        ),
      ),
    );
  }
}
