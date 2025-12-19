import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prahar/data/models/journal_entry_model.dart';
import 'package:prahar/features/reflection/screens/add_edit_entry_screen.dart';
import 'package:prahar/providers/firestore_providers.dart';
import 'package:table_calendar/table_calendar.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(journalEntriesStreamProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CDS ASPIRANT LOG',
              style: GoogleFonts.blackOpsOne(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'DAILY DEBRIEF',
              style: GoogleFonts.blackOpsOne(
                fontSize: 24,
                color: const Color(0xFF1E232C),
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF1E232C)),
              onPressed: () {},
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
             decoration: const BoxDecoration(
              color: Color(0xFF333D29), // Dark Olive
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.calendar_today, color: Color(0xFFFFD54F)), // Gold icon
              onPressed: () {
                // Toggle calendar view mode if needed, for now just an icon
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Weekly Calendar Strip
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            currentDay: DateTime.now(),
            calendarFormat: CalendarFormat.week,
            headerVisible: false,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
               _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              defaultTextStyle: GoogleFonts.lato(color: Colors.grey[600], fontWeight: FontWeight.bold),
              weekendTextStyle: GoogleFonts.lato(color: Colors.grey[600], fontWeight: FontWeight.bold),
              todayDecoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
              todayTextStyle: GoogleFonts.lato(color: const Color(0xFF556B2F), fontWeight: FontWeight.bold), // Highlight today text
              selectedDecoration: const BoxDecoration(
                color: Color(0xFFAFB42B), // Olive Gold
                shape: BoxShape.circle,
              ),
              selectedTextStyle: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: GoogleFonts.lato(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 12),
              weekendStyle: GoogleFonts.lato(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              DateFormat('MMMM yyyy').format(_focusedDay).toUpperCase(),
              style: GoogleFonts.blackOpsOne(
                fontSize: 12, 
                fontWeight: FontWeight.bold, 
                color: const Color(0xFF33691E),
                letterSpacing: 1.5
              ),
            ),
          ),

          const Divider(height: 1),

          // Journal Entries List
          Expanded(
            child: entriesAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                   return Center(child: Text('No logs found.', style: GoogleFonts.lato(color: Colors.grey)));
                }
                
                // Sort logs desc
                final sortedEntries = List<JournalEntry>.from(entries)..sort((a, b) => b.date.compareTo(a.date));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedEntries.length,
                  itemBuilder: (context, index) {
                    final entry = sortedEntries[index];
                    return _buildTimelineEntry(entry);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error loading logs: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        height: 64, width: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFAFB42B), // Olive Gold
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFAFB42B).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: IconButton(
          icon: const Icon(Icons.add, color: Colors.white, size: 32),
          onPressed: () => _navigateToEntryScreen(DateTime.now()),
        ),
      ),
    );
  }

  void _navigateToEntryScreen(DateTime date) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddEditEntryScreen(date: date),
    ));
  }

  Widget _buildTimelineEntry(JournalEntry entry) {
    final date = entry.date.toDate();
    final dayName = DateFormat('E').format(date).toUpperCase(); // TUE
    final dayNum = DateFormat('d').format(date); // 25
    final monthName = DateFormat('MMM').format(date).toUpperCase(); // NOV

    // Dynamic color indicator based on energy level
    Color statusColor;
    if (entry.energyLevel >= 4) statusColor = const Color(0xFF4CAF50); // Green
    else if (entry.energyLevel >= 3) statusColor = const Color(0xFFFFC107); // Amber
    else statusColor = const Color(0xFFE53935); // Red

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Column
            SizedBox(
              width: 50,
              child: Column(
                children: [
                  Text(dayName, style: GoogleFonts.blackOpsOne(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  Text(dayNum, style: GoogleFonts.blackOpsOne(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E232C), height: 1.0)),
                  Text(monthName, style: GoogleFonts.blackOpsOne(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[400])),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Dotted Line & Content
            Expanded(
               child: Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: const Color(0xFFFAFAFA), // Off-white/Surface
                   borderRadius: BorderRadius.circular(20),
                   border: Border.all(color: Colors.grey[200]!),
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Row(
                           children: [
                             Container(
                               width: 8, height: 8,
                               decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                             ),
                             const SizedBox(width: 8),
                             Text(
                               entry.mood.isNotEmpty ? entry.mood : "Debrief Log",
                               style: GoogleFonts.blackOpsOne(
                                 fontSize: 16, 
                                 fontWeight: FontWeight.bold, 
                                 color: const Color(0xFF1E232C)
                               ),
                             ),
                           ],
                         ),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             color: Colors.grey[100],
                             borderRadius: BorderRadius.circular(8),
                             border: Border.all(color: Colors.grey[300]!),
                           ),
                           child: Row(
                             children: [
                               const Icon(Icons.bolt, size: 14, color: Color(0xFFFDD835)), // Lightning
                               const SizedBox(width: 4),
                               Text(
                                 '${entry.energyLevel.toInt()}/5',
                                 style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                               ),
                             ],
                           ),
                         )
                       ],
                     ),
                     const SizedBox(height: 12),
                     Text(
                       '"${entry.reflection.isNotEmpty ? entry.reflection : entry.gratitude}"',
                       style: GoogleFonts.lato(
                         fontSize: 14,
                         fontStyle: FontStyle.italic,
                         color: const Color(0xFF546E7A), // Blue Grey
                         height: 1.4,
                       ),
                     ),
                   ],
                 ),
               ),
            ),
          ],
        ),
      ),
    );
  }
}
