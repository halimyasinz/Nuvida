import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/goal.dart';
import '../models/habit.dart';
import '../services/hive_service.dart';
import '../theme/app_theme.dart';

class GoalsAndHabitsScreen extends StatefulWidget {
  const GoalsAndHabitsScreen({super.key});

  @override
  State<GoalsAndHabitsScreen> createState() => _GoalsAndHabitsScreenState();
}

class _GoalsAndHabitsScreenState extends State<GoalsAndHabitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Goal> _goals = [];
  List<Habit> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final goals = HiveService.getAllGoals();
      final habits = HiveService.getAllHabits();
      setState(() {
        _goals = goals;
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
              'Veriler yüklenirken hata oluştu: $e',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteGoal(String id) async {
    try {
      await HiveService.deleteGoal(id);
      setState(() {
        _goals.removeWhere((goal) => goal.id == id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hedef silindi',
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
              'Hedef silinirken hata oluştu: $e',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteHabit(int index) async {
    final habit = _habits[index];
    try {
      await HiveService.deleteHabit(habit.id);
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

  void _showAddDialog() {
    if (_tabController.index == 0) {
      _showAddGoalDialog();
    } else {
      _showAddHabitDialog();
    }
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddGoalDialog(
        onGoalAdded: (goal) async {
          try {
            await HiveService.addGoal(goal);
            setState(() {
              _goals.add(goal);
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Hedef başarıyla eklendi',
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
                    'Hedef eklenirken hata oluştu: $e',
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

  void _showAddHabitDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddHabitDialog(
        onHabitAdded: (habit) async {
          try {
            await HiveService.addHabit(habit);
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

  Future<void> _toggleHabit(String id) async {
    try {
      final habit = _habits.firstWhere((h) => h.id == id);
      final updatedHabit = habit.copyWith(completed: !habit.completed);
      await HiveService.updateHabit(updatedHabit);
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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hedefler & Alışkanlıklar",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  "Hedeflerini belirle ve alışkanlıklarını takip et",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.lightPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.cardBackground,
              unselectedLabelColor: AppTheme.textSecondary,
              indicator: BoxDecoration(
                color: AppTheme.primaryPurple,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              tabs: const [
                Tab(text: 'Hedefler'),
                Tab(text: 'Alışkanlıklar'),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGoalsTab(),
                _buildHabitsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryPurple,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildGoalsTab() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryPurple),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Hedefler yükleniyor...',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 64,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Henüz hedef eklenmemiş',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'İlk hedefini eklemek için + butonuna tıkla',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: _goals.length,
      itemBuilder: (context, index) {
        final goal = _goals[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => _deleteGoal(goal.id),
                  backgroundColor: AppTheme.highRisk,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Sil',
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flag,
                        color: AppTheme.primaryPurple,
                        size: 24,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: Text(
                          goal.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (goal.description != null) ...[
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      goal.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppTheme.spacingS),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        goal.targetDate != null
                            ? '${goal.targetDate!.day.toString().padLeft(2, '0')}-${goal.targetDate!.month.toString().padLeft(2, '0')}-${goal.targetDate!.year}'
                            : 'Tarih belirtilmemiş',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  LinearProgressIndicator(
                    value: goal.progress / 100,
                    backgroundColor: AppTheme.textLight.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    '${goal.progress}% tamamlandı',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHabitsTab() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryPurple),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Alışkanlıklar yükleniyor...',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_habits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Henüz alışkanlık eklenmemiş',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'İlk alışkanlığını eklemek için + butonuna tıkla',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: _habits.length,
      itemBuilder: (context, index) {
        final habit = _habits[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Slidable(
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
            child: ListTile(
              leading: GestureDetector(
                onTap: () => _toggleHabit(habit.id),
                child: Icon(
                  habit.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: habit.completed ? AppTheme.lowRisk : AppTheme.textSecondary,
                  size: 28,
                ),
              ),
              title: Text(
                habit.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  decoration: habit.completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: habit.completed ? AppTheme.textSecondary : AppTheme.textPrimary,
                ),
              ),
              subtitle: habit.description != null
                  ? Text(
                      habit.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    )
                  : null,
              trailing: habit.category != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingS,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightPurple,
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Text(
                        habit.category!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _AddGoalDialog extends StatefulWidget {
  final Function(Goal) onGoalAdded;

  const _AddGoalDialog({required this.onGoalAdded});

  @override
  State<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<_AddGoalDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deadlineController = TextEditingController();
  DateTime? _selectedDeadline;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Yeni Hedef Ekle',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Hedef Başlığı',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            enableSuggestions: true,
            autocorrect: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Açıklama',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            enableSuggestions: true,
            autocorrect: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _deadlineController,
            decoration: const InputDecoration(
              labelText: 'Son Tarih (Opsiyonel)',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _selectedDeadline = date;
                  _deadlineController.text = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
                });
              }
            },
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
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPurple,
          ),
          child: Text(
            'Ekle',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    
    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hedef başlığı ve açıklaması zorunludur',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
      return;
    }

    final goal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      targetDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now(),
      isCompleted: false,
      category: 'Genel',
    );

    widget.onGoalAdded(goal);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    super.dispose();
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
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            enableSuggestions: true,
            autocorrect: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Açıklama',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            enableSuggestions: true,
            autocorrect: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _categoryController,
            decoration: InputDecoration(
              labelText: 'Kategori (Opsiyonel)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.done,
            enableSuggestions: true,
            autocorrect: true,
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
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPurple,
          ),
          child: Text(
            'Ekle',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    
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
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
      createdAt: DateTime.now(),
      completed: false,
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
