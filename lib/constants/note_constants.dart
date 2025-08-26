// Not kategorileri
class NoteCategories {
  static const List<String> categories = [
    'Genel',
    'Ders',
    'Kişisel',
    'Etkinlik',
    'Okuma',
    'Spor / Sağlık',
  ];

  // Kategori renkleri (Material Design renkleri)
  static const Map<String, int> categoryColors = {
    'Genel': 0xFF9E9E9E,      // Grey
    'Ders': 0xFF2196F3,       // Blue
    'Kişisel': 0xFFE91E63,    // Pink
    'Etkinlik': 0xFF4CAF50,   // Green
    'Okuma': 0xFF795548,      // Brown
    'Spor / Sağlık': 0xFFFF5722, // Deep Orange
  };

  // Kategori icon'ları
  static const Map<String, String> categoryIcons = {
    'Genel': '📝',
    'Ders': '📚',
    'Kişisel': '👤',
    'Etkinlik': '🎉',
    'Okuma': '📖',
    'Spor / Sağlık': '💪',
  };
}
