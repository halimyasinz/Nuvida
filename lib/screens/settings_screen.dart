import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nuvida/theme/app_theme.dart';
import 'package:nuvida/services/auth_service.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoBackupEnabled = true;
  String _selectedLanguage = 'Türkçe';
  String _selectedTheme = 'Sistem';

  final List<String> _languages = ['Türkçe', 'English', 'Deutsch', 'Français'];
  final List<String> _themes = ['Sistem', 'Açık', 'Koyu'];

  @override
  void initState() {
    super.initState();
    // Mevcut tema durumunu al
    _loadCurrentTheme();
  }

  void _loadCurrentTheme() {
    // ThemeProvider'dan mevcut tema durumunu al
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      switch (themeProvider.themeMode) {
        case ThemeMode.system:
          _selectedTheme = 'Sistem';
          break;
        case ThemeMode.light:
          _selectedTheme = 'Açık';
          break;
        case ThemeMode.dark:
          _selectedTheme = 'Koyu';
          break;
      }
      setState(() {});
    });
  }

  void _changeTheme(String theme) {
    print('Tema değiştiriliyor: $theme');
    
    setState(() {
      _selectedTheme = theme;
    });

    ThemeMode newThemeMode;
    switch (theme) {
      case 'Sistem':
        newThemeMode = ThemeMode.system;
        break;
      case 'Açık':
        newThemeMode = ThemeMode.light;
        break;
      case 'Koyu':
        newThemeMode = ThemeMode.dark;
        break;
      default:
        newThemeMode = ThemeMode.system;
    }

    print('Yeni tema modu: $newThemeMode');

    // ThemeProvider üzerinden tema değişikliğini yap
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.changeTheme(newThemeMode);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            "Ayarlar",
            style: GoogleFonts.notoSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              children: [
                // App Info Section
                _buildSectionHeader('Uygulama Bilgileri'),
                _buildInfoCard(
                  title: 'Nuvida',
                  subtitle: 'Öğrenci Asistanı',
                  icon: Icons.school,
                  iconColor: AppTheme.success,
                ),
                _buildInfoCard(
                  title: 'Versiyon',
                  subtitle: '1.0.0',
                  icon: Icons.info,
                  iconColor: AppTheme.primaryPurple,
                ),

                const SizedBox(height: 24),

                // Preferences Section
                _buildSectionHeader('Tercihler'),
                _buildSwitchTile(
                  title: 'Bildirimler',
                  subtitle: 'Sınav ve ders hatırlatıcıları',
                  icon: Icons.notifications,
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Otomatik Yedekleme',
                  subtitle: 'Verileri otomatik olarak yedekle',
                  icon: Icons.backup,
                  value: _autoBackupEnabled,
                  onChanged: (value) {
                    setState(() {
                      _autoBackupEnabled = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Language & Theme Section
                _buildSectionHeader('Görünüm ve Dil'),
                _buildDropdownTile(
                  title: 'Dil',
                  subtitle: 'Uygulama dili',
                  icon: Icons.language,
                  value: _selectedLanguage,
                  items: _languages,
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                  },
                ),
                _buildDropdownTile(
                  title: 'Tema',
                  subtitle: 'Uygulama teması',
                  icon: Icons.palette,
                  value: _selectedTheme,
                  items: _themes,
                  onChanged: (value) {
                    _changeTheme(value!);
                  },
                ),

                const SizedBox(height: 24),

                // Data Management Section
                _buildSectionHeader('Veri Yönetimi'),
                _buildActionTile(
                  title: 'Verileri Dışa Aktar',
                  subtitle: 'Tüm verileri JSON formatında dışa aktar',
                  icon: Icons.download,
                  iconColor: AppTheme.primaryBlue,
                  onTap: () {
                    _showExportDialog();
                  },
                ),
                _buildActionTile(
                  title: 'Verileri İçe Aktar',
                  subtitle: 'Dışa aktarılan verileri geri yükle',
                  icon: Icons.upload,
                  iconColor: AppTheme.success,
                  onTap: () {
                    _showImportDialog();
                  },
                ),
                _buildActionTile(
                  title: 'Verileri Temizle',
                  subtitle: 'Tüm verileri kalıcı olarak sil',
                  icon: Icons.delete_forever,
                  iconColor: AppTheme.danger,
                  onTap: () {
                    _showClearDataDialog();
                  },
                ),

                const SizedBox(height: 24),

                // Support Section
                _buildSectionHeader('Destek'),
                _buildActionTile(
                  title: 'Yardım',
                  subtitle: 'Kullanım kılavuzu ve SSS',
                  icon: Icons.help,
                  iconColor: AppTheme.warning,
                  onTap: () {
                    _showHelpDialog();
                  },
                ),
                _buildActionTile(
                  title: 'Geri Bildirim',
                  subtitle: 'Öneri ve hata bildirimi',
                  icon: Icons.feedback,
                  iconColor: AppTheme.secondaryPurple,
                  onTap: () {
                    _showFeedbackDialog();
                  },
                ),
                _buildActionTile(
                  title: 'Hakkında',
                  subtitle: 'Uygulama hakkında detaylı bilgi',
                  icon: Icons.info_outline,
                  iconColor: AppTheme.info,
                  onTap: () {
                    _showAboutDialog();
                  },
                ),

                const SizedBox(height: 32),

                // Çıkış Yap Section
                _buildSectionHeader('Hesap'),
                _buildActionTile(
                  title: 'Çıkış Yap',
                  subtitle: 'Hesabından çıkış yap ve başka hesaba geçiş yap',
                  icon: Icons.logout,
                  iconColor: Colors.red,
                  onTap: () {
                    _showSignOutDialog();
                  },
                ),

                const SizedBox(height: 32),

                // App Version Footer
                Center(
                  child: Text(
                    'Nuvida v1.0.0 • Flutter ile geliştirildi',
                    style: GoogleFonts.notoSans(
                      color: AppTheme.textLight,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.notoSans(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade100,
          child: Icon(icon, color: Colors.grey.shade700),
        ),
        title: Text(
          title,
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.notoSans(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.green.shade700,
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade100,
          child: Icon(icon, color: Colors.grey.shade700),
        ),
        title: Text(
          title,
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.notoSans(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: DropdownButton<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.notoSans()),
            );
          }).toList(),
          onChanged: onChanged,
          underline: Container(),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.notoSans(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Verileri Dışa Aktar',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Tüm verileriniz JSON formatında dışa aktarılacak. Devam etmek istiyor musunuz?',
          style: GoogleFonts.notoSans(),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Veriler dışa aktarıldı',
                    style: GoogleFonts.notoSans(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: Text(
              'Dışa Aktar',
              style: GoogleFonts.notoSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Verileri İçe Aktar',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Dışa aktarılan verileri geri yüklemek istiyor musunuz? Mevcut veriler üzerine yazılacak.',
          style: GoogleFonts.notoSans(),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Veriler içe aktarıldı',
                    style: GoogleFonts.notoSans(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: Text(
              'İçe Aktar',
              style: GoogleFonts.notoSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Verileri Temizle',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Tüm verileriniz kalıcı olarak silinecek. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
          style: GoogleFonts.notoSans(),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Veriler temizlendi',
                    style: GoogleFonts.notoSans(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            child: Text(
              'Temizle',
              style: GoogleFonts.notoSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Yardım',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Nuvida kullanım kılavuzu ve sık sorulan sorular yakında eklenecek.',
          style: GoogleFonts.notoSans(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: Text(
              'Tamam',
              style: GoogleFonts.notoSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Geri Bildirim',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Öneri ve hata bildirimleriniz için geliştirici ekibimizle iletişime geçebilirsiniz.',
          style: GoogleFonts.notoSans(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: Text(
              'Tamam',
              style: GoogleFonts.notoSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Nuvida Hakkında',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Nuvida, öğrencilerin akademik hayatlarını organize etmelerine yardımcı olan kapsamlı bir öğrenci asistanı uygulamasıdır.\n\nFlutter ile geliştirilmiştir ve Material Design prensiplerini takip eder.',
          style: GoogleFonts.notoSans(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: Text(
              'Tamam',
              style: GoogleFonts.notoSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Çıkış Yap',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Hesabından çıkış yapmak istediğinizden emin misiniz?\n\nÇıkış yaptıktan sonra tekrar giriş yapmanız gerekecek.',
          style: GoogleFonts.notoSans(),
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
            onPressed: () async {
              Navigator.pop(context);
              await _signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            child: Text(
              'Çıkış Yap',
              style: GoogleFonts.notoSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      // AuthService'i import et ve çıkış yap
      final authService = AuthService();
      await authService.signOut();
      
      // Login ekranına yönlendir
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Başarıyla çıkış yapıldı',
            style: GoogleFonts.notoSans(),
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Çıkış yapılırken hata oluştu: $e',
              style: GoogleFonts.notoSans(),
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
}
