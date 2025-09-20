import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryIndigo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ve başlık
              const Icon(
                Icons.school,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              const Text(
                'Nuvida',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Öğrenci Yaşam Asistanı',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 64),

              // Google ile giriş butonu
              _buildSignInButton(
                text: 'Google ile Giriş Yap',
                icon: 'assets/icons/google_icon.png', // Google icon ekle
                backgroundColor: Colors.white,
                textColor: Colors.black87,
                onPressed: _signInWithGoogle,
              ),
              const SizedBox(height: 16),

              // Apple ile giriş butonu
              _buildSignInButton(
                text: 'Apple ile Giriş Yap',
                icon: 'assets/icons/apple_icon.png', // Apple icon ekle
                backgroundColor: Colors.black,
                textColor: Colors.white,
                onPressed: _signInWithApple,
              ),
              const SizedBox(height: 16),

              // Misafir girişi butonu
              _buildSignInButton(
                text: 'Misafir Olarak Giriş Yap',
                icon: 'assets/icons/guest_icon.png', // Guest icon ekle
                backgroundColor: Colors.grey[700]!,
                textColor: Colors.white,
                onPressed: _signInAsGuest,
              ),
              const SizedBox(height: 32),

              // Yükleniyor göstergesi
              if (_isLoading)
                const CircularProgressIndicator(
                  color: Colors.white,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton({
    required String text,
    required String icon,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon placeholder (gerçek icon'ları ekle)
            Icon(
              icon.contains('google') ? Icons.g_mobiledata : 
              icon.contains('apple') ? Icons.apple :
              icon.contains('guest') ? Icons.person_outline : Icons.person,
              size: 24,
              color: textColor,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Google ile giriş
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential != null) {
        // Giriş başarılı, ana sayfaya yönlendir
        _navigateToHome();
      } else {
        _showErrorSnackBar('Google ile giriş iptal edildi veya başarısız oldu');
      }
    } catch (e) {
      _showErrorSnackBar('Giriş hatası: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Apple ile giriş
  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithApple();
      
      if (userCredential != null) {
        // Giriş başarılı, ana sayfaya yönlendir
        _navigateToHome();
      } else {
        _showErrorSnackBar('Apple ile giriş başarısız');
      }
    } catch (e) {
      _showErrorSnackBar('Giriş hatası: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Misafir girişi
  Future<void> _signInAsGuest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _authService.signInAnonymously();
      
      if (userCredential != null) {
        // Giriş başarılı, ana sayfaya yönlendir
        _navigateToHome();
      } else {
        _showErrorSnackBar('Misafir girişi başarısız');
      }
    } catch (e) {
      _showErrorSnackBar('Giriş hatası: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Ana sayfaya yönlendir
  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  // Hata mesajı göster
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
