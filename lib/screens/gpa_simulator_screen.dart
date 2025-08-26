import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GPASimulatorScreen extends StatefulWidget {
  const GPASimulatorScreen({super.key});

  @override
  State<GPASimulatorScreen> createState() => _GPASimulatorScreenState();
}

class _GPASimulatorScreenState extends State<GPASimulatorScreen> {
  final List<Map<String, dynamic>> _courses = [];
  final _formKey = GlobalKey<FormState>();
  final _courseNameController = TextEditingController();
  final _creditController = TextEditingController();
  String _selectedGrade = 'AA';
  double _currentGPA = 0.0;
  int _totalCredits = 0;

  final Map<String, double> _gradeValues = {
    'AA': 4.0,
    'BA': 3.5,
    'BB': 3.0,
    'CB': 2.5,
    'CC': 2.0,
    'DC': 1.5,
    'DD': 1.0,
    'FF': 0.0,
  };

  @override
  void dispose() {
    _courseNameController.dispose();
    _creditController.dispose();
    super.dispose();
  }

  void _addCourse() {
    if (_formKey.currentState!.validate()) {
      final courseName = _courseNameController.text.trim();
      final credits = int.parse(_creditController.text.trim());
      final grade = _selectedGrade;

      setState(() {
        _courses.add({
          'name': courseName,
          'credits': credits,
          'grade': grade,
        });
        _calculateGPA();
      });

      _courseNameController.clear();
      _creditController.clear();
      _selectedGrade = 'AA';
    }
  }

  void _removeCourse(int index) {
    setState(() {
      _courses.removeAt(index);
      _calculateGPA();
    });
  }

  void _calculateGPA() {
    if (_courses.isEmpty) {
      setState(() {
        _currentGPA = 0.0;
        _totalCredits = 0;
      });
      return;
    }

    double totalPoints = 0;
    int totalCredits = 0;

    for (final course in _courses) {
      final credits = course['credits'] as int;
      final grade = course['grade'] as String;
      final gradeValue = _gradeValues[grade]!;

      totalPoints += credits * gradeValue;
      totalCredits += credits;
    }

    setState(() {
      _currentGPA = totalPoints / totalCredits;
      _totalCredits = totalCredits;
    });
  }

  void _clearAll() {
    setState(() {
      _courses.clear();
      _currentGPA = 0.0;
      _totalCredits = 0;
    });
  }

  String _getGPALetter(double gpa) {
    if (gpa >= 3.5) return 'AA';
    if (gpa >= 3.0) return 'BA';
    if (gpa >= 2.5) return 'BB';
    if (gpa >= 2.0) return 'CB';
    if (gpa >= 1.5) return 'CC';
    if (gpa >= 1.0) return 'DC';
    return 'FF';
  }

  Color _getGPAColor(double gpa) {
    if (gpa >= 3.5) return AppTheme.lowRisk;
    if (gpa >= 3.0) return AppTheme.mediumRisk;
    if (gpa >= 2.0) return AppTheme.highRisk;
    return AppTheme.highRisk;
  }

  @override
  Widget build(BuildContext context) {
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
                    "GPA Simülatörü",
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    "Ders notlarını gir ve ortalamanı hesapla",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // GPA Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  Text(
                    "Mevcut GPA",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildGPADisplay('GPA', _currentGPA.toStringAsFixed(2)),
                      _buildGPADisplay('Harf', _getGPALetter(_currentGPA)),
                      _buildGPADisplay('Kredi', '$_totalCredits'),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.textLight.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (_currentGPA / 4.0).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getGPAColor(_currentGPA),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Add Course Form
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ders Ekle",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    
                    // Course Name
                    TextFormField(
                      controller: _courseNameController,
                      decoration: InputDecoration(
                        labelText: 'Ders Adı',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        prefixIcon: Icon(Icons.book, color: AppTheme.primaryPurple),
                      ),
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      enableSuggestions: true,
                      autocorrect: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ders adı gerekli';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppTheme.spacingM),
                    
                    Row(
                      children: [
                        // Credits
                        Expanded(
                          child: TextFormField(
                            controller: _creditController,
                            decoration: InputDecoration(
                              labelText: 'Kredi',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                              ),
                              prefixIcon: Icon(Icons.credit_score, color: AppTheme.primaryPurple),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Kredi gerekli';
                              }
                              final credits = int.tryParse(value);
                              if (credits == null || credits <= 0) {
                                return 'Geçerli kredi girin';
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        const SizedBox(width: AppTheme.spacingM),
                        
                        // Grade
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedGrade,
                            decoration: InputDecoration(
                              labelText: 'Harf Notu',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                              ),
                              prefixIcon: Icon(Icons.grade, color: AppTheme.primaryPurple),
                            ),
                            items: _gradeValues.keys.map((grade) {
                              return DropdownMenuItem(
                                value: grade,
                                child: Text(grade),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedGrade = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppTheme.spacingM),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addCourse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacingM,
                          ),
                        ),
                        child: Text(
                          'Ders Ekle',
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
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Courses List
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Eklenen Dersler (${_courses.length})",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_courses.isNotEmpty)
                        TextButton(
                          onPressed: _clearAll,
                          child: Text(
                            'Tümünü Temizle',
                            style: TextStyle(color: AppTheme.highRisk),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacingM),
                  
                  if (_courses.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 64,
                              color: AppTheme.textLight,
                            ),
                            const SizedBox(height: AppTheme.spacingM),
                            Text(
                              'Henüz ders eklenmemiş',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingS),
                            Text(
                              'İlk dersini eklemek için yukarıdaki formu kullan',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._courses.map((course) {
                      final index = _courses.indexOf(course);
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                        decoration: BoxDecoration(
                          color: AppTheme.lightPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                          border: Border.all(
                            color: AppTheme.lightPurple.withOpacity(0.3),
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(AppTheme.spacingS),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple,
                              borderRadius: BorderRadius.circular(AppTheme.radiusS),
                            ),
                            child: Text(
                              course['grade'],
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.cardBackground,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            course['name'],
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${course['credits']} kredi',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () => _removeCourse(index),
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

  Widget _buildGPADisplay(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppTheme.primaryPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
