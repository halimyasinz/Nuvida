import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course.dart';
import '../services/hive_service.dart';

class CoursesScreen extends StatefulWidget {
  final Function(List<Course>)? onCoursesChanged;

  const CoursesScreen({super.key, this.onCoursesChanged});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<Course> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final courses = HiveService.getAllCourses();
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
      
      // Parent'a bildir
      if (widget.onCoursesChanged != null) {
        widget.onCoursesChanged!(_courses);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Dersler yüklenirken hata oluştu: $e',
              style: GoogleFonts.notoSans(),
            ),
          ),
        );
      }
    }
  }

  void _addCourse() {
    showDialog(
      context: context,
      builder: (context) => _AddCourseDialog(
        onCourseAdded: (course) async {
          try {
            // Hive'a kaydet
            await HiveService.addCourse(course);
            
            // Local state'i güncelle
            setState(() {
              _courses.add(course);
            });
            
            // Parent'a bildir
            if (widget.onCoursesChanged != null) {
              widget.onCoursesChanged!(_courses);
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Ders başarıyla eklendi',
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
                    'Ders eklenirken hata oluştu: $e',
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

  Future<void> _deleteCourse(int index) async {
    final course = _courses[index];
    
    try {
      // Hive'dan sil
      await HiveService.deleteCourse(course.id);
      
      // Local state'i güncelle
      setState(() {
        _courses.removeAt(index);
      });
      
      // Parent'a bildir
      if (widget.onCoursesChanged != null) {
        widget.onCoursesChanged!(_courses);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ders silindi',
              style: GoogleFonts.notoSans(),
            ),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Geri Al',
              onPressed: () async {
                try {
                  await HiveService.addCourse(course);
                  setState(() {
                    _courses.insert(index, course);
                  });
                  if (widget.onCoursesChanged != null) {
                    widget.onCoursesChanged!(_courses);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Geri alma başarısız: $e',
                          style: GoogleFonts.notoSans(),
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
              'Ders silinirken hata oluştu: $e',
              style: GoogleFonts.notoSans(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                "Derslerim",
                style: GoogleFonts.notoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _addCourse,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${_courses.length} ders bulundu",
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
                    'Dersler yükleniyor...',
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : _courses.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz ders eklenmemiş',
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İlk dersini eklemek için + butonuna tıkla',
                    style: GoogleFonts.notoSans(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Icon(
                        Icons.school,
                        color: Colors.green.shade700,
                      ),
                    ),
                    title: Text(
                      course.name,
                      style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              course.day,
                              style: GoogleFonts.notoSans(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${course.startTime} - ${course.endTime}",
                              style: GoogleFonts.notoSans(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            // TODO: Implement edit functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Düzenleme özelliği yakında!',
                                  style: GoogleFonts.notoSans(),
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () => _deleteCourse(index),
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

class _AddCourseDialog extends StatefulWidget {
  final Function(Course) onCourseAdded;

  const _AddCourseDialog({required this.onCourseAdded});

  @override
  State<_AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<_AddCourseDialog> {
  final _nameController = TextEditingController();
  final _dayController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _instructorController = TextEditingController();
  final _locationController = TextEditingController();

  final List<String> _days = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Yeni Ders Ekle',
        style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Ders Adı',
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.notoSans(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _dayController.text.isEmpty ? null : _dayController.text,
              decoration: InputDecoration(
                labelText: 'Gün',
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.notoSans(),
              ),
              items: _days.map((day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day, style: GoogleFonts.notoSans()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _dayController.text = value ?? '';
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startTimeController,
                    decoration: InputDecoration(
                      labelText: 'Başlangıç Saati',
                      border: const OutlineInputBorder(),
                      labelStyle: GoogleFonts.notoSans(),
                      hintText: '09:00',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _endTimeController,
                    decoration: InputDecoration(
                      labelText: 'Bitiş Saati',
                      border: const OutlineInputBorder(),
                      labelStyle: GoogleFonts.notoSans(),
                      hintText: '10:30',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _instructorController,
              decoration: InputDecoration(
                labelText: 'Öğretim Üyesi',
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.notoSans(),
                hintText: 'Dr. Ahmet Yılmaz',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Sınıf/Laboratuvar',
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.notoSans(),
                hintText: 'D301 veya Lab A',
              ),
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
          onPressed: _saveCourse,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
          ),
          child: Text(
            'Ekle',
            style: GoogleFonts.notoSans(color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _saveCourse() {
    final name = _nameController.text.trim();
    final day = _dayController.text.trim();
    final startTime = _startTimeController.text.trim();
    final endTime = _endTimeController.text.trim();
    final instructor = _instructorController.text.trim();
    final location = _locationController.text.trim();

    if (name.isEmpty || day.isEmpty || startTime.isEmpty || endTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tüm alanları doldurun',
            style: GoogleFonts.notoSans(),
          ),
        ),
      );
      return;
    }

    final course = Course(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      day: day,
      startTime: startTime,
      endTime: endTime,
      instructor: instructor.isEmpty ? 'Belirtilmemiş' : instructor,
      location: location.isEmpty ? 'Belirtilmemiş' : location,
      createdAt: DateTime.now(),
    );

    widget.onCourseAdded(course);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dayController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _instructorController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
