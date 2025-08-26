import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/course_schedule_screen.dart';
import 'screens/exam_screen.dart';
import 'screens/goals_and_habits_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/event_calendar_screen.dart';
import 'screens/focus_mode_screen.dart';
import 'screens/gpa_simulator_screen.dart';
import 'screens/mood_tracker_screen.dart';
import 'screens/settings_screen.dart';
import 'models/course.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'providers/habit_provider.dart';
import 'providers/course_provider.dart';
import 'theme/app_theme.dart';

// Tema değişikliklerini yöneten provider
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void changeTheme(ThemeMode mode) {
    print('ThemeProvider: Tema değiştiriliyor: $mode');
    _themeMode = mode;
    notifyListeners();
  }
}

/// Uygulama başlatılırken yapılan ağır işlemleri yönetir
Future<void> setup() async {
  try {
    print('Setup başlatılıyor...');
    
    // Hive servisini başlat
    print('Hive servisi başlatılıyor...');
    await HiveService.init();
    print('Hive servisi başarıyla başlatıldı');
    
    // Bildirim servisini başlat
    print('Bildirim servisi başlatılıyor...');
    await NotificationService.init();
    print('Bildirim servisi başarıyla başlatıldı');
    
    // Günlük özet bildirimini planla
    print('Günlük özet bildirimi planlanıyor...');
    await NotificationService.scheduleDailyBrief();
    print('Günlük özet bildirimi başarıyla planlandı');
    
    // Firebase test
    await _testFirebase();
    
    print('Setup tamamlandı');
  } catch (e, stackTrace) {
    print('Setup sırasında hata: $e');
    print('Stack trace: $stackTrace');
    // Hata durumunda uygulama çalışmaya devam etsin
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase'i başlat
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase başarıyla başlatıldı');
    } else {
      print('Firebase zaten başlatılmış');
    }
    
    // Firebase test her durumda yap
    final app = Firebase.app();
    print('Firebase app name: ${app.name}');
    print('Firebase app options: ${app.options.projectId}');
    
  } catch (e) {
    print('Firebase başlatılırken hata: $e');
  }
  
  // Ağır işlemleri setup fonksiyonunda yap
  await setup();
  
  runApp(const NuvidaApp());
}

// Firebase test fonksiyonu
Future<void> _testFirebase() async {
  try {
    print('🧪 Firebase test başlatılıyor...');
    
    final firestore = FirebaseFirestore.instance;
    print('✅ Firestore başarıyla başlatıldı');
    
    // Test collection oluştur
    await firestore.collection('test').doc('firebase_test').set({
      'message': 'Firebase çalışıyor!',
      'timestamp': FieldValue.serverTimestamp(),
    });
    print('✅ Firestore yazma testi başarılı');
    
    // Test veri okuma
    final doc = await firestore.collection('test').doc('firebase_test').get();
    if (doc.exists) {
      print('✅ Firestore okuma testi başarılı: ${doc.data()}');
    }
    
    print('🎉 TÜM FIREBASE TESTLERİ BAŞARILI!');
    
  } catch (e) {
    print('❌ Firebase test hatası: $e');
    print('❌ Firebase çalışmıyor!');
  }
}

class NuvidaApp extends StatefulWidget {
  const NuvidaApp({super.key});

  @override
  State<NuvidaApp> createState() => _NuvidaAppState();
}

class _NuvidaAppState extends State<NuvidaApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          print('Ana uygulama build ediliyor, tema: ${themeProvider.themeMode}');
          return MaterialApp(
            title: 'Nuvida',
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const SplashScreen(),
            },
          );
        },
      ),
    );
  }
}

// Authentication wrapper
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // Kullanıcı giriş yapmış
          return const SplashScreen();
        } else {
          // Kullanıcı giriş yapmamış
          return const LoginScreen();
        }
      },
    );
  }
}

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _selectedIndex = 0;
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    print('HomeWrapper initState');
    // Dersleri yükle
    _loadCourses();
  }
  
  Future<void> _loadCourses() async {
    try {
      // Hive servisinin hazır olduğundan emin ol
      if (!Hive.isBoxOpen('courses')) {
        await HiveService.init();
      }
      
      final courses = HiveService.getAllCourses();
      if (mounted && _courses.length != courses.length) {
        setState(() {
          _courses = courses;
        });
        print('Başlangıçta dersler yüklendi: ${_courses.length} ders');
      }
    } catch (e) {
      print('Dersler yüklenirken hata: $e');
      // Hata durumunda boş liste kullan
      if (mounted) {
        setState(() {
          _courses = [];
        });
      }
    }
  }

       void _updateCourses(List<Course> courses) {
    // Sadece ders listesi değiştiyse setState çağır
    if (_courses.length != courses.length || !_areCoursesEqual(_courses, courses)) {
      setState(() {
        _courses = courses;
      });
      print('Dersler güncellendi: ${_courses.length} ders');
    }
  }
  
  // Ders listelerinin eşit olup olmadığını kontrol et
  bool _areCoursesEqual(List<Course> list1, List<Course> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id) return false;
    }
    return true;
  }
  
  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen(courses: _courses);
      case 1:
        return CourseScheduleScreen(courses: _courses, onCoursesChanged: _updateCourses);
      case 2:
        return const ExamScreen();
      case 3:
        return const NotesScreen();
      default:
        return HomeScreen(courses: _courses);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nuvida",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryIndigo,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigo,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nuvida',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.calendar_month, color: AppTheme.primaryIndigo),
              title: Text(
                'Etkinlik Takvimi',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Etkinlik Takvimi'),
                        backgroundColor: AppTheme.primaryIndigo,
                        foregroundColor: Colors.white,
                      ),
                      body: const EventCalendarScreen(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.flag, color: AppTheme.primaryIndigo),
              title: Text(
                'Hedefler & Alışkanlıklar',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Hedefler & Alışkanlıklar'),
                        backgroundColor: AppTheme.primaryIndigo,
                        foregroundColor: Colors.white,
                      ),
                      body: const GoalsAndHabitsScreen(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.psychology, color: AppTheme.primaryIndigo),
              title: Text(
                'Focus Modu',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Focus Modu'),
                        backgroundColor: AppTheme.primaryIndigo,
                        foregroundColor: Colors.white,
                      ),
                      body: const FocusModeScreen(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calculate, color: AppTheme.primaryIndigo),
              title: Text(
                'GPA Simülatörü',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('GPA Simülatörü'),
                        backgroundColor: AppTheme.primaryIndigo,
                        foregroundColor: Colors.white,
                      ),
                      body: const GPASimulatorScreen(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.mood, color: AppTheme.primaryIndigo),
              title: Text(
                'Mood Takibi',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Mood Takibi'),
                        backgroundColor: AppTheme.primaryIndigo,
                        foregroundColor: Colors.white,
                      ),
                      body: const MoodTrackerScreen(),
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: AppTheme.primaryIndigo),
              title: Text(
                'Ayarlar',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Ayarlar'),
                        backgroundColor: AppTheme.primaryIndigo,
                        foregroundColor: Colors.white,
                      ),
                      body: const SettingsScreen(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _getSelectedScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Ders Programı',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Sınav Takvimi',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note),
            label: 'Notlar',
          ),
        ],
      ),
    );
  }
}
