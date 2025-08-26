import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen>
    with TickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  int _longBreakMinutes = 15;
  int _currentMinutes = 25;
  int _currentSeconds = 0;
  bool _isRunning = false;
  bool _isBreak = false;
  bool _isLongBreak = false;
  int _completedSessions = 0;
  int _currentSession = 1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(minutes: _focusMinutes),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  void _startTimer() {
    if (!_isRunning) {
      setState(() {
        _isRunning = true;
      });
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_currentSeconds > 0) {
          setState(() {
            _currentSeconds--;
          });
        } else if (_currentMinutes > 0) {
          setState(() {
            _currentMinutes--;
            _currentSeconds = 59;
          });
        } else {
          _timer.cancel();
          _onSessionComplete();
        }
      });
      
      _animationController.forward();
    }
  }

  void _pauseTimer() {
    if (_isRunning) {
      _timer.cancel();
      _animationController.stop();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _resetTimer() {
    _timer.cancel();
    _animationController.reset();
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _isLongBreak = false;
      _currentMinutes = _focusMinutes;
      _currentSeconds = 0;
      _currentSession = 1;
    });
  }

  void _onSessionComplete() {
    if (!_isBreak && !_isLongBreak) {
      // Focus session completed
      setState(() {
        _completedSessions++;
        _isBreak = true;
        _isLongBreak = _completedSessions % 4 == 0;
        _currentMinutes = _isLongBreak ? _longBreakMinutes : _breakMinutes;
        _currentSeconds = 0;
      });
      
      _showSessionCompleteDialog('Odak seansı tamamlandı!', 
        _isLongBreak ? 'Uzun mola zamanı!' : 'Kısa mola zamanı!');
    } else {
      // Break completed
      setState(() {
        _isBreak = false;
        _isLongBreak = false;
        _currentMinutes = _focusMinutes;
        _currentSeconds = 0;
        _currentSession++;
      });
      
      _showSessionCompleteDialog('Mola tamamlandı!', 'Yeni odak seansına başla!');
    }
    
    _animationController.reset();
    _startTimer();
  }

  void _showSessionCompleteDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _setFocusTime(int minutes) {
    setState(() {
      _focusMinutes = minutes;
      if (!_isRunning && !_isBreak) {
        _currentMinutes = minutes;
        _currentSeconds = 0;
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
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
                    "Focus Modu",
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    "Odaklan ve verimli çalış",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            
            // Timer Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingXL),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  // Progress Circle
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return CircularProgressIndicator(
                              value: _animation.value,
                              strokeWidth: 8,
                              backgroundColor: AppTheme.textLight.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _isBreak ? AppTheme.lowRisk : AppTheme.primaryPurple,
                              ),
                            );
                          },
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_currentMinutes.toString().padLeft(2, '0')}:${_currentSeconds.toString().padLeft(2, '0')}',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: _isBreak ? AppTheme.lowRisk : AppTheme.primaryPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _isBreak 
                                  ? (_isLongBreak ? 'Uzun Mola' : 'Kısa Mola')
                                  : 'Odaklan',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Session Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSessionInfo('Seans', '$_currentSession'),
                      _buildSessionInfo('Tamamlanan', '$_completedSessions'),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Timer Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _isRunning ? _pauseTimer : _startTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRunning ? AppTheme.mediumRisk : AppTheme.primaryPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingXL,
                            vertical: AppTheme.spacingM,
                          ),
                        ),
                        child: Text(
                          _isRunning ? 'Duraklat' : 'Başla',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.cardBackground,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _resetTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.textSecondary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingXL,
                            vertical: AppTheme.spacingM,
                          ),
                        ),
                        child: Text(
                          'Sıfırla',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.cardBackground,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Quick Settings
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
                    "Hızlı Ayarlar",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickSettingButton(25, '25dk'),
                      _buildQuickSettingButton(45, '45dk'),
                      _buildQuickSettingButton(60, '60dk'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Tips
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.lightPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(
                  color: AppTheme.lightPurple.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: AppTheme.primaryPurple,
                        size: 24,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        "Odaklanma İpuçları",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    "• Telefonu sessize al ve uzaklaştır\n"
                    "• Rahat bir pozisyonda otur\n"
                    "• Derin nefes al ve rahatla\n"
                    "• Sadece tek bir işe odaklan",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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

  Widget _buildQuickSettingButton(int minutes, String label) {
    final isSelected = _focusMinutes == minutes;
    return ElevatedButton(
      onPressed: () => _setFocusTime(minutes),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.primaryPurple : Theme.of(context).colorScheme.surface,
        foregroundColor: isSelected ? Colors.white : AppTheme.primaryPurple,
        side: BorderSide(
          color: isSelected ? AppTheme.primaryPurple : Theme.of(context).colorScheme.outline,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
