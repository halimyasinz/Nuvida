import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  final List<Map<String, dynamic>> _moodEntries = [];
  String _selectedMood = '😊';
  String _selectedNote = '';
  DateTime _selectedDate = DateTime.now();

  final Map<String, String> _moodOptions = {
    '😊': 'Mutlu',
    '😄': 'Çok Mutlu',
    '😌': 'Sakin',
    '😐': 'Nötr',
    '😔': 'Üzgün',
    '😢': 'Çok Üzgün',
    '😤': 'Stresli',
    '😴': 'Yorgun',
    '🤔': 'Düşünceli',
    '😎': 'Rahat',
  };

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    // Örnek veri yükle (gerçek uygulamada Hive'dan gelecek)
    final now = DateTime.now();
    _moodEntries.addAll([
      {
        'date': DateTime(now.year, now.month, now.day - 2),
        'mood': '😊',
        'note': 'Güzel bir gündü',
      },
      {
        'date': DateTime(now.year, now.month, now.day - 1),
        'mood': '😌',
        'note': 'Sakin ve huzurlu',
      },
      {
        'date': now,
        'mood': '😄',
        'note': 'Harika bir gün!',
      },
    ]);
  }

  void _addMoodEntry() {
    if (_selectedMood.isNotEmpty) {
      setState(() {
        _moodEntries.add({
          'date': _selectedDate,
          'mood': _selectedMood,
          'note': _selectedNote.trim(),
        });
      });

      // Form'u temizle
      _selectedNote = '';
      _selectedDate = DateTime.now();
    }
  }

  void _removeMoodEntry(int index) {
    setState(() {
      _moodEntries.removeAt(index);
    });
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getMoodLabel(String emoji) {
    return _moodOptions[emoji] ?? 'Bilinmeyen';
  }

  Color _getMoodColor(String emoji) {
    switch (emoji) {
      case '😊':
      case '😄':
        return AppTheme.lowRisk; // Yeşil - pozitif
      case '😌':
      case '😎':
        return AppTheme.mediumRisk; // Turuncu - nötr-pozitif
      case '😐':
      case '🤔':
        return AppTheme.textSecondary; // Gri - nötr
      case '😔':
      case '😢':
      case '😤':
      case '😴':
        return AppTheme.highRisk; // Kırmızı - negatif
      default:
        return AppTheme.textSecondary;
    }
  }

  List<Map<String, dynamic>> _getMoodEntriesForDate(DateTime date) {
    return _moodEntries.where((entry) {
      final entryDate = entry['date'] as DateTime;
      return entryDate.year == date.year &&
          entryDate.month == date.month &&
          entryDate.day == date.day;
    }).toList();
  }

  Map<String, dynamic>? _getTodayMood() {
    final today = DateTime.now();
    final todayEntries = _getMoodEntriesForDate(today);
    if (todayEntries.isNotEmpty) {
      return todayEntries.last; // En son giriş
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final todayMood = _getTodayMood();
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mood Takibi",
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    "Günlük ruh halini takip et ve notlarını kaydet",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // Mood Selection Form
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bugünkü Ruh Halin",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  
                  // Mood Selection
                  Wrap(
                    spacing: AppTheme.spacingS,
                    runSpacing: AppTheme.spacingS,
                    children: _moodOptions.entries.map((entry) {
                      final isSelected = _selectedMood == entry.key;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMood = entry.key;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppTheme.spacingM),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppTheme.primaryPurple 
                                : AppTheme.lightPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            border: Border.all(
                              color: isSelected 
                                  ? AppTheme.primaryPurple 
                                  : AppTheme.primaryPurple.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: AppTheme.spacingS),
                              Text(
                                entry.value,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingM),
                  
                  // Date Selection
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      TextButton(
                        onPressed: _selectDate,
                        child: Text(
                          '${_selectedDate.day.toString().padLeft(2, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.year}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacingM),
                  
                  // Note Input
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _selectedNote = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Not (Opsiyonel)',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    enableSuggestions: true,
                    autocorrect: true,
                  ),
                  
                  const SizedBox(height: AppTheme.spacingM),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addMoodEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingM,
                        ),
                      ),
                      child: Text(
                        'Ekle',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.cardBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),
            
            // Mood History
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mood Geçmişi",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingM),
                  
                  if (_moodEntries.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mood_outlined,
                            size: 64,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          Text(
                            'Henüz mood eklenmemiş',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          Text(
                            'İlk mood\'unu eklemek için yukarıdaki formu kullan',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ..._moodEntries.map((entry) {
                      final entryDate = entry['date'] as DateTime;
                      final isToday = entryDate.year == DateTime.now().year &&
                          entryDate.month == DateTime.now().month &&
                          entryDate.day == DateTime.now().day;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppTheme.lightPurple.withOpacity(0.2)
                              : AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                          border: Border.all(
                            color: isToday
                                ? AppTheme.primaryPurple.withOpacity(0.3)
                                : AppTheme.divider,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(AppTheme.spacingS),
                            decoration: BoxDecoration(
                              color: _getMoodColor(entry['mood']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusS),
                            ),
                            child: Text(
                              entry['mood'],
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                _getMoodLabel(entry['mood']),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (isToday) ...[
                                const SizedBox(width: AppTheme.spacingS),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacingS,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryPurple,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                                  ),
                                  child: Text(
                                    'Bugün',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppTheme.cardBackground,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entryDate.day.toString().padLeft(2, '0')}-${entryDate.month.toString().padLeft(2, '0')}-${entryDate.year}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              if (entry['note'] != null && entry['note'].isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  entry['note'],
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () => _removeMoodEntry(_moodEntries.indexOf(entry)),
                            icon: Icon(
                              Icons.delete,
                              color: AppTheme.highRisk,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
