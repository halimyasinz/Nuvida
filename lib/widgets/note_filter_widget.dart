import 'package:flutter/material.dart';
import '../constants/note_constants.dart';

class NoteFilterWidget extends StatefulWidget {
  final String? selectedCategory;
  final List<String> selectedTags;
  final Function(String?) onCategoryChanged;
  final Function(List<String>) onTagsChanged;
  final List<String> availableTags; // Mevcut tüm etiketler

  const NoteFilterWidget({
    super.key,
    this.selectedCategory,
    required this.selectedTags,
    required this.onCategoryChanged,
    required this.onTagsChanged,
    required this.availableTags,
  });

  @override
  State<NoteFilterWidget> createState() => _NoteFilterWidgetState();
}

class _NoteFilterWidgetState extends State<NoteFilterWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtreleme',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Kategori filtresi
              Text(
                'Kategori:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: widget.selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Tümü'),
                  ),
                  ...NoteCategories.categories.map((category) {
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
                  }),
                ],
                onChanged: widget.onCategoryChanged,
              ),
              
              const SizedBox(height: 16),
              
              // Etiket filtresi
              Text(
                'Etiketler:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              // Seçili etiketler
              if (widget.selectedTags.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.selectedTags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      deleteIcon: Icon(
                        Icons.close,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                      onDeleted: () {
                        final newTags = List<String>.from(widget.selectedTags)..remove(tag);
                        widget.onTagsChanged(newTags);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
              
              // Etiket seçimi
              if (widget.availableTags.isNotEmpty) ...[
                Text(
                  'Etiket seç:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: widget.availableTags.where((tag) => !widget.selectedTags.contains(tag)).map((tag) {
                    return ActionChip(
                      label: Text(tag),
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                      onPressed: () {
                        final newTags = List<String>.from(widget.selectedTags)..add(tag);
                        widget.onTagsChanged(newTags);
                      },
                    );
                  }).toList(),
                ),
              ],
              
              // Filtreleri temizle
              if (widget.selectedCategory != null || widget.selectedTags.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onCategoryChanged(null);
                      widget.onTagsChanged([]);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Filtreleri Temizle'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
