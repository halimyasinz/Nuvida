import 'package:flutter/material.dart';

class TagInputWidget extends StatefulWidget {
  final List<String> tags;
  final Function(List<String>) onTagsChanged;
  final List<String>? suggestedTags; // Önerilen etiketler

  const TagInputWidget({
    super.key,
    required this.tags,
    required this.onTagsChanged,
    this.suggestedTags,
  });

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _tagFocusNode = FocusNode();

  @override
  void dispose() {
    _tagController.dispose();
    _tagFocusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !widget.tags.contains(tag.trim())) {
      final newTags = List<String>.from(widget.tags)..add(tag.trim());
      widget.onTagsChanged(newTags);
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    final newTags = List<String>.from(widget.tags)..remove(tag);
    widget.onTagsChanged(newTags);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiket girişi
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagController,
                  focusNode: _tagFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Etiket ekle...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (value) {
                    _addTag(value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _addTag(_tagController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Ekle'),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Mevcut etiketler
          if (widget.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.tags.map((tag) {
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
                  onDeleted: () => _removeTag(tag),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
          
          // Önerilen etiketler
          if (widget.suggestedTags != null && widget.suggestedTags!.isNotEmpty) ...[
            Text(
              'Önerilen etiketler:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: widget.suggestedTags!.where((tag) => !widget.tags.contains(tag)).map((tag) {
                return ActionChip(
                  label: Text(tag),
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                  onPressed: () => _addTag(tag),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
