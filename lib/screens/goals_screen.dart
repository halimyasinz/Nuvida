import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/goal.dart';
import '../services/hive_service.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<Goal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final goals = HiveService.getAllGoals();
      setState(() {
        _goals = goals;
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
              'Hedefler yüklenirken hata oluştu: $e',
              style: GoogleFonts.notoSans(),
            ),
          ),
        );
      }
    }
  }

  void _addGoal() {
    showDialog(
      context: context,
      builder: (context) => _AddGoalDialog(
        onGoalAdded: (goal) async {
          try {
            // Hive'a kaydet
            await HiveService.addGoal(goal);
            
            // Local state'i güncelle
            setState(() {
              _goals.add(goal);
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Hedef başarıyla eklendi',
                    style: GoogleFonts.notoSans(),
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
                    style: GoogleFonts.notoSans(),
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _editGoal(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => _AddGoalDialog(
        goal: goal,
        onGoalAdded: (editedGoal) async {
          try {
            // Hive'a kaydet
            await HiveService.updateGoal(editedGoal);
            
            // Local state'i güncelle
            setState(() {
              final index = _goals.indexWhere((g) => g.id == goal.id);
              if (index != -1) {
                _goals[index] = editedGoal;
              }
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Hedef başarıyla güncellendi',
                    style: GoogleFonts.notoSans(),
                  ),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Hedef güncellenirken hata oluştu: $e',
                    style: GoogleFonts.notoSans(),
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteGoal(String id) async {
    try {
      // Hive'dan sil
      await HiveService.deleteGoal(id);
      
      // Local state'i güncelle
      setState(() {
        _goals.removeWhere((goal) => goal.id == id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hedef silindi',
              style: GoogleFonts.notoSans(),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hedef silinirken hata oluştu: $e',
              style: GoogleFonts.notoSans(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _toggleGoalCompletion(String id) async {
    try {
      final goal = _goals.firstWhere((g) => g.id == id);
      final updatedGoal = goal.copyWith(isCompleted: !goal.isCompleted);
      
      // Hive'a kaydet
      await HiveService.updateGoal(updatedGoal);
      
      // Local state'i güncelle
      final index = _goals.indexOf(goal);
      _goals[index] = updatedGoal;
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hedef güncellenirken hata oluştu: $e',
              style: GoogleFonts.notoSans(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _updateProgress(String id, int progress) async {
    try {
      final goal = _goals.firstWhere((g) => g.id == id);
      final updatedGoal = goal.copyWith(progress: progress);
      
      // Hive'a kaydet
      await HiveService.updateGoal(updatedGoal);
      
      // Local state'i güncelle
      final index = _goals.indexOf(goal);
      _goals[index] = updatedGoal;
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'İlerleme güncellenirken hata oluştu: $e',
              style: GoogleFonts.notoSans(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedGoals = _goals.where((g) => g.isCompleted).length;
    final totalGoals = _goals.length;
    final overallProgress = totalGoals > 0 ? (completedGoals / totalGoals * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Hedeflerim",
                style: GoogleFonts.notoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _addGoal,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress Overview Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Genel İlerleme",
                        style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        "$overallProgress%",
                        style: GoogleFonts.notoSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: overallProgress / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$completedGoals / $totalGoals hedef tamamlandı",
                    style: GoogleFonts.notoSans(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text(
            "${_goals.length} hedef bulundu",
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: _isLoading
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Hedefler yükleniyor...',
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : _goals.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flag,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz hedef belirlenmemiş',
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İlk hedefini belirlemek için + butonuna tıkla',
                    style: GoogleFonts.notoSans(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final daysUntil = goal.targetDate.difference(DateTime.now()).inDays;
                final isOverdue = daysUntil < 0 && !goal.isCompleted;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  color: goal.isCompleted
                      ? Colors.grey.shade50
                      : isOverdue
                      ? Colors.red.shade50
                      : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row with icon, title, and completion status
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: goal.isCompleted
                                  ? Colors.green.shade100
                                  : isOverdue
                                  ? Colors.red.shade100
                                  : Colors.blue.shade100,
                              child: Icon(
                                goal.isCompleted
                                    ? Icons.check
                                    : isOverdue
                                    ? Icons.warning
                                    : Icons.flag,
                                color: goal.isCompleted
                                    ? Colors.green.shade700
                                    : isOverdue
                                    ? Colors.red.shade700
                                    : Colors.blue.shade700,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal.title,
                                    style: GoogleFonts.notoSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      decoration: goal.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: goal.isCompleted
                                          ? Colors.grey.shade600
                                          : null,
                                    ),
                                  ),
                                  if (goal.isCompleted)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green.shade700,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Description
                        Text(
                          goal.description,
                          style: GoogleFonts.notoSans(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Category and overdue badges
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                goal.category,
                                style: GoogleFonts.notoSans(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isOverdue) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Gecikmiş',
                                  style: GoogleFonts.notoSans(
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Progress Bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'İlerleme',
                                  style: GoogleFonts.notoSans(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${goal.progress}%',
                                  style: GoogleFonts.notoSans(
                                    color: Colors.green.shade700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: goal.progress / 100,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  goal.progress >= 100
                                      ? Colors.green.shade700
                                      : Colors.blue.shade700
                              ),
                              minHeight: 6,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Date and days remaining
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Hedef Tarih: ${_formatDate(goal.targetDate)}',
                                style: GoogleFonts.notoSans(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Days remaining indicator
                        if (!goal.isCompleted && !isOverdue) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: daysUntil <= 7
                                  ? Colors.red.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              daysUntil == 0
                                  ? 'Bugün!'
                                  : daysUntil == 1
                                  ? 'Yarın!'
                                  : '$daysUntil gün kaldı',
                              style: GoogleFonts.notoSans(
                                color: daysUntil <= 7
                                    ? Colors.red.shade700
                                    : Colors.orange.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!goal.isCompleted) ...[
                              TextButton.icon(
                                onPressed: () => _showProgressDialog(goal),
                                icon: Icon(
                                  Icons.trending_up,
                                  color: Colors.blue.shade700,
                                  size: 18,
                                ),
                                label: Text(
                                  'İlerleme',
                                  style: GoogleFonts.notoSans(
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () => _toggleGoalCompletion(goal.id),
                                icon: Icon(
                                  Icons.check,
                                  color: Colors.green.shade700,
                                  size: 18,
                                ),
                                label: Text(
                                  'Tamamla',
                                  style: GoogleFonts.notoSans(
                                    color: Colors.green.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            TextButton.icon(
                              onPressed: () => _editGoal(goal),
                              icon: Icon(
                                Icons.edit,
                                color: Colors.grey.shade700,
                                size: 18,
                              ),
                              label: Text(
                                'Düzenle',
                                style: GoogleFonts.notoSans(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _deleteGoal(goal.id),
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red.shade700,
                                size: 18,
                              ),
                              label: Text(
                                'Sil',
                                style: GoogleFonts.notoSans(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showProgressDialog(Goal goal) {
    int currentProgress = goal.progress;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'İlerleme Güncelle',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${goal.title} için ilerleme yüzdesi:',
              style: GoogleFonts.notoSans(),
            ),
            const SizedBox(height: 16),
            Slider(
              value: currentProgress.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              label: '$currentProgress%',
              onChanged: (value) {
                setState(() {
                  currentProgress = value.round();
                });
              },
            ),
            Text(
              '$currentProgress%',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: GoogleFonts.notoSans(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _updateProgress(goal.id, currentProgress);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: Text(
              'Güncelle',
              style: GoogleFonts.notoSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _AddGoalDialog extends StatefulWidget {
  final Goal? goal;
  final Function(Goal) onGoalAdded;

  const _AddGoalDialog({
    this.goal,
    required this.onGoalAdded,
  });

  @override
  State<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<_AddGoalDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _isEditing = true;
      _titleController.text = widget.goal!.title;
      _descriptionController.text = widget.goal!.description;
      _categoryController.text = widget.goal!.category;
      _selectedDate = widget.goal!.targetDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEditing ? 'Hedefi Düzenle' : 'Yeni Hedef Ekle',
        style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Hedef Başlığı',
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.notoSans(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Açıklama',
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.notoSans(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Kategori',
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.notoSans(),
                hintText: 'örn: Akademik, Sağlık, Proje',
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                'Hedef Tarih',
                style: GoogleFonts.notoSans(),
              ),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: GoogleFonts.notoSans(),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'İptal',
            style: GoogleFonts.notoSans(),
          ),
        ),
        ElevatedButton(
          onPressed: _saveGoal,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
          ),
          child: Text(
            _isEditing ? 'Güncelle' : 'Ekle',
            style: GoogleFonts.notoSans(color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _saveGoal() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final category = _categoryController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Başlık ve açıklama zorunludur',
            style: GoogleFonts.notoSans(),
          ),
        ),
      );
      return;
    }

    final goal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      targetDate: _selectedDate,
      createdAt: DateTime.now(),
      category: category,
      progress: 0,
      milestones: [],
    );

    widget.onGoalAdded(goal);
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
