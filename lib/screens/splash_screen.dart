import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    
    // Async işlemleri başlat ve yönlendirme yap
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    try {
      // Minimum 2 saniye bekle (animasyon için)
      await Future.delayed(const Duration(milliseconds: 2000));
      
      // Hive servisini başlat (timeout ile)
      print('Hive servisi başlatılıyor...');
      await HiveService.init().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Hive servisi başlatma timeout!');
          throw TimeoutException('Hive servisi başlatılamadı');
        },
      );
      print('Hive servisi başlatıldı');
      
      // Notification servisini başlat (timeout ile)
      print('Notification servisi başlatılıyor...');
      await NotificationService.init().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('Notification servisi başlatma timeout!');
          throw TimeoutException('Notification servisi başlatılamadı');
        },
      );
      print('Notification servisi başlatıldı');
      
      // Daily brief bildirimini planla (timeout ile)
      print('Daily brief bildirimi planlanıyor...');
      await NotificationService.scheduleDailyBrief().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('Daily brief bildirimi planlama timeout!');
          throw TimeoutException('Daily brief bildirimi planlanamadı');
        },
      );
      print('Daily brief bildirimi planlandı');
      
      // Ek güvenlik için kısa bir bekleme
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('Ana sayfaya yönlendiriliyor...');
      
      // Ana sayfaya yönlendir
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeWrapper(),
          ),
        );
      }
    } catch (e) {
      print('Uygulama başlatılırken hata: $e');
      
      // Hata durumunda da ana sayfaya git (fallback)
      if (mounted) {
        print('Hata durumunda fallback olarak ana sayfaya yönlendiriliyor...');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeWrapper(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryIndigo,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.school,
                        size: 60,
                        color: AppTheme.primaryIndigo,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // App Name
                    Text(
                      'Nuvida',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Tagline
                    Text(
                      'Akademik Hayatını Planla',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Loading indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
