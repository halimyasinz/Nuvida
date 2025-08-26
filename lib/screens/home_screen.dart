import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/habit.dart';
import '../models/course.dart';
import '../services/hive_service.dart';
import '../widgets/daily_brief_card.dart';
import '../theme/app_theme.dart';


class HomeScreen extends StatefulWidget {
  final List<Course>? courses;
  
  const HomeScreen({super.key, this.courses});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final habits = HiveService.getAllHabits();
      setState(() {
        _habits = habits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
                         content: Text(
               'Alışkanlıklar yüklenirken hata oluştu: $e',
               style: Theme.of(context).textTheme.bodyMedium,
             ),
          ),
        );
      }
    }
  }

  void _addHabit() {
    showDialog(
      context: context,
      builder: (context) => _AddHabitDialog(
        onHabitAdded: (habit) async {
          try {
            // Hive'a kaydet
            await HiveService.addHabit(habit);
            
            // Local state'i güncelle
            setState(() {
              _habits.add(habit);
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                               content: Text(
               'Alışkanlık başarıyla eklendi',
               style: Theme.of(context).textTheme.bodyMedium,
             ),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                               content: Text(
               'Alışkanlık eklenirken hata oluştu: $e',
               style: Theme.of(context).textTheme.bodyMedium,
             ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteHabit(int index) async {
    final habit = _habits[index];
    
    try {
      // Hive'dan sil
      await HiveService.deleteHabit(habit.id);
      
      // Local state'i güncelle
      setState(() {
        _habits.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
                         content: Text(
               'Alışkanlık silindi',
               style: Theme.of(context).textTheme.bodyMedium,
             ),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Geri Al',
              onPressed: () async {
                try {
                  await HiveService.addHabit(habit);
                  setState(() {
                    _habits.insert(index, habit);
                  });
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                                           content: Text(
                     'Geri alma başarısız: $e',
                     style: Theme.of(context).textTheme.bodyMedium,
                   ),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
                         content: Text(
               'Alışkanlık silinirken hata oluştu: $e',
               style: Theme.of(context).textTheme.bodyMedium,
             ),
          ),
        );
      }
    }
  }

  Future<void> _toggleHabit(String id) async {
    try {
      final habit = _habits.firstWhere((h) => h.id == id);
      final updatedHabit = habit.copyWith(completed: !habit.completed);
      
      // Hive'a kaydet
      await HiveService.updateHabit(updatedHabit);
      
      // Local state'i güncelle
      final index = _habits.indexOf(habit);
      _habits[index] = updatedHabit;
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
                         content: Text(
               'Alışkanlık güncellenirken hata oluştu: $e',
               style: Theme.of(context).textTheme.bodyMedium,
             ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.spacingM),
            // Daily Brief Card
            DailyBriefCard(courses: widget.courses),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              "Bugünkü Yapılacaklar",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Expanded(
                              child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppTheme.primaryPurple,
                            ),
                            const SizedBox(height: AppTheme.spacingM),
                            Text(
                              'Alışkanlıklar yükleniyor...',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _habits.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                const SizedBox(height: AppTheme.spacingM),
                                Text(
                                  'Henüz alışkanlık eklenmemiş',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacingS),
                                Text(
                                  'İlk alışkanlığını eklemek için + butonuna tıkla',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          )
                      : ListView.builder(
                          itemCount: _habits.length,
                          itemBuilder: (context, index) {
                            return Slidable(
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) => _deleteHabit(index),
                                    backgroundColor: AppTheme.highRisk,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Sil',
                                  ),
                                ],
                              ),
                              child: HabitCard(
                                title: _habits[index].title,
                                completed: _habits[index].completed,
                                onTap: () => _toggleHabit(_habits[index].id),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryPurple,
        onPressed: _addHabit,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _AddHabitDialog extends StatefulWidget {
  final Function(Habit) onHabitAdded;

  const _AddHabitDialog({required this.onHabitAdded});

  @override
  State<_AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<_AddHabitDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
             title: Text(
         'Yeni Alışkanlık Ekle',
         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
           fontWeight: FontWeight.bold,
         ),
       ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
                     TextField(
             controller: _titleController,
             decoration: InputDecoration(
               labelText: 'Alışkanlık Adı',
               border: const OutlineInputBorder(),
               labelStyle: Theme.of(context).textTheme.bodyMedium,
             ),
             keyboardType: TextInputType.text,
             textInputAction: TextInputAction.next,
             enableSuggestions: true,
             autocorrect: true,
             textCapitalization: TextCapitalization.sentences,
           ),
          const SizedBox(height: 16),
                     TextField(
             controller: _descriptionController,
             decoration: InputDecoration(
               labelText: 'Açıklama (Opsiyonel)',
               border: const OutlineInputBorder(),
               labelStyle: Theme.of(context).textTheme.bodyMedium,
             ),
             maxLines: 2,
             keyboardType: TextInputType.multiline,
             textInputAction: TextInputAction.newline,
             enableSuggestions: true,
             autocorrect: true,
             textCapitalization: TextCapitalization.sentences,
           ),
          const SizedBox(height: 16),
                     TextField(
             controller: _categoryController,
             decoration: InputDecoration(
               labelText: 'Kategori (Opsiyonel)',
               border: const OutlineInputBorder(),
               labelStyle: Theme.of(context).textTheme.bodyMedium,
               hintText: 'örn: Sağlık, Çalışma, Spor',
             ),
             keyboardType: TextInputType.text,
             textInputAction: TextInputAction.done,
             enableSuggestions: true,
             autocorrect: true,
             textCapitalization: TextCapitalization.words,
           ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
                   child: Text(
           'İptal',
           style: Theme.of(context).textTheme.bodyMedium,
         ),
        ),
        ElevatedButton(
          onPressed: _saveHabit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.success,
          ),
                     child: Text(
             'Ekle',
             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
               color: Colors.white,
             ),
           ),
        ),
      ],
    );
  }

  void _saveHabit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final category = _categoryController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
                       content: Text(
               'Alışkanlık adı zorunludur',
               style: Theme.of(context).textTheme.bodyMedium,
             ),
        ),
      );
      return;
    }

    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description.isEmpty ? null : description,
      category: category.isEmpty ? null : category,
      completed: false,
      createdAt: DateTime.now(),
    );

    widget.onHabitAdded(habit);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}

class HabitCard extends StatelessWidget {
  final String title;
  final bool completed;
  final VoidCallback onTap;

  const HabitCard({
    super.key,
    required this.title,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? AppTheme.success : AppTheme.textLight,
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              decoration: completed
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              fontWeight: completed ? FontWeight.normal : FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}
