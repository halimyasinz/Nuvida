import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course.dart'; // Course modelini import et
import '../services/hive_service.dart';
import '../theme/app_theme.dart';

class CourseScheduleScreen extends StatefulWidget {
  final List<Course>? courses;
  final Function(List<Course>)? onCoursesChanged;

  const CourseScheduleScreen({super.key, this.courses, this.onCoursesChanged});

  @override
  State<CourseScheduleScreen> createState() => _CourseScheduleScreenState();
}

class _CourseScheduleScreenState extends State<CourseScheduleScreen> {
  List<Course> _localCourses = [];
  
  @override
  void initState() {
    super.initState();
    // Dersleri yükle
    _loadCourses();
  }
  
  @override
  void didUpdateWidget(CourseScheduleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Eğer widget.courses değiştiyse local state'i güncelle
    if (widget.courses != oldWidget.courses) {
      setState(() {
        _localCourses = widget.courses ?? [];
      });
    }
  }

  Future<void> _loadCourses() async {
    try {
      final courses = HiveService.getAllCourses();
      setState(() {
        _localCourses = courses;
      });
      
      // Parent'a da bildir
      if (widget.onCoursesChanged != null) {
        widget.onCoursesChanged!(courses);
      }
    } catch (e) {
      print('Dersler yüklenirken hata: $e');
    }
  }

  Map<String, List<Course>> _groupCoursesByDay() {
    final Map<String, List<Course>> grouped = {};

    // Local courses listesini kullan
    if (_localCourses.isEmpty) return grouped;

    // Debug: Dersleri yazdır
    print('Toplam ders sayısı: ${_localCourses.length}');
    for (final course in _localCourses) {
      print('Ders: ${course.name}, Gün: ${course.day}');
    }

    // Türkçe gün isimleri
    const Map<String, String> dayTranslations = {
      'Pazartesi': 'Pazartesi',
      'Salı': 'Salı',
      'Çarşamba': 'Çarşamba',
      'Perşembe': 'Perşembe',
      'Cuma': 'Cuma',
      'Cumartesi': 'Cumartesi',
      'Pazar': 'Pazar',
    };

    for (final course in _localCourses) {
      final turkishDay = dayTranslations[course.day] ?? course.day;
      if (grouped[turkishDay] == null) {
        grouped[turkishDay] = [];
      }
      grouped[turkishDay]!.add(course);
    }

    // Debug: Gruplandırılmış dersleri yazdır
    print('Gruplandırılmış dersler:');
    grouped.forEach((day, courses) {
      print('$day: ${courses.length} ders');
      for (final course in courses) {
        print('  - ${course.name}');
      }
    });

    // Günleri sırala
    final List<String> dayOrder = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

    final Map<String, List<Course>> ordered = {};
    for (final day in dayOrder) {
      if (grouped.containsKey(day)) {
        ordered[day] = grouped[day]!;
      }
    }

    return ordered;
  }

  void _addCourse() {
    showDialog(
      context: context,
      builder: (context) => _AddCourseDialog(
        onCourseAdded: (course) async {
          try {
            await HiveService.addCourse(course);
            
            // Local state'e ekle
            setState(() {
              _localCourses.add(course);
            });
            
            // Parent'a da bildir
            if (widget.onCoursesChanged != null) {
              widget.onCoursesChanged!(_localCourses);
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
  
  Future<void> _deleteCourse(Course course) async {
    try {
      await HiveService.deleteCourse(course.id);
      
      // Local state'den sil
      setState(() {
        _localCourses.removeWhere((c) => c.id == course.id);
      });
      
      // Parent'a da bildir
      if (widget.onCoursesChanged != null) {
        widget.onCoursesChanged!(_localCourses);
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
                    _localCourses.add(course);
                  });
                  if (widget.onCoursesChanged != null) {
                    widget.onCoursesChanged!(_localCourses);
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
    final groupedCourses = _groupCoursesByDay();
    final coursesCount = _localCourses.length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ders Programı",
                      style: GoogleFonts.notoSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$coursesCount ders programı bulundu",
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _addCourse,
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (coursesCount == 0)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 64,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz ders programı bulunmuyor',
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Derslerim ekranından ders ekleyerek\nprogramını oluşturabilirsin',
                      style: GoogleFonts.notoSans(
                        color: AppTheme.textLight,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
                         Expanded(
               child: ListView.builder(
                 scrollDirection: Axis.horizontal,
                 itemCount: groupedCourses.length,
                 itemBuilder: (context, index) {
                   final entry = groupedCourses.entries.elementAt(index);
                   final day = entry.key;
                   final dayCourses = entry.value;

                   return Container(
                     width: 200,
                     margin: const EdgeInsets.only(right: 16),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         // Gün başlığı
                         Container(
                           width: double.infinity,
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: AppTheme.primaryPurple,
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: Text(
                             day,
                             style: GoogleFonts.notoSans(
                               color: AppTheme.cardBackground,
                               fontSize: 18,
                               fontWeight: FontWeight.bold,
                             ),
                             textAlign: TextAlign.center,
                           ),
                         ),
                         const SizedBox(height: 12),

                         // O güne ait dersler
                         if (dayCourses.isEmpty)
                           Container(
                             width: double.infinity,
                             padding: const EdgeInsets.all(20),
                             decoration: BoxDecoration(
                               color: AppTheme.divider,
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: Column(
                               children: [
                                 Icon(
                                   Icons.event_busy,
                                   size: 32,
                                   color: AppTheme.textLight,
                                 ),
                                 const SizedBox(height: 8),
                                 Text(
                                   'Ders yok',
                                   style: GoogleFonts.notoSans(
                                     color: AppTheme.textSecondary,
                                     fontSize: 14,
                                   ),
                                 ),
                               ],
                             ),
                           )
                         else
                           Expanded(
                             child: ListView.builder(
                               itemCount: dayCourses.length,
                               itemBuilder: (context, courseIndex) {
                                 final course = dayCourses[courseIndex];
                                 return Container(
                                   margin: const EdgeInsets.only(bottom: 8),
                                   child: Slidable(
                                     endActionPane: ActionPane(
                                       motion: const ScrollMotion(),
                                       children: [
                                         SlidableAction(
                                           onPressed: (_) => _deleteCourse(course),
                                           backgroundColor: AppTheme.highRisk,
                                           foregroundColor: Colors.white,
                                           icon: Icons.delete,
                                           label: 'Sil',
                                         ),
                                       ],
                                     ),
                                     child: Card(
                                       elevation: 2,
                                       child: Padding(
                                         padding: const EdgeInsets.all(12),
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: [
                                             Text(
                                               course.name,
                                               style: GoogleFonts.notoSans(
                                                 fontWeight: FontWeight.bold,
                                                 fontSize: 16,
                                               ),
                                               maxLines: 2,
                                               overflow: TextOverflow.ellipsis,
                                             ),
                                             const SizedBox(height: 8),
                                             Row(
                                               children: [
                                                 Icon(
                                                   Icons.person,
                                                   size: 14,
                                                   color: AppTheme.textSecondary,
                                                 ),
                                                 const SizedBox(width: 4),
                                                 Expanded(
                                                   child: Text(
                                                     course.instructor,
                                                     style: GoogleFonts.notoSans(
                                                       color: AppTheme.textSecondary,
                                                       fontSize: 12,
                                                     ),
                                                     maxLines: 1,
                                                     overflow: TextOverflow.ellipsis,
                                                   ),
                                                 ),
                                               ],
                                             ),
                                             const SizedBox(height: 4),
                                             Row(
                                               children: [
                                                 Icon(
                                                   Icons.access_time,
                                                   size: 14,
                                                   color: AppTheme.textSecondary,
                                                 ),
                                                 const SizedBox(width: 4),
                                                 Text(
                                                   "${course.startTime} - ${course.endTime}",
                                                   style: GoogleFonts.notoSans(
                                                     color: AppTheme.textSecondary,
                                                     fontSize: 12,
                                                   ),
                                                 ),
                                               ],
                                             ),
                                             const SizedBox(height: 4),
                                             Row(
                                               children: [
                                                 Icon(
                                                   Icons.location_on,
                                                   size: 14,
                                                   color: AppTheme.textSecondary,
                                                 ),
                                                 const SizedBox(width: 4),
                                                 Expanded(
                                                   child: Text(
                                                     course.location,
                                                     style: GoogleFonts.notoSans(
                                                       color: AppTheme.textSecondary,
                                                       fontSize: 12,
                                                     ),
                                                     maxLines: 1,
                                                     overflow: TextOverflow.ellipsis,
                                                   ),
                                                 ),
                                               ],
                                             ),
                                           ],
                                         ),
                                       ),
                                     ),
                                   ),
                                 );
                               },
                             ),
                           ),
                       ],
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
  final _instructorController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedDay = 'Pazartesi';
  String _selectedStartTime = '09:00';
  String _selectedEndTime = '10:00';

  final List<String> _days = [
    'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'
  ];

  final List<String> _times = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00', '17:30', '18:00', '18:30', '19:00', '19:30'
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
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              enableSuggestions: true,
              autocorrect: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _instructorController,
              decoration: InputDecoration(
                labelText: 'Öğretmen',
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.notoSans(),
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
                labelText: 'Sınıf',
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.notoSans(),
              ),
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.done,
              enableSuggestions: true,
              autocorrect: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDay,
                    decoration: const InputDecoration(
                      labelText: 'Gün',
                      border: OutlineInputBorder(),
                    ),
                    items: _days.map((day) => DropdownMenuItem(
                      value: day,
                      child: Text(day),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDay = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStartTime,
                    decoration: const InputDecoration(
                      labelText: 'Başlangıç',
                      border: OutlineInputBorder(),
                    ),
                    items: _times.map((time) => DropdownMenuItem(
                      value: time,
                      child: Text(time),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStartTime = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedEndTime,
                    decoration: const InputDecoration(
                      labelText: 'Bitiş',
                      border: OutlineInputBorder(),
                    ),
                    items: _times.map((time) => DropdownMenuItem(
                      value: time,
                      child: Text(time),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEndTime = value!;
                      });
                    },
                  ),
                ),
              ],
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
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPurple,
          ),
          child: Text(
            'Ekle',
            style: GoogleFonts.notoSans(color: AppTheme.cardBackground),
          ),
        ),
      ],
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    final instructor = _instructorController.text.trim();
    final location = _locationController.text.trim();

    if (name.isEmpty || instructor.isEmpty || location.isEmpty) {
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
      instructor: instructor,
      day: _selectedDay,
      startTime: _selectedStartTime,
      endTime: _selectedEndTime,
      location: location,
      createdAt: DateTime.now(),
    );

    widget.onCourseAdded(course);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructorController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
