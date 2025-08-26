# 🎓 Nuvida - Öğrenci Asistanı

Nuvida, öğrencilerin akademik hayatlarını organize etmelerine yardımcı olan kapsamlı bir Flutter mobil uygulamasıdır.

## ✨ Özellikler

### 🏠 Ana Sayfa (Alışkanlıklar)
- Günlük alışkanlık takibi
- Alışkanlık ekleme/düzenleme
- Tamamlanan alışkanlıkları işaretleme
- Görsel ilerleme göstergeleri

### 📚 Dersler
- Ders listesi görüntüleme
- Ders bilgileri (gün, saat, süre)
- Modern kart tasarımı
- Ders detayları (yakında)

### 📅 Ders Programı
- Haftalık ders programı
- Öğretmen bilgileri
- Sınıf lokasyonları
- Detaylı zaman bilgileri

### 📝 Sınav Takvimi
- Sınav tarihleri ve saatleri
- Sınav lokasyonları
- Önemli notlar
- Kalan gün sayacı
- Gecikmiş sınav uyarıları

### 📖 Notlar
- Not ekleme/düzenleme/silme
- Ders bazlı kategorilendirme
- Etiket sistemi
- Önemli not işaretleme
- Tarih bazlı sıralama

### 🎯 Hedefler
- Hedef belirleme ve takip
- İlerleme yüzdesi
- Kategori bazlı organizasyon
- Hedef tarih takibi
- Tamamlanan hedefler

### ⚙️ Ayarlar
- Bildirim tercihleri
- Tema seçenekleri
- Dil ayarları
- Veri yedekleme/geri yükleme
- Uygulama bilgileri

## 🚀 Kurulum

1. Flutter SDK'yı yükleyin (3.0+)
2. Projeyi klonlayın
3. Bağımlılıkları yükleyin: `flutter pub get`
4. Uygulamayı çalıştırın: `flutter run`

## 🏗️ Proje Yapısı

```
lib/
├── main.dart                 # Ana uygulama girişi
├── screens/                  # Ekran dosyaları
│   ├── home_screen.dart     # Ana sayfa (alışkanlıklar)
│   ├── courses_screen.dart  # Dersler
│   ├── course_schedule_screen.dart # Ders programı
│   ├── exam_screen.dart     # Sınav takvimi
│   ├── notes_screen.dart    # Notlar
│   ├── goals_screen.dart    # Hedefler
│   └── settings_screen.dart # Ayarlar
├── models/                   # Veri modelleri
│   ├── course.dart          # Ders modeli
│   ├── course_schedule.dart # Ders programı modeli
│   ├── exam.dart            # Sınav modeli
│   ├── note.dart            # Not modeli
│   └── goal.dart            # Hedef modeli
└── add_habit_screen.dart    # Alışkanlık ekleme ekranı
```

## 🎨 Tasarım Özellikleri

- **Material Design 3** prensipleri
- **Responsive** tasarım
- **Modern UI** bileşenleri
- **Tutarlı renk paleti** (yeşil ana tema)
- **Görsel geri bildirimler** ve animasyonlar

## 📱 Navigasyon

- **Drawer Navigation** ile kolay ekran geçişi
- **State Management** ile veri güncellemeleri
- **setState()** ile UI yenileme
- **Modal dialogs** ile kullanıcı etkileşimi

## 💾 Veri Yönetimi

### Mevcut Durum
- In-memory veri saklama
- Mock veriler ile demo
- StatefulWidget ile durum yönetimi

### Önerilen Geliştirmeler
1. **SharedPreferences** - Basit ayarlar için
2. **SQLite** - Yerel veritabanı
3. **Hive** - NoSQL yerel veritabanı
4. **Cloud Firestore** - Bulut senkronizasyonu

## 🔧 Teknik Detaylar

- **Flutter Version**: 3.0+
- **Dart Version**: 2.17+
- **Platform Support**: Android, iOS, Web, Windows, macOS, Linux
- **Architecture**: StatefulWidget pattern
- **State Management**: setState() with StatefulWidget

## 🚧 Gelecek Geliştirmeler

- [ ] Veri kalıcılığı (local storage)
- [ ] Push bildirimleri
- [ ] Takvim entegrasyonu
- [ ] Bulut senkronizasyonu
- [ ] Çoklu dil desteği
- [ ] Karanlık tema
- [ ] Widget desteği
- [ ] Offline çalışma modu

## 📋 Kullanım

1. **Alışkanlık Ekleme**: Ana sayfada + butonuna tıklayın
2. **Not Ekleme**: Notlar ekranında + butonuna tıklayın
3. **Hedef Belirleme**: Hedefler ekranında + butonuna tıklayın
4. **Ekran Geçişi**: Sol üst köşedeki menü ikonuna tıklayın

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Commit yapın (`git commit -m 'Add some AmazingFeature'`)
4. Push yapın (`git push origin feature/AmazingFeature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 📞 İletişim

- **Proje**: [Nuvida GitHub](https://github.com/yourusername/nuvida)
- **Geliştirici**: [Your Name](mailto:your.email@example.com)

---

**Nuvida** ile akademik hayatınızı organize edin! 🎓✨
