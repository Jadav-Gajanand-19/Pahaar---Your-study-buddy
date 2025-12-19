import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/data/models/calendar_event_model.dart';
import 'package:prahar/data/constants/defence_exam_dates.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangeProvider).value;
    if (user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    // Fetch events for the focused month
    final eventsAsync = ref.watch(eventsForMonthProvider((userId: user.uid, month: _focusedDay)));
    
    // Fetch study sessions for selected day
    final selectedDayStart = _selectedDay != null
        ? DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)
        : DateTime.now();
    final selectedDayEnd = selectedDayStart.add(const Duration(days: 1));
    final studySessionsAsync = ref.watch(studySessionsForDateRangeProvider((
      userId: user.uid,
      start: selectedDayStart,
      end: selectedDayEnd,
    )));

    // Fetch workouts for selected day
    final workoutsAsync = ref.watch(workoutsForDateRangeProvider((
      userId: user.uid,
      start: selectedDayStart,
      end: selectedDayEnd,
    )));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'OPS CALENDAR',
          style: GoogleFonts.blackOpsOne(
            color: Colors.black,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF556B2F), size: 28),
            onPressed: () {
              _showAddEventDialog(context, user.uid);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Calendar Wrapper
            Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                   // Custom Header with Navigation
                   Padding(
                     padding: const EdgeInsets.only(top: 24, bottom: 8),
                     child: Column(
                       children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             IconButton(
                               icon: const Icon(Icons.chevron_left, size: 32),
                               color: const Color(0xFF4C5E35),
                               onPressed: () {
                                 setState(() {
                                   _focusedDay = DateTime(
                                     _focusedDay.year,
                                     _focusedDay.month - 1,
                                   );
                                 });
                               },
                             ),
                             const SizedBox(width: 8),
                             Text(
                               DateFormat('MMMM yyyy').format(_focusedDay).toUpperCase(),
                               style: GoogleFonts.oswald(
                                 fontSize: 24,
                                 fontWeight: FontWeight.bold,
                                 color: const Color(0xFF1E232C),
                               ),
                             ),
                             const SizedBox(width: 8),
                             IconButton(
                               icon: const Icon(Icons.chevron_right, size: 32),
                               color: const Color(0xFF4C5E35),
                               onPressed: () {
                                 setState(() {
                                   _focusedDay = DateTime(
                                     _focusedDay.year,
                                     _focusedDay.month + 1,
                                   );
                                 });
                               },
                             ),
                           ],
                         ),
                         Text(
                           'OPS TRACKING',
                           style: GoogleFonts.oswald(
                             fontSize: 12,
                             fontWeight: FontWeight.bold,
                             color: const Color(0xFF76FF03),
                             letterSpacing: 2.0,
                           ),
                         ),
                       ],
                     ),
                   ),
                   
                   eventsAsync.when(
                     data: (userEvents) {
                       // Merge user events with defence exam dates for the focused month
                       final defenceExams = DefenceExamDates.getExamsForMonth(_focusedDay);
                       final allEvents = [...userEvents, ...defenceExams];
                       
                       return TableCalendar(
                       firstDay: DateTime.utc(2023, 1, 1),
                       lastDay: DateTime.utc(2030, 12, 31),
                       focusedDay: _focusedDay,
                       selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                       onDaySelected: (selectedDay, focusedDay) {
                         setState(() {
                           _selectedDay = selectedDay;
                           _focusedDay = focusedDay;
                         });
                       },
                       onPageChanged: (focusedDay) {
                         setState(() {
                           _focusedDay = focusedDay;
                         });
                       },
                       headerVisible: false,
                       calendarFormat: CalendarFormat.month,
                       startingDayOfWeek: StartingDayOfWeek.sunday,
                       daysOfWeekStyle: DaysOfWeekStyle(
                         weekdayStyle: GoogleFonts.oswald(fontWeight: FontWeight.bold, color: Colors.grey[400]),
                         weekendStyle: GoogleFonts.oswald(fontWeight: FontWeight.bold, color: Colors.grey[400]),
                       ),
                       calendarStyle: CalendarStyle(
                         defaultTextStyle: GoogleFonts.lato(color: const Color(0xFF1E232C), fontWeight: FontWeight.bold, fontSize: 16),
                         weekendTextStyle: GoogleFonts.lato(color: const Color(0xFF1E232C), fontWeight: FontWeight.bold, fontSize: 16),
                         outsideTextStyle: GoogleFonts.lato(color: Colors.grey[300]),
                       ),
                       calendarBuilders: CalendarBuilders(
                         todayBuilder: (context, day, focusedDay) {
                            return Center(
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text('${day.day}', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                              ),
                            );
                         },
                         selectedBuilder: (context, day, focusedDay) {
                           return Center(
                             child: Container(
                               width: 44, height: 44,
                               decoration: BoxDecoration(
                                 color: const Color(0xFF4C5E35),
                                 borderRadius: BorderRadius.circular(16),
                                 boxShadow: [BoxShadow(color: const Color(0xFF4C5E35).withOpacity(0.4), blurRadius: 8, offset: const Offset(0,4))],
                               ),
                               alignment: Alignment.center,
                               child: Text(
                                 '${day.day}',
                                 style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                               ),
                             ),
                           );
                         },
                         defaultBuilder: (context, day, focusedDay) {
                           // Check if day has events (including defence exams)
                           final dayEvents = allEvents.where((e) {
                             return e.date.year == day.year &&
                                    e.date.month == day.month &&
                                    e.date.day == day.day;
                           }).toList();

                           if (dayEvents.isNotEmpty) {
                             // Determine color based on event type
                             Color bgColor = const Color(0xFF4C5E35); // Default green
                             
                             if (dayEvents.any((e) => e.eventType == EventType.testDay)) {
                               bgColor = const Color(0xFFFF5252); // Red for test days
                             } else if (dayEvents.any((e) => e.eventType == EventType.official)) {
                               bgColor = const Color(0xFFFFC107); // Gold for official events
                             }

                             return Center(
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${day.day}',
                                      style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      width: 4, height: 4,
                                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    )
                                  ],
                                ),
                              ),
                            );
                           }
                           return null; 
                         },
                       ),
                     );
                     },
                     loading: () => const Center(child: CircularProgressIndicator()),
                     error: (err, stack) => TableCalendar(
                       firstDay: DateTime.utc(2023, 1, 1),
                       lastDay: DateTime.utc(2030, 12, 31),
                       focusedDay: _focusedDay,
                       selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                       onDaySelected: (selectedDay, focusedDay) {
                         setState(() {
                           _selectedDay = selectedDay;
                           _focusedDay = focusedDay;
                         });
                       },
                       headerVisible: false,
                       calendarFormat: CalendarFormat.month,
                       startingDayOfWeek: StartingDayOfWeek.sunday,
                     ),
                   ),
                   const SizedBox(height: 24),
                 ],
               ),
             ),
            
            // Event Alert Card - Show next upcoming event (including defence exams)
            eventsAsync.when(
              data: (userEvents) {
                final now = DateTime.now();
                // Merge user events with all defence exam dates
                final defenceExams = DefenceExamDates.getAllExamDates();
                final allEvents = [...userEvents, ...defenceExams];
                
                final upcomingEvents = allEvents.where((e) => e.date.isAfter(now)).toList();
                upcomingEvents.sort((a, b) => a.date.compareTo(b.date));

                if (upcomingEvents.isEmpty) {
                  return const SizedBox.shrink();
                }

                final nextEvent = upcomingEvents.first;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(16),
                    border: const Border(left: BorderSide(color: Color(0xFFFFC107), width: 6)),
                  ),
                  child: Row(
                    children: [
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               nextEvent.title,
                               style: GoogleFonts.oswald(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                             ),
                             const SizedBox(height: 4),
                             Text(
                               nextEvent.description ?? DateFormat('MMM dd, yyyy - h:mm a').format(nextEvent.date),
                               style: GoogleFonts.lato(color: Colors.grey[400], fontSize: 14),
                             ),
                           ],
                         ),
                       ),
                       const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFC107), size: 32),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 24),
            
            // Logs Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 4, height: 16, color: const Color(0xFF4C5E35)),
                      const SizedBox(width: 8),
                      Text(
                        'LOGS FOR ${DateFormat('dd MMM').format(_selectedDay ?? DateTime.now()).toUpperCase()}',
                        style: GoogleFonts.oswald(
                          fontSize: 14, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.grey[400], 
                          letterSpacing: 2.0
                        ),
                      ),
                    ],
                  ),
                  // Calculate total time from study sessions and workouts
                  studySessionsAsync.when(
                    data: (sessions) {
                      final totalMinutes = sessions.fold<int>(0, (sum, session) => sum + (session.durationInSeconds / 60).floor());
                      final hours = totalMinutes ~/ 60;
                      final minutes = totalMinutes % 60;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${hours}h ${minutes}m Total',
                          style: GoogleFonts.lato(color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (err, stack) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Log Items - Study Sessions
            studySessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No study sessions for this day',
                      style: GoogleFonts.lato(color: Colors.grey[400]),
                    ),
                  );
                }
                return Column(
                  children: sessions.map((session) {
                    final duration = session.durationInSeconds ~/ 60;
                    final hours = duration ~/ 60;
                    final minutes = duration % 60;
                    return _buildLogCard(
                      icon: Icons.menu_book_rounded,
                      title: session.subject,
                      tag: 'STUDY',
                      timeRange: DateFormat('HHmm').format(session.startTime),
                      duration: '${hours}h ${minutes}m',
                      isGold: false,
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
            ),

            // Log Items - Workouts
            workoutsAsync.when(
              data: (workouts) {
                return Column(
                  children: workouts.map((workout) {
                    return _buildLogCard(
                      icon: Icons.fitness_center,
                      title: workout.type.toString().split('.').last,
                      tag: 'FITNESS',
                      timeRange: DateFormat('HHmm').format(workout.date),
                      duration: workout.getFormattedValue(),
                      isGold: false,
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
            ),

            // Log Items - User Events + Defence Exams for selected day
            eventsAsync.when(
              data: (userEvents) {
                // Get defence exams for the focused month
                final defenceExams = DefenceExamDates.getExamsForMonth(_focusedDay);
                
                // Merge and filter for selected day
                final allEvents = [...userEvents, ...defenceExams];
                final dayEvents = allEvents.where((e) {
                  return _selectedDay != null &&
                         e.date.year == _selectedDay!.year &&
                         e.date.month == _selectedDay!.month &&
                         e.date.day == _selectedDay!.day;
                }).toList();
                
                return Column(
                  children: dayEvents.map((event) {
                    return _buildLogCard(
                      icon: event.eventType == EventType.testDay ? Icons.assignment : Icons.event,
                      title: event.title,
                      tag: event.eventType.toString().split('.').last.toUpperCase(),
                      timeRange: DateFormat('HHmm').format(event.date),
                      duration: event.eventType == EventType.testDay ? 'TEST DAY' : 'EVENT',
                      isGold: event.eventType == EventType.testDay,
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 32),
            Center(
              child: Text(
                '"SWEAT IN PEACE, BLEED LESS IN WAR"',
                style: GoogleFonts.oswald(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[300],
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, String userId) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = _selectedDay ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    EventType selectedType = EventType.user;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'ADD EVENT',
            style: GoogleFonts.oswald(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E232C),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Event Title',
                    hintText: 'Enter event title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.title, color: Color(0xFF4C5E35)),
                  ),
                ),
                const SizedBox(height: 16),

                // Description Field
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Enter description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.description, color: Color(0xFF4C5E35)),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Date Picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today, color: Color(0xFF4C5E35)),
                  title: Text(
                    'Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),

                // Time Picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time, color: Color(0xFF4C5E35)),
                  title: Text(
                    'Time: ${selectedTime.format(context)}',
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Event Type Selector
                Text(
                  'Event Type',
                  style: GoogleFonts.oswald(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: EventType.values.map((type) {
                    final isSelected = selectedType == type;
                    return ChoiceChip(
                      label: Text(
                        type.toString().split('.').last.toUpperCase(),
                        style: GoogleFonts.oswald(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF4C5E35),
                      backgroundColor: Colors.grey[200],
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            selectedType = type;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: GoogleFonts.oswald(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter event title')),
                  );
                  return;
                }

                // Combine date and time
                final eventDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                final event = CalendarEvent(
                  title: titleController.text.trim(),
                  date: eventDateTime,
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  eventType: selectedType,
                );

                try {
                  await ref.read(firestoreServiceProvider).addUserEvent(userId, event);
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Event "${event.title}" added successfully!'),
                        backgroundColor: const Color(0xFF4C5E35),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding event: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C5E35),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'ADD EVENT',
                style: GoogleFonts.oswald(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard({
    required IconData icon,
    required String title,
    required String tag,
    required String timeRange,
    required String duration,
    bool isGold = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
           Container(
             width: 48, height: 48,
             decoration: BoxDecoration(
               color: isGold ? const Color(0xFFFFF8E1) : const Color(0xFFF1F8E9),
               borderRadius: BorderRadius.circular(16),
             ),
             child: Icon(icon, color: isGold ? const Color(0xFFFF8F00) : const Color(0xFF33691E)),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   title,
                   style: GoogleFonts.oswald(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E232C)),
                 ),
                 const SizedBox(height: 6),
                 Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                       decoration: BoxDecoration(
                         color: isGold ? const Color(0xFFFFECB3) : const Color(0xFFDCEDC8),
                         borderRadius: BorderRadius.circular(4),
                       ),
                       child: Text(
                         tag,
                         style: GoogleFonts.oswald(
                           fontSize: 10, 
                           fontWeight: FontWeight.bold, 
                           color: isGold ? const Color(0xFFBF360C) : const Color(0xFF33691E)
                         ),
                       ),
                     ),
                     const SizedBox(width: 8),
                     Text(
                       timeRange,
                       style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold)
                     ),
                   ],
                 ),
               ],
             ),
           ),
           Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               Text(
                 duration,
                 style: GoogleFonts.oswald(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E232C)),
               ),
               Text(
                 'DURATION',
                 style: GoogleFonts.oswald(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400]),
               ),
             ],
           ),
        ],
      ),
    );
  }
}