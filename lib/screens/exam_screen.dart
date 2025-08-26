import 'package:flutter/material.dart';
import '../models/exam.dart';
import '../services/hive_service.dart';
import '../services/risk_service.dart';
import '../widgets/risk_badge.dart';
import '../theme/app_theme.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  List<Exam> _exams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final exams = HiveService.getAllExams();
      setState(() {
        _exams = exams;
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
               'Sınavlar yüklenirken hata oluştu: $e',
               style: Theme.of(context).textTheme.bodyMedium,
             ),
          ),
        );
      }
    }
  }

  void _addExam() {
    showDialog(
      context: context,
      builder: (context) => _AddExamDialog(
        onExamAdded: (exam) async {
          try {
            // Hive'a kaydet
            await HiveService.addExam(exam);
            
            // Local state'i güncelle
            setState(() {
              _exams.add(exam);
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                               content: Text(
               'Sınav başarıyla eklendi',
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
               'Sınav eklenirken hata oluştu: $e',
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

  Future<void> _deleteExam(String id) async {
    try {
      // Hive'dan sil
      await HiveService.deleteExam(id);
      
      // Local state'i güncelle
      setState(() {
        _exams.removeWhere((exam) => exam.id == id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sınav silindi',
              style: Theme.of(context).textTheme.bodyMedium,
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
              'Sınav silinirken hata oluştu: $e',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }
    }
  }

  Color _getRiskColor(int daysUntil) {
    if (daysUntil <= 7) return AppTheme.highRisk;
    if (daysUntil <= 14) return AppTheme.mediumRisk;
    return AppTheme.lowRisk;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                        Text(
            "Sınav Takvimi",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: IconButton(
                  onPressed: _addExam,
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            "${_exams.length} sınav bulundu",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
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
                    'Sınavlar yükleniyor...',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            )
                : _exams.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                                                  Icon(
                                  Icons.event_note,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                      const SizedBox(height: AppTheme.spacingM),
                    Text(
                    'Henüz sınav eklenmemiş',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'İlk sınavını eklemek için + butonuna tıkla',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _exams.length,
              itemBuilder: (context, index) {
                final exam = _exams[index];
                final daysUntil = exam.dateTime.difference(DateTime.now()).inDays;
                final isUpcoming = daysUntil >= 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    boxShadow: AppTheme.cardShadow,
                    border: Border(
                      left: BorderSide(
                        color: _getRiskColor(daysUntil),
                        width: 4,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                exam.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Risk Badge
                            RiskBadge(
                              riskLevel: RiskService.compute(
                                examDate: exam.dateTime,
                                goalProgress: 0, // TODO: İleride hedef eşleştirmesi yapılacak
                                habitStreak: 0, // TODO: İleride alışkanlık eşleştirmesi yapılacak
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Text(
                          exam.courseName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
                              "${exam.dateTime.day.toString().padLeft(2, '0')}-${exam.dateTime.month.toString().padLeft(2, '0')}-${exam.dateTime.year}",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingS),
                            Text(
                              "•",
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingS),
                            Text(
                              "${exam.dateTime.hour.toString().padLeft(2, '0')}:${exam.dateTime.minute.toString().padLeft(2, '0')}",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: AppTheme.spacingS),
                            Text(
                              exam.location,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (exam.note != null) ...[
                          const SizedBox(height: AppTheme.spacingS),
                          Row(
                            children: [
                              Icon(
                                Icons.note,
                                size: 16,
                                color: AppTheme.mediumRisk,
                              ),
                              const SizedBox(width: AppTheme.spacingS),
                              Expanded(
                                child: Text(
                                  exam.note!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.mediumRisk,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppTheme.spacingS),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingS,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getRiskColor(daysUntil).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                              ),
                              child: Text(
                                daysUntil == 0
                                    ? 'Bugün!'
                                    : daysUntil == 1
                                        ? 'Yarın!'
                                        : '$daysUntil gün kaldı',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: _getRiskColor(daysUntil),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                size: 20,
                                color: AppTheme.highRisk,
                              ),
                              onPressed: () => _deleteExam(exam.id),
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
}

class _AddExamDialog extends StatefulWidget {
  final Function(Exam) onExamAdded;

  const _AddExamDialog({required this.onExamAdded});

  @override
  State<_AddExamDialog> createState() => _AddExamDialogState();
}

class _AddExamDialogState extends State<_AddExamDialog> {
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
             title: Text(
         'Yeni Sınav Ekle',
         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
           fontWeight: FontWeight.bold,
         ),
       ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                       TextField(
             controller: _titleController,
             decoration: InputDecoration(
               labelText: 'Sınav Adı',
               border: const OutlineInputBorder(),
               labelStyle: Theme.of(context).textTheme.bodyMedium,
             ),
             keyboardType: TextInputType.name,
             textInputAction: TextInputAction.next,
             enableSuggestions: true,
             autocorrect: true,
           ),
            const SizedBox(height: 16),
                       TextField(
             controller: _courseController,
             decoration: InputDecoration(
               labelText: 'Ders Adı',
               border: const OutlineInputBorder(),
               labelStyle: Theme.of(context).textTheme.bodyMedium,
             ),
             keyboardType: TextInputType.name,
             textInputAction: TextInputAction.next,
             enableSuggestions: true,
             autocorrect: true,
           ),
            const SizedBox(height: 16),
                       TextField(
             controller: _locationController,
             decoration: InputDecoration(
               labelText: 'Sınav Yeri',
               border: const OutlineInputBorder(),
               labelStyle: Theme.of(context).textTheme.bodyMedium,
               hintText: 'D301, Lab A, vb.',
             ),
             keyboardType: TextInputType.name,
             textInputAction: TextInputAction.next,
             enableSuggestions: true,
             autocorrect: true,
           ),
            const SizedBox(height: 16),
                       TextField(
             controller: _noteController,
             decoration: InputDecoration(
               labelText: 'Notlar (Opsiyonel)',
               border: const OutlineInputBorder(),
               labelStyle: Theme.of(context).textTheme.bodyMedium,
               hintText: 'Örn: Formül kağıdı getir',
             ),
             maxLines: 2,
             keyboardType: TextInputType.multiline,
             textInputAction: TextInputAction.newline,
             enableSuggestions: true,
             autocorrect: true,
           ),
            const SizedBox(height: 16),
            ListTile(
                             title: Text(
                 'Sınav Tarihi',
                 style: Theme.of(context).textTheme.bodyMedium,
               ),
                             subtitle: Text(
                 '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                 style: Theme.of(context).textTheme.bodySmall,
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
            ListTile(
                             title: Text(
                 'Sınav Saati',
                 style: Theme.of(context).textTheme.bodyMedium,
               ),
                             subtitle: Text(
                 _selectedTime.format(context),
                 style: Theme.of(context).textTheme.bodySmall,
               ),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = time;
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
           style: Theme.of(context).textTheme.bodyMedium,
         ),
        ),
        ElevatedButton(
          onPressed: _saveExam,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.highRisk,
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

  void _saveExam() {
    final title = _titleController.text.trim();
    final courseName = _courseController.text.trim();
    final location = _locationController.text.trim();
    final note = _noteController.text.trim();

    if (title.isEmpty || courseName.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
                     content: Text(
             'Başlık, ders adı ve yer zorunludur',
             style: Theme.of(context).textTheme.bodyMedium,
           ),
        ),
      );
      return;
    }

    final exam = Exam(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      courseName: courseName,
      dateTime: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      location: location,
      note: note.isEmpty ? null : note,
      createdAt: DateTime.now(),
    );

    widget.onExamAdded(exam);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}

