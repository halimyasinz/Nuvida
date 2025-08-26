import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/hive_service.dart';
import '../theme/app_theme.dart';
import '../constants/note_constants.dart';
import '../widgets/note_filter_widget.dart';
import '../widgets/tag_input_widget.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = true;
  
  // Filtreleme state'i
  String? _selectedCategory;
  List<String> _selectedTags = [];
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Eski notları güncelle
      await HiveService.updateExistingNotes();
      
      final notes = HiveService.getAllNotes();
      print('HiveService.getAllNotes() sonucu: ${notes.length} not bulundu');
      
      setState(() {
        _notes = notes;
        _filteredNotes = notes;
        _isLoading = false;
        print('Notlar yüklendi. Toplam: ${_notes.length}, Filtrelenmiş: ${_filteredNotes.length}');
      });
    } catch (e) {
      print('_loadNotes hatası: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notlar yüklenirken hata oluştu: $e',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }
    }
  }

  // Filtreleme fonksiyonu
  void _applyFilters() {
    print('_applyFilters() çağrıldı. Seçili kategori: $_selectedCategory, Seçili etiketler: $_selectedTags');
    print('Toplam not sayısı: ${_notes.length}');
    
    setState(() {
      _filteredNotes = _notes.where((note) {
        // Kategori filtresi
        if (_selectedCategory != null && note.category != _selectedCategory) {
          return false;
        }
        
        // Etiket filtresi
        if (_selectedTags.isNotEmpty) {
          final hasAllTags = _selectedTags.every((tag) => note.tags.contains(tag));
          if (!hasAllTags) {
            return false;
          }
        }
        
        return true;
      }).toList();
      
      print('Filtreleme sonucu: ${_filteredNotes.length} not');
    });
  }

  // Kategori değiştiğinde
  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters();
    
    // Filtre eklendikten sonra filtre bölümünü kapat
    if (category != null) {
      setState(() {
        _showFilters = false;
      });
      
      // Kullanıcıya filtre uygulandığını bildir
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kategori filtresi uygulandı: $category',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    }
  }

  // Etiketler değiştiğinde
  void _onTagsChanged(List<String> tags) {
    setState(() {
      _selectedTags = tags;
    });
    _applyFilters();
    
    // Filtre eklendikten sonra filtre bölümünü kapat
    if (tags.isNotEmpty) {
      setState(() {
        _showFilters = false;
      });
      
      // Kullanıcıya filtre uygulandığını bildir
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Etiket filtresi uygulandı: ${tags.join(', ')}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    }
  }

  // Filtreleri temizle
  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedTags = [];
      _showFilters = false;
    });
    _applyFilters();
    
    // Kullanıcıya filtrelerin temizlendiğini bildir
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tüm filtreler temizlendi',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  // Mevcut tüm etiketleri al
  List<String> get _availableTags {
    final allTags = <String>{};
    for (final note in _notes) {
      allTags.addAll(note.tags);
    }
    return allTags.toList()..sort();
  }

  // Aktif filtre var mı?
  bool get _hasActiveFilters => _selectedCategory != null || _selectedTags.isNotEmpty;

  void _showNoteDetails(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (note.courseName != null) ...[
                Row(
                  children: [
                    Icon(Icons.school, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      note.courseName!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Text(
                note.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Kategori
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(note.category ?? 'Genel').withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getCategoryColor(note.category ?? 'Genel'),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_getCategoryIcon(note.category ?? 'Genel')),
                        const SizedBox(width: 4),
                        Text(
                          note.category ?? 'Genel',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: _getCategoryColor(note.category ?? 'Genel'),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Etiketler
              if (note.tags.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.label, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: note.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.lightPurple,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.primaryPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              // Zaman damgaları
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Oluşturulma: ${_formatDate(note.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (note.lastModified != note.createdAt) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Son güncelleme: ${_formatDate(note.lastModified)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
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
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editNote(note);
            },
            child: const Text('Düzenle'),
          ),
        ],
      ),
    );
  }

  void _addNote() {
    print('_addNote() çağrıldı');
    
    showDialog(
      context: context,
      builder: (context) => _AddNoteDialog(
        onNoteAdded: (note) async {
          print('onNoteAdded callback başladı: ${note.title}');
          
          try {
            print('HiveService.addNote çağrılıyor...');
            await HiveService.addNote(note);
            print('HiveService.addNote tamamlandı');
            
            // Notları yeniden yükle
            await _loadNotes();
            
            if (mounted) {
              print('SnackBar gösteriliyor...');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Not başarıyla eklendi',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }
          } catch (e) {
            print('Hata oluştu: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Not eklenirken hata oluştu: $e',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _editNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => _AddNoteDialog(
        note: note,
        onNoteAdded: (editedNote) async {
          try {
            await HiveService.updateNote(editedNote);
            
            // Notları yeniden yükle
            await _loadNotes();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Not başarıyla güncellendi',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Not güncellenirken hata oluştu: $e',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteNote(String id) async {
    // Silme onayı iste
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notu Sil'),
        content: const Text('Bu notu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.highRisk,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await HiveService.deleteNote(id);
      
      // Notları yeniden yükle
      await _loadNotes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Not silindi',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Not silinirken hata oluştu: $e',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.spacingM),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Notlarım",
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      if (_notes.isEmpty)
                        TextButton.icon(
                          onPressed: () async {
                            await HiveService.addSampleNotes();
                            _loadNotes();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Örnek Notlar'),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    "Önemli bilgilerini kaydet ve organize et",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_filteredNotes.length} not bulundu",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    // Filtreleme butonu
                    Container(
                      decoration: BoxDecoration(
                        color: _hasActiveFilters
                            ? AppTheme.warning
                            : AppTheme.primaryPurple,
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _showFilters = !_showFilters;
                          });
                        },
                        icon: Icon(
                          _showFilters ? Icons.filter_alt : Icons.filter_list,
                          color: Colors.white,
                        ),
                        tooltip: 'Filtrele',
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    // Filtreleri temizle butonu
                    if (_hasActiveFilters)
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.highRisk,
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: IconButton(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear, color: Colors.white),
                          tooltip: 'Filtreleri Temizle',
                        ),
                      ),
                    if (_hasActiveFilters)
                      const SizedBox(width: AppTheme.spacingS),
                    // Not ekleme butonu
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple,
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: IconButton(
                        onPressed: _addNote,
                        icon: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
            
            // Filtreleme widget'ı
            if (_showFilters) ...[
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: NoteFilterWidget(
                  selectedCategory: _selectedCategory,
                  selectedTags: _selectedTags,
                  onCategoryChanged: _onCategoryChanged,
                  onTagsChanged: _onTagsChanged,
                  availableTags: _availableTags,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
            ],
            
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppTheme.primaryPurple),
                          const SizedBox(height: AppTheme.spacingM),
                          Text(
                            'Notlar yükleniyor...',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _notes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.note_add,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              const SizedBox(height: AppTheme.spacingM),
                              Text(
                                'Henüz not eklenmemiş',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingS),
                              Text(
                                'İlk notunu eklemek için + butonuna tıkla',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadNotes,
                          color: AppTheme.primaryPurple,
                          child: ListView.builder(
                            itemCount: _filteredNotes.length,
                            itemBuilder: (context, index) {
                              final note = _filteredNotes[index];
                              return GestureDetector(
                                onTap: () => _showNoteDetails(note),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardBackground,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                                    boxShadow: AppTheme.cardShadow,
                                    border: Border(
                                      left: BorderSide(
                                        color: note.isImportant ? AppTheme.mediumRisk : AppTheme.primaryPurple,
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppTheme.spacingM),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(AppTheme.spacingS),
                                              decoration: BoxDecoration(
                                                color: note.isImportant
                                                    ? AppTheme.mediumRisk.withOpacity(0.1)
                                                    : AppTheme.primaryPurple.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                                              ),
                                              child: Icon(
                                                note.isImportant ? Icons.star : Icons.note,
                                                color: note.isImportant
                                                    ? AppTheme.mediumRisk
                                                    : AppTheme.primaryPurple,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: AppTheme.spacingS),
                                            Expanded(
                                              child: Text(
                                                note.title,
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            if (note.isImportant)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: AppTheme.spacingS,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.mediumRisk,
                                                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                                                ),
                                                child: Text(
                                                  'Önemli',
                                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: AppTheme.spacingS),
                                        if (note.courseName != null) ...[
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.school,
                                                size: 16,
                                                color: AppTheme.textSecondary,
                                              ),
                                              const SizedBox(width: AppTheme.spacingS),
                                              Text(
                                                note.courseName!,
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: AppTheme.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: AppTheme.spacingS),
                                        ],
                                        Text(
                                          note.content,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: AppTheme.spacingS),
                                        // Kategori gösterimi
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.category,
                                              size: 16,
                                              color: AppTheme.textSecondary,
                                            ),
                                            const SizedBox(width: AppTheme.spacingS),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: AppTheme.spacingS,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getCategoryColor(note.category ?? 'Genel').withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                                                border: Border.all(
                                                  color: _getCategoryColor(note.category ?? 'Genel'),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    _getCategoryIcon(note.category ?? 'Genel'),
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    note.category ?? 'Genel',
                                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                      color: _getCategoryColor(note.category ?? 'Genel'),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppTheme.spacingS),
                                        
                                        // Etiketler gösterimi
                                        if (note.tags.isNotEmpty) ...[
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.label,
                                                size: 16,
                                                color: AppTheme.textSecondary,
                                              ),
                                              const SizedBox(width: AppTheme.spacingS),
                                              Expanded(
                                                child: Wrap(
                                                  spacing: AppTheme.spacingS,
                                                  runSpacing: 4,
                                                  children: note.tags.map((tag) {
                                                    return Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: AppTheme.spacingS,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.lightPurple,
                                                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                                                      ),
                                                      child: Text(
                                                        tag,
                                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                          color: AppTheme.primaryPurple,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: AppTheme.spacingS),
                                        ],
                                        // Zaman damgaları
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 16,
                                              color: AppTheme.textSecondary,
                                            ),
                                            const SizedBox(width: AppTheme.spacingS),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Oluşturulma: ${_formatDate(note.createdAt)}',
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: AppTheme.textSecondary,
                                                    ),
                                                  ),
                                                  if (note.lastModified != note.createdAt) ...[
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Son güncelleme: ${_formatDate(note.lastModified)}',
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        color: AppTheme.textSecondary,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            PopupMenuButton(
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'edit',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.edit),
                                                      SizedBox(width: 8),
                                                      Text('Düzenle'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.delete, color: AppTheme.highRisk),
                                                      SizedBox(width: 8),
                                                      Text('Sil', style: TextStyle(color: AppTheme.highRisk)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              onSelected: (value) {
                                                if (value == 'edit') {
                                                  _editNote(note);
                                                } else if (value == 'delete') {
                                                  _deleteNote(note.id);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _AddNoteDialog extends StatefulWidget {
  final Note? note;
  final Function(Note) onNoteAdded;

  const _AddNoteDialog({
    this.note,
    required this.onNoteAdded,
  });

  @override
  State<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<_AddNoteDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _courseController = TextEditingController();
  List<String> _tags = [];
  String _selectedCategory = 'Genel';
  bool _isImportant = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _isEditing = true;
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _courseController.text = widget.note!.courseName ?? '';
      _tags = List<String>.from(widget.note!.tags);
             _selectedCategory = widget.note!.category ?? 'Genel';
      _isImportant = widget.note!.isImportant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      ),
      title: Text(
        _isEditing ? 'Notu Düzenle' : 'Yeni Not Ekle',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Başlık',
                border: const OutlineInputBorder(),
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'İçerik',
                border: const OutlineInputBorder(),
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              maxLines: 4,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
                         TextField(
               controller: _courseController,
               decoration: InputDecoration(
                 labelText: 'Ders (Opsiyonel)',
                 border: const OutlineInputBorder(),
                 labelStyle: Theme.of(context).textTheme.bodyMedium,
               ),
             ),
             const SizedBox(height: 20),
             
             // Kategori seçimi
             DropdownButtonFormField<String>(
               value: _selectedCategory,
               decoration: InputDecoration(
                 labelText: 'Kategori',
                 border: const OutlineInputBorder(),
                 labelStyle: Theme.of(context).textTheme.bodyMedium,
               ),
               items: NoteCategories.categories.map((category) {
                 return DropdownMenuItem<String>(
                   value: category,
                   child: Row(
                     children: [
                       Text(NoteCategories.categoryIcons[category] ?? '📝'),
                       const SizedBox(width: 8),
                       Text(category),
                     ],
                   ),
                 );
               }).toList(),
               onChanged: (value) {
                 if (value != null) {
                   setState(() {
                     _selectedCategory = value;
                   });
                 }
               },
             ),
             const SizedBox(height: 20),
             
             // Etiket girişi
             TagInputWidget(
               tags: _tags,
               onTagsChanged: (tags) {
                 setState(() {
                   _tags = tags;
                 });
               },
               suggestedTags: ['matematik', 'formül', 'önemli', 'sınav', 'ödev', 'proje', 'araştırma'],
             ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _isImportant,
                  onChanged: (value) {
                    setState(() {
                      _isImportant = value ?? false;
                    });
                  },
                ),
                Text(
                  'Önemli Not',
                  style: Theme.of(context).textTheme.bodyMedium,
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
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.success,
          ),
          child: Text(
            _isEditing ? 'Güncelle' : 'Ekle',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  void _submit() {
    print('_submit() çağrıldı');
    
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final courseName = _courseController.text.trim();

    print('Title: $title, Content: $content, Category: $_selectedCategory, Tags: $_tags');

    if (title.isEmpty || content.isEmpty) {
      print('Başlık veya içerik boş');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Başlık ve içerik zorunludur',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
      return;
    }

    try {
      final note = Note(
        id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        lastModified: DateTime.now(),
        courseName: courseName.isEmpty ? null : courseName,
        tags: List<String>.from(_tags),
        isImportant: _isImportant,
        category: _selectedCategory,
      );

      print('Note oluşturuldu: ${note.title}, ID: ${note.id}, Category: ${note.category}');
      print('onNoteAdded callback çağrılıyor...');
      
      // Dialog'u kapat
      Navigator.pop(context);
      
      // Callback'i çağır
      widget.onNoteAdded(note);
      print('onNoteAdded callback tamamlandı');
      
    } catch (e) {
      print('Note oluşturma hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Not oluşturulurken hata: $e',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _courseController.dispose();
    super.dispose();
  }
}

// Yardımcı fonksiyonlar
Color _getCategoryColor(String category) {
  final colorHex = NoteCategories.categoryColors[category];
  return colorHex != null ? Color(colorHex) : Colors.grey;
}

String _getCategoryIcon(String category) {
  return NoteCategories.categoryIcons[category] ?? '📝';
}
