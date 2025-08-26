import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event.dart';
import '../services/hive_service.dart';
import '../theme/app_theme.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Hive servisinden etkinlikleri yükle
      print('EventCalendarScreen: Etkinlikler yükleniyor...');
      final events = HiveService.getAllEvents();
      print('EventCalendarScreen: ${events.length} etkinlik yüklendi');
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      print('EventCalendarScreen: Etkinlikler yüklenirken hata: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Etkinlikler yüklenirken hata oluştu: $e',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events.where((event) => 
      event.start.year == day.year &&
      event.start.month == day.month &&
      event.start.day == day.day
    ).toList();
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.lesson:
        return AppTheme.academicEvent;
      case EventType.exam:
        return AppTheme.highRisk;
      case EventType.club:
        return AppTheme.clubEvent;
      case EventType.other:
        return AppTheme.socialEvent;
    }
  }

  String _getEventTypeText(EventType type) {
    switch (type) {
      case EventType.lesson:
        return 'Ders';
      case EventType.exam:
        return 'Sınav';
      case EventType.club:
        return 'Kulüp';
      case EventType.other:
        return 'Diğer';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Etkinlik Takvimi",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  "Tüm etkinliklerini tek takvimde gör",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              boxShadow: AppTheme.cardShadow,
            ),
            child: TableCalendar<Event>(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: _getEventsForDay,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: TextStyle(
                  color: Colors.black, // Regular dates always black for readability
                ),
                weekendTextStyle: TextStyle(color: AppTheme.highRisk),
                holidayTextStyle: TextStyle(color: AppTheme.highRisk),
                selectedDecoration: BoxDecoration(
                  color: AppTheme.primaryPurple,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: AppTheme.primaryPurple,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                titleTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                formatButtonDecoration: BoxDecoration(
                  color: AppTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                formatButtonTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Expanded(
            child: _buildEventsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryPurple,
        onPressed: () {
          _showAddEventDialog();
        },
        child: Icon(Icons.add, color: AppTheme.cardBackground),
      ),
    );
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddEventDialog(
        onEventAdded: (event) async {
          print('Event ekleniyor: ${event.title}');
          try {
            // Hive'a kaydet
            print('HiveService.addEvent çağrılıyor...');
            await HiveService.addEvent(event);
            print('Event Hive\'a kaydedildi');
            
            // Local state'i güncelle
            setState(() {
              _events.add(event);
            });
            print('Local state güncellendi, toplam event sayısı: ${_events.length}');

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Etkinlik başarıyla eklendi',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }
          } catch (e) {
            print('Event eklenirken hata: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Etkinlik eklenirken hata oluştu: $e',
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

  Widget _buildEventsList() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryPurple),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Etkinlikler yükleniyor...',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final selectedEvents = _selectedDay != null 
        ? _getEventsForDay(_selectedDay!)
        : [];

    if (selectedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              _selectedDay != null
                  ? '${_selectedDay!.day.toString().padLeft(2, '0')}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.year} tarihinde etkinlik yok'
                  : 'Bir gün seçin',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Yeni etkinlik eklemek için + butonuna tıkla',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) {
        final event = selectedEvents[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            boxShadow: AppTheme.cardShadow,
            border: Border(
              left: BorderSide(
                color: _getEventColor(event.type),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingS,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getEventColor(event.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Text(
                        _getEventTypeText(event.type),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getEventColor(event.type),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      '${event.start.hour.toString().padLeft(2, '0')}:${event.start.minute.toString().padLeft(2, '0')} - ${event.end.hour.toString().padLeft(2, '0')}:${event.end.minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (event.location != null) ...[
                  const SizedBox(height: AppTheme.spacingS),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        event.location!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (event.note != null) ...[
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    event.note!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (event.tags.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingS),
                  Wrap(
                    spacing: AppTheme.spacingS,
                    children: event.tags.map((tag) => Container(
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
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AddEventDialog extends StatefulWidget {
  final Function(Event) onEventAdded;

  const _AddEventDialog({required this.onEventAdded});

  @override
  State<_AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<_AddEventDialog> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
  EventType _selectedType = EventType.other;
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  late TimeOfDay _selectedEndTime;

  @override
  void initState() {
    super.initState();
    // Güvenli şekilde bitiş saatini ayarla
    final now = TimeOfDay.now();
    final endHour = (now.hour + 1) % 24; // 24 saat formatında güvenli
    _selectedEndTime = TimeOfDay(hour: endHour, minute: now.minute);
  }

  void _updateEndTime(TimeOfDay newStartTime) {
    // Başlangıç saatinden 1 saat sonrasını güvenli şekilde hesapla
    final endHour = (newStartTime.hour + 1) % 24;
    setState(() {
      _selectedEndTime = TimeOfDay(hour: endHour, minute: newStartTime.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Yeni Etkinlik Ekle',
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
                labelText: 'Etkinlik Adı',
                border: const OutlineInputBorder(),
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              enableSuggestions: true,
              autocorrect: true,
            ),
            const SizedBox(height: 16),
            
            // Event Type
            DropdownButtonFormField<EventType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Etkinlik Türü',
                border: OutlineInputBorder(),
              ),
              items: EventType.values.map((type) {
                String label;
                switch (type) {
                  case EventType.lesson:
                    label = 'Ders';
                    break;
                  case EventType.exam:
                    label = 'Sınav';
                    break;
                  case EventType.club:
                    label = 'Kulüp';
                    break;
                  case EventType.other:
                    label = 'Diğer';
                    break;
                }
                return DropdownMenuItem(
                  value: type,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Date Selection
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedStartDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedStartDate = date;
                          _selectedEndDate = date;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      '${_selectedStartDate.day.toString().padLeft(2, '0')}-${_selectedStartDate.month.toString().padLeft(2, '0')}-${_selectedStartDate.year}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Time Selection
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _selectedStartTime,
                      );
                      if (time != null) {
                        setState(() {
                          _selectedStartTime = time;
                        });
                        // Bitiş saatini otomatik güncelle
                        _updateEndTime(time);
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedStartTime.format(context)),
                  ),
                ),
                const Text(' - '),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _selectedEndTime,
                      );
                      if (time != null) {
                        setState(() {
                          _selectedEndTime = time;
                        });
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedEndTime.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Konum (Opsiyonel)',
                border: const OutlineInputBorder(),
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              enableSuggestions: true,
              autocorrect: true,
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Not (Opsiyonel)',
                border: const OutlineInputBorder(),
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              enableSuggestions: true,
              autocorrect: true,
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
            backgroundColor: AppTheme.primaryPurple,
          ),
          child: Text(
            'Ekle',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Etkinlik adı zorunludur',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
      return;
    }

    // Start datetime
    final startDateTime = DateTime(
      _selectedStartDate.year,
      _selectedStartDate.month,
      _selectedStartDate.day,
      _selectedStartTime.hour,
      _selectedStartTime.minute,
    );

    // End datetime
    final endDateTime = DateTime(
      _selectedEndDate.year,
      _selectedEndDate.month,
      _selectedEndDate.day,
      _selectedEndTime.hour,
      _selectedEndTime.minute,
    );

    // Bitiş zamanının başlangıç zamanından sonra olduğunu kontrol et
    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bitiş zamanı başlangıç zamanından önce olamaz',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
      return;
    }

    final event = Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      title: title,
      start: startDateTime,
      end: endDateTime,
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    print('Event oluşturuldu: ${event.title}');
    
    // Event'i ekle ve dialog'u kapat
    widget.onEventAdded(event);
    
    // Dialog'u kapat
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
