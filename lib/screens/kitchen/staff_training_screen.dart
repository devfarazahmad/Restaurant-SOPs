import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaffTrainingScreen extends StatefulWidget {
  const StaffTrainingScreen({super.key});

  @override
  State<StaffTrainingScreen> createState() =>
      _StaffTrainingScreenState();
}

class _StaffTrainingScreenState
    extends State<StaffTrainingScreen> {
  static const String _storageKey =
      'kitchenops_training_schedule';

  List<Map<String, dynamic>> _trainings = [];

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrainings();
  }

  Future<void> _loadTrainings() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(_storageKey);

    if (data != null) {
      try {
        final decoded = jsonDecode(data);

        if (decoded is List) {
          _trainings = decoded
              .map(
                (item) => Map<String, dynamic>.from(item),
              )
              .toList();
        }
      } catch (_) {}
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveTrainings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _storageKey,
      jsonEncode(_trainings),
    );
  }

  List<Map<String, dynamic>> get _upcomingTrainings {
    final now = DateTime.now();

    final list = _trainings.where((training) {
      final date = DateTime.tryParse(
        training['date'] ?? '',
      );

      if (date == null) return false;

      return date.isAfter(
        DateTime(now.year, now.month, now.day - 1),
      );
    }).toList();

    list.sort((a, b) {
      final dateA = DateTime.parse(a['date']);
      final dateB = DateTime.parse(b['date']);

      return dateA.compareTo(dateB);
    });

    return list;
  }

  List<Map<String, dynamic>> get _selectedDayTrainings {
    return _trainings.where((training) {
      final date = DateTime.tryParse(
        training['date'] ?? '',
      );

      if (date == null) return false;

      return date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;
    }).toList();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF59E0B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null) return;

    setState(() {
      _selectedDate = selected;
    });
  }

  Future<void> _showTrainingForm({
    Map<String, dynamic>? existing,
  }) async {
    final titleController = TextEditingController(
      text: existing?['title'] ?? '',
    );

    final trainerController = TextEditingController(
      text: existing?['trainer'] ?? '',
    );

    final locationController = TextEditingController(
      text: existing?['location'] ?? '',
    );

    final notesController = TextEditingController(
      text: existing?['notes'] ?? '',
    );

    TimeOfDay selectedTime = _parseTime(
      existing?['time'],
    );

    DateTime selectedDate = existing != null
        ? DateTime.parse(existing['date'])
        : _selectedDate;

    final formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1D5DB),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          18,
                          12,
                          12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                existing == null
                                    ? 'Schedule Training'
                                    : 'Edit Training',
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: titleController,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Enter training title';
                                  }
                                  return null;
                                },
                                decoration:
                                    _inputDecoration(
                                  'Training Title',
                                  Icons.school_outlined,
                                ).copyWith(
                                  hintText:
                                      'e.g. Food Safety Training',
                                ),
                              ),

                              const SizedBox(height: 14),

                              InkWell(
                                onTap: () async {
                                  final date =
                                      await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime.now()
                                        .subtract(
                                      const Duration(days: 1),
                                    ),
                                    lastDate: DateTime(2100),
                                    builder:
                                        (context, child) {
                                      return Theme(
                                        data: Theme.of(context)
                                            .copyWith(
                                          colorScheme:
                                              const ColorScheme
                                                  .light(
                                            primary:
                                                Color(0xFFF59E0B),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (date != null) {
                                    setModalState(() {
                                      selectedDate = date;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration:
                                      _inputDecoration(
                                    'Training Date',
                                    Icons.calendar_month_outlined,
                                  ),
                                  child: Text(
                                    _formatDate(
                                      selectedDate,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              InkWell(
                                onTap: () async {
                                  final time =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: selectedTime,
                                  );

                                  if (time != null) {
                                    setModalState(() {
                                      selectedTime = time;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration:
                                      _inputDecoration(
                                    'Training Time',
                                    Icons.access_time_rounded,
                                  ),
                                  child: Text(
                                    selectedTime.format(context),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              TextFormField(
                                controller: trainerController,
                                decoration:
                                    _inputDecoration(
                                  'Trainer',
                                  Icons.person_outline_rounded,
                                ).copyWith(
                                  hintText:
                                      'Chef Master / Manager',
                                ),
                              ),

                              const SizedBox(height: 14),

                              TextFormField(
                                controller: locationController,
                                decoration:
                                    _inputDecoration(
                                  'Location',
                                  Icons.location_on_outlined,
                                ).copyWith(
                                  hintText:
                                      'Kitchen / Training Room',
                                ),
                              ),

                              const SizedBox(height: 14),

                              TextFormField(
                                controller: notesController,
                                maxLines: 4,
                                decoration:
                                    _inputDecoration(
                                  'Notes',
                                  Icons.notes_outlined,
                                ).copyWith(
                                  hintText:
                                      'Training details, topics or requirements',
                                ),
                              ),

                              const SizedBox(height: 25),

                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (!formKey.currentState!
                                        .validate()) {
                                      return;
                                    }

                                    final timeString =
                                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

                                    final training = {
                                      'id': existing?['id'] ??
                                          DateTime.now()
                                              .millisecondsSinceEpoch,
                                      'title':
                                          titleController.text.trim(),
                                      'date': DateTime(
                                        selectedDate.year,
                                        selectedDate.month,
                                        selectedDate.day,
                                      ).toIso8601String(),
                                      'time': timeString,
                                      'trainer':
                                          trainerController.text
                                              .trim(),
                                      'location':
                                          locationController.text
                                              .trim(),
                                      'notes':
                                          notesController.text.trim(),
                                    };

                                    if (existing == null) {
                                      _trainings.add(training);
                                    } else {
                                      final index =
                                          _trainings.indexWhere(
                                        (item) =>
                                            item['id'] ==
                                            existing['id'],
                                      );

                                      if (index != -1) {
                                        _trainings[index] =
                                            training;
                                      }
                                    }

                                    Navigator.pop(
                                      context,
                                      true,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.save_rounded,
                                  ),
                                  label: Text(
                                    existing == null
                                        ? 'Save Training'
                                        : 'Update Training',
                                  ),
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFF59E0B),
                                    foregroundColor:
                                        Colors.white,
                                    elevation: 0,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    trainerController.dispose();
    locationController.dispose();
    notesController.dispose();

    if (result == true) {
      await _saveTrainings();

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Training schedule saved successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  TimeOfDay _parseTime(dynamic value) {
    if (value == null) {
      return const TimeOfDay(
        hour: 10,
        minute: 0,
      );
    }

    final parts = value.toString().split(':');

    if (parts.length != 2) {
      return const TimeOfDay(
        hour: 10,
        minute: 0,
      );
    }

    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 10,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  Future<void> _deleteTraining(
    Map<String, dynamic> training,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Training?'),
          content: Text(
            'Remove "${training['title']}" from the schedule?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    _trainings.removeWhere(
      (item) => item['id'] == training['id'],
    );

    await _saveTrainings();

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        title: const Text(
          'Staff Training',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showTrainingForm();
            },
            icon: const Icon(
              Icons.add_rounded,
              color: Color(0xFFF59E0B),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showTrainingForm();
        },
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Schedule'),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF59E0B),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                5,
                20,
                100,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _calendarCard(),

                  const SizedBox(height: 25),

                  const Text(
                    'Selected Day',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_selectedDayTrainings.isEmpty)
                    _smallEmptyCard(
                      'No training scheduled for this day.',
                    )
                  else
                    ..._selectedDayTrainings.map(
                      _trainingCard,
                    ),

                  const SizedBox(height: 25),

                  const Text(
                    'Upcoming Training',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_upcomingTrainings.isEmpty)
                    _smallEmptyCard(
                      'No upcoming training sessions.',
                    )
                  else
                    ..._upcomingTrainings.map(
                      _trainingCard,
                    ),
                ],
              ),
            ),
    );
  }

  Widget _calendarCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFFF59E0B),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Training Calendar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(_selectedDate),
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: _pickDate,
                icon: const Icon(
                  Icons.edit_calendar_outlined,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: List.generate(
              7,
              (index) {
                final date = DateTime.now().add(
                  Duration(days: index),
                );

                final selected =
                    date.year == _selectedDate.year &&
                        date.month ==
                            _selectedDate.month &&
                        date.day == _selectedDate.day;

                final hasTraining =
                    _trainings.any((training) {
                  final trainingDate =
                      DateTime.tryParse(
                    training['date'] ?? '',
                  );

                  return trainingDate != null &&
                      trainingDate.year == date.year &&
                      trainingDate.month == date.month &&
                      trainingDate.day == date.day;
                });

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 2,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFF59E0B)
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _weekday(date),
                            style: TextStyle(
                              fontSize: 10,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasTraining
                                  ? (selected
                                      ? Colors.white
                                      : const Color(
                                          0xFFF59E0B,
                                        ))
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _trainingCard(Map<String, dynamic> training) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: Color(0xFFF59E0B),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  training['title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '${_formatDate(DateTime.parse(training['date']))} • ${_formatTime(training['time'])}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),

                if ((training['trainer'] ?? '')
                    .toString()
                    .isNotEmpty)
                  Text(
                    'Trainer: ${training['trainer']}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),

                if ((training['location'] ?? '')
                    .toString()
                    .isNotEmpty)
                  Text(
                    training['location'],
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showTrainingForm(
                  existing: training,
                );
              } else if (value == 'delete') {
                _deleteTraining(training);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallEmptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFF59E0B),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _weekday(DateTime date) {
    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return days[date.weekday - 1];
  }

  String _formatTime(String value) {
    final parts = value.split(':');

    if (parts.length != 2) return value;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    final time = TimeOfDay(
      hour: hour,
      minute: minute,
    );

    return time.format(context);
  }
}