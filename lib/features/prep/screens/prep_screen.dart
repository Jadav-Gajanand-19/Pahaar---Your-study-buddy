import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prahar/core/services/notification_service.dart';
import 'package:prahar/core/services/hybrid_notification_service.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/data/models/mock_test_model.dart';
import 'package:prahar/data/models/revision_topic_model.dart';
import 'package:prahar/features/prep/screens/mock_test_detail_screen.dart';
import 'package:prahar/features/quiz/models/question_model.dart';
import 'package:prahar/features/quiz/screens/quiz_session_screen.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';

class PrepScreen extends ConsumerStatefulWidget {
  const PrepScreen({super.key});

  @override
  ConsumerState<PrepScreen> createState() => _PrepScreenState();
}

class _PrepScreenState extends ConsumerState<PrepScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MISSION PREP',
                        style: GoogleFonts.blackOpsOne(
                          fontSize: 28,
                          color: kTextDarkPrimary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MOCK TESTS & ANALYSIS',
                        style: GoogleFonts.blackOpsOne(
                          fontSize: 12,
                          color: kTextDarkSecondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEBE2), // Light military beige
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events_outlined, color: kTextDarkPrimary, size: 24),
                  ),
                ],
              ),
            ),
            
            // Toggle Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: kTextDarkPrimary,
                unselectedLabelColor: kTextDarkSecondary,
                labelStyle: GoogleFonts.blackOpsOne(fontSize: 14, fontWeight: FontWeight.bold),
                unselectedLabelStyle: GoogleFonts.blackOpsOne(fontSize: 14, fontWeight: FontWeight.w500),
                indicatorPadding: const EdgeInsets.all(4),
                tabs: const [
                  Tab(text: 'Mock Tests'),
                  Tab(text: 'Revisions'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe to avoid gesture conflicts
                children: const [
                  MockTestsView(),
                  RevisionPlannerView(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentIndex == 0) {
            _showAddOrEditMockTestDialog(context, ref);
          } else {
            _showAddOrEditRevisionTopicDialog(context, ref);
          }
        },
        backgroundColor: kTextDarkPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// --- Mock Tests Tab ---
class MockTestsView extends ConsumerWidget {
  const MockTestsView({super.key});

  IconData _getSubjectIcon(String subject) {
    final lowerCaseSubject = subject.toLowerCase();
    if (lowerCaseSubject.contains('math')) return Icons.calculate_outlined;
    if (lowerCaseSubject.contains('science')) return Icons.science_outlined;
    if (lowerCaseSubject.contains('history')) return Icons.history_edu_outlined;
    if (lowerCaseSubject.contains('geography')) return Icons.public_outlined;
    if (lowerCaseSubject.contains('english')) return Icons.translate_outlined;
    if (lowerCaseSubject.contains('gk')) return Icons.lightbulb_outline;
    return Icons.menu_book_outlined;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsAsync = ref.watch(mockTestsProvider);
    final user = ref.read(authStateChangeProvider).value;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 96), // Added bottom padding for FAB
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT PERFORMANCE',
                style: GoogleFonts.blackOpsOne(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kTextDarkSecondary.withOpacity(0.6),
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                'View All Stats',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37), // Gold
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          testsAsync.when(
            data: (tests) {
              if (tests.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.leaderboard_outlined, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No mock tests logged yet', style: GoogleFonts.lato(color: Colors.grey[500])),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: tests.map((test) {
                  final scorePercentage = test.totalMarks > 0 ? (test.finalScore / test.totalMarks) * 100 : 0.0;
                  final isStrong = scorePercentage >= 75;
                  final isWeak = scorePercentage < 50;
                  final tagText = isStrong ? 'STRONG' : (isWeak ? 'WEAK' : 'AVERAGE');
                  final tagColor = isStrong ? const Color(0xFFE8F5E9) : (isWeak ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0));
                  final tagTextColor = isStrong ? Colors.green[700] : (isWeak ? Colors.red[700] : Colors.orange[800]);
                  final progressColor = isStrong ? const Color(0xFF00C853) : (isWeak ? Colors.redAccent : Colors.orange);

                  return Dismissible(
                    key: ValueKey(test.id!),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red[900],
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                       if (user != null) {
                          ref.read(firestoreServiceProvider).deleteMockTest(user.uid, test.id!);
                       }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kTextDarkPrimary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(_getSubjectIcon(test.subject), color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      test.subject,
                                      style: GoogleFonts.blackOpsOne(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: kTextDarkPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${scorePercentage.toInt()}%',
                                      style: GoogleFonts.blackOpsOne(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: kTextDarkPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    if(tagText != 'AVERAGE') // Only show Weak/Strong as per wireframe preference
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: tagColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        tagText,
                                        style: GoogleFonts.blackOpsOne(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: tagTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  test.topic.isNotEmpty ? test.topic : 'General Mock',
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: kTextDarkSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 12, color: kTextDarkSecondary.withOpacity(0.5)),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('MMM d, yyyy').format(test.date.toDate()),
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        color: kTextDarkSecondary.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Progress Bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: scorePercentage / 100,
                                    backgroundColor: Colors.grey[100],
                                    color: progressColor,
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}

// --- Revision Planner Tab ---
class RevisionPlannerView extends ConsumerWidget {
  const RevisionPlannerView({super.key});

  IconData _getSubjectIcon(String subject) {
    final lowerCaseSubject = subject.toLowerCase();
    if (lowerCaseSubject.contains('math')) return Icons.calculate_outlined;
    if (lowerCaseSubject.contains('science')) return Icons.science_outlined;
    if (lowerCaseSubject.contains('history')) return Icons.history_edu_outlined;
    if (lowerCaseSubject.contains('geography')) return Icons.public_outlined;
    if (lowerCaseSubject.contains('english')) return Icons.translate_outlined;
    if (lowerCaseSubject.contains('gk')) return Icons.lightbulb_outline;
    return Icons.menu_book_outlined;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(revisionTopicsProvider);
    final user = ref.read(authStateChangeProvider).value;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 96), // Added bottom padding for FAB
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OFFICER TRAINING ACADEMY',
                style: GoogleFonts.blackOpsOne(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: kTextDarkSecondary.withOpacity(0.6),
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          topicsAsync.when(
            data: (topics) {
              if (topics.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.menu_book_outlined, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No revision topics added yet', style: GoogleFonts.lato(color: Colors.grey[500])),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: topics.map((topic) {
                   final dueDate = topic.nextRevisionDue.toDate();
                   final lastRevised = topic.lastRevisedOn.toDate();
                   final now = DateTime.now();
                   final today = DateTime(now.year, now.month, now.day);
                   final isOverdue = dueDate.isBefore(today);
                   final isDueToday = dueDate.year == today.year && dueDate.month == today.month && dueDate.day == today.day;
                   
                   return Dismissible(
                    key: ValueKey(topic.id!),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red[900],
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                       if (user != null) {
                          NotificationService().cancelNotification(topic.id!.hashCode);
                          ref.read(firestoreServiceProvider).deleteRevisionTopic(user.uid, topic.id!);
                       }
                    },
                     child: Container(
                       margin: const EdgeInsets.only(bottom: 16),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(20),
                         boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                         ],
                       ),
                       child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           // Header Section with Subject and Icon
                           Padding(
                             padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                             child: Row(
                               children: [
                                  Icon(_getSubjectIcon(topic.subject), size: 20, color: const Color(0xFFD4AF37)), // Gold Icon
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          topic.subject.toUpperCase(),
                                          style: GoogleFonts.blackOpsOne(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: kTextDarkSecondary,
                                            letterSpacing: 1.0
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 1,
                                          height: 10,
                                          color: kTextDarkSecondary.withOpacity(0.2),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'NEXT: ${DateFormat('MMM d').format(topic.nextRevisionDue.toDate())}',
                                          style: GoogleFonts.blackOpsOne(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFD4AF37), // Gold
                                            letterSpacing: 0.5
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                               ],
                             ),
                           ),
                           
                           // Topic Title
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 20),
                             child: Text(
                               topic.topicName,
                               style: GoogleFonts.blackOpsOne(
                                 fontSize: 20, // Large Title
                                 fontWeight: FontWeight.bold,
                                 color: kTextDarkPrimary,
                               ),
                             ),
                           ),
                           const SizedBox(height: 8),
                           
                           // Last Revised Date
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 20),
                             child: Row(
                               children: [
                                 Icon(Icons.calendar_today, size: 14, color: Colors.grey[400]),
                                 const SizedBox(width: 6),
                                 Text(
                                   'Last Revised: ${DateFormat('MMM d, yyyy').format(lastRevised)}',
                                   style: GoogleFonts.lato(
                                     fontSize: 13,
                                     color: Colors.grey[500],
                                     fontWeight: FontWeight.w600,
                                   ),
                                 ),
                               ],
                             ),
                           ),
                           
                           const SizedBox(height: 20),
                           
                           // Action Footer
                           Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              border: Border(top: BorderSide(color: Color(0xFFF5F5F5))),
                            ),
                             child: Row(
                               children: [
                                 // Status Pill
                                 Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                   decoration: BoxDecoration(
                                     color: isOverdue ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0), // Red BG if overdue
                                     borderRadius: BorderRadius.circular(8),
                                   ),
                                   child: Row(
                                     children: [
                                       Icon(
                                         Icons.error_outline, 
                                         size: 16, 
                                         color: isOverdue ? Colors.red[700] : Colors.orange[800]
                                       ),
                                       const SizedBox(width: 8),
                                       Text(
                                         isOverdue ? 'OVERDUE' : (isDueToday ? 'DUE TODAY' : 'PENDING'),
                                         style: GoogleFonts.blackOpsOne(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isOverdue ? Colors.red[700] : Colors.orange[800],
                                            letterSpacing: 0.5
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                                 
                                 const SizedBox(width: 12),
                                 
                                  // Revised Button
                                  Expanded(
                                    child: InkWell(
                                      onTap: (isOverdue || isDueToday) ? () async {
                                        if (user != null) {
                                          final notificationService = NotificationService();
                                          await notificationService.cancelNotification(topic.id!.hashCode);
                                          final newDueDate = await ref.read(firestoreServiceProvider).markTopicAsRevised(user.uid, topic);

                                          // Show success message with next revision date
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '✅ Revised! Next revision: ${DateFormat('MMM d, yyyy').format(newDueDate)}',
                                                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                                                ),
                                                backgroundColor: const Color(0xFF2E7D32),
                                                duration: const Duration(seconds: 3),
                                              ),
                                            );
                                          }

                                          // Always reschedule notification using hybrid service
                                          final hybridService = ref.read(hybridNotificationServiceProvider);
                                          TimeOfDay? scheduleTime;
                                          if (topic.reminderTime != null) {
                                            final timeParts = topic.reminderTime!.split(':');
                                            scheduleTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
                                          }

                                          await hybridService.scheduleRevisionReminderHybrid(
                                            userId: user.uid,
                                            topicId: topic.id!,
                                            topicName: topic.topicName,
                                            subject: topic.subject,
                                            dueDate: newDueDate,
                                            reminderTime: scheduleTime, // Service now handles null by defaulting to morning
                                          );
                                        }
                                      } : null,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: (isOverdue || isDueToday) 
                                              ? const Color(0xFF2E7D32) 
                                              : Colors.grey[300],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              (isOverdue || isDueToday) ? Icons.check_circle : Icons.lock,
                                              color: (isOverdue || isDueToday) ? Colors.white : Colors.grey[600],
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              (isOverdue || isDueToday) ? 'REVISED TODAY' : 'LOCKED',
                                              style: GoogleFonts.blackOpsOne(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: (isOverdue || isDueToday) ? Colors.white : Colors.grey[600],
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                               ],
                             ),
                           ),
                         ],
                       ),
                     ),
                   );
                }).toList(),
              );
            },
           loading: () => const Center(child: CircularProgressIndicator()),
           error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}

// --- DIALOGS (Updated) ---
void _showAddOrEditMockTestDialog(BuildContext context, WidgetRef ref) {
  final formKey = GlobalKey<FormState>();
  final subjectController = TextEditingController();
  final topicController = TextEditingController(); 
  final totalMarksController = TextEditingController(text: '100');
  final correctController = TextEditingController(text: '0');
  final incorrectController = TextEditingController(text: '0');
  final unattemptedController = TextEditingController(text: '0');
  String markingScheme = 'CDS Marking Standard';
  
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Rainbow Top Border
            Container(
              height: 6,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.yellow, Colors.red],
                ),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Log New Mock Test',
                              style: GoogleFonts.blackOpsOne(
                                fontSize: 24, 
                                fontWeight: FontWeight.bold,
                                color: kTextDarkPrimary
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Record your mission progress',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: kTextDarkSecondary
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
              
                      // Subject
                      _buildLabel(Icons.bookmark, 'SUBJECT', const Color(0xFF00897B)),
                      TextFormField(
                        controller: subjectController,
                        decoration: _inputDecoration('e.g. General Knowledge'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      // Topic (Optional - added to match model even if not in image explicitly, keeping it useful)
                      _buildLabel(Icons.category, 'TOPIC (Optional)', Colors.blueGrey),
                       TextFormField(
                        controller: topicController,
                         decoration: _inputDecoration('e.g. Probability'),
                      ),
                      const SizedBox(height: 20),
              
                      // Date & Time
                      _buildLabel(Icons.calendar_today, 'TEST DATE & TIME', const Color(0xFF00897B)),
                      GestureDetector(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context, 
                            initialDate: selectedDate, 
                            firstDate: DateTime(2020), 
                            lastDate: DateTime(2030)
                          );
                          if(pickedDate != null) {
                             final pickedTime = await showTimePicker(context: context, initialTime: selectedTime);
                             if(pickedTime != null) {
                               setState(() {
                                 selectedDate = pickedDate;
                                 selectedTime = pickedTime;
                               });
                             }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MM/dd/yyyy, h:mm a').format(
                                  DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute)
                                ),
                                style: GoogleFonts.lato(fontSize: 16, color: kTextDarkPrimary),
                              ),
                              const Icon(Icons.calendar_month, color: kTextDarkPrimary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
              
                      // Marking Scheme
                      _buildLabel(Icons.tune, 'MARKING SCHEME', const Color(0xFF00897B)), // Using tune icon generic
                      DropdownButtonFormField<String>(
                         value: markingScheme,
                         items: ['CDS Marking Standard', 'AFCAT Marking Standard'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                         onChanged: (v) => setState(() => markingScheme = v!),
                         decoration: _inputDecoration(''),
                      ),
                      const SizedBox(height: 20),
              
                      // Total Marks
                      _buildLabel(Icons.functions, 'TOTAL MARKS', const Color(0xFF00897B)),
                      TextFormField(
                        controller: totalMarksController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('100'),
                      ),
                      const SizedBox(height: 20),
              
                      // Correct / Incorrect Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(Icons.check_circle, 'CORRECT', Colors.green),
                                TextFormField(
                                  controller: correctController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade100)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade300, width: 2)),
                                    fillColor: Colors.green.shade50.withOpacity(0.3), filled: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(Icons.cancel, 'INCORRECT', Colors.red),
                                TextFormField(
                                  controller: incorrectController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade100)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade300, width: 2)),
                                    fillColor: Colors.red.shade50.withOpacity(0.3), filled: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Unattempted
                      _buildLabel(Icons.radio_button_unchecked, 'UNATTEMPTED', Colors.grey),
                      TextFormField(
                        controller: unattemptedController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('0'),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey[100],
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Cancel', style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDarkSecondary)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                   final user = ref.read(authStateChangeProvider).value;
                                   if (user != null) {
                                      final double total = double.tryParse(totalMarksController.text) ?? 100;
                                      final int correct = int.tryParse(correctController.text) ?? 0;
                                      final int incorrect = int.tryParse(incorrectController.text) ?? 0;
                                      final int unattempted = int.tryParse(unattemptedController.text) ?? 0;
                                      
                                      double score = 0.0;
                                      if (markingScheme.contains('CDS')) {
                                         score = (correct * 0.83) - (incorrect * 0.27); // approx CDS logic per question if 120 q for 100 marks
                                         // Or simplicity: just use 1 for correct, -0.33 for wrong if not specified
                                         score = (correct * 1.0) - (incorrect * 0.33);
                                      } else {
                                         score = (correct * 3.0) - (incorrect * 1.0); // AFCAT usually
                                      }
                                      
                                      final newTest = MockTest(
                                        subject: subjectController.text.trim(),
                                        topic: topicController.text.trim(), // Save topic
                                        date: Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute)),
                                        correctCount: correct,
                                        incorrectCount: incorrect,
                                        unattemptedCount: unattempted,
                                        totalMarks: total,
                                        markingScheme: markingScheme,
                                        finalScore: score
                                      );
                                      ref.read(firestoreServiceProvider).addMockTest(user.uid, newTest);
                                   }
                                   Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E232C), // Dark Navy/Black from image
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Text('Save Log', style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Helper methods for the dialog
Widget _buildLabel(IconData icon, String text, Color color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.blackOpsOne(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.0)),
      ],
    ),
  );
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.lato(color: Colors.grey[400]),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kMilitaryGreen, width: 2)),
    filled: true,
    fillColor: Colors.white,
  );
}

void _showAddOrEditRevisionTopicDialog(BuildContext context, WidgetRef ref) {
  final topicController = TextEditingController();
  final subjectController = TextEditingController();
  String selectedInterval = '7d'; // Default: Weekly
  TimeOfDay? selectedReminderTime;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Rainbow Top Border
            Container(
              height: 6,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple, Colors.orange],
                ),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Add Revision Topic',
                            style: GoogleFonts.blackOpsOne(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: kTextDarkPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Schedule your study revision',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: kTextDarkSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Topic
                    _buildLabel(Icons.topic, 'TOPIC NAME', const Color(0xFF00897B)),
                    TextField(
                      controller: topicController,
                      decoration: _inputDecoration('e.g. Probability'),
                    ),
                    const SizedBox(height: 20),

                    // Subject
                    _buildLabel(Icons.book, 'SUBJECT', const Color(0xFF00897B)),
                    TextField(
                      controller: subjectController,
                      decoration: _inputDecoration('e.g. Mathematics'),
                    ),
                    const SizedBox(height: 20),

                    // Revision Frequency
                    _buildLabel(Icons.repeat, 'REVISION FREQUENCY', const Color(0xFF00897B)),
                    DropdownButtonFormField<String>(
                      value: selectedInterval,
                      items: const [
                        DropdownMenuItem(value: '1d', child: Text('Daily')),
                        DropdownMenuItem(value: '7d', child: Text('Weekly')),
                        DropdownMenuItem(value: '30d', child: Text('Monthly')),
                      ],
                      onChanged: (value) => setState(() => selectedInterval = value!),
                      decoration: _inputDecoration(''),
                    ),
                    const SizedBox(height: 20),

                    // Reminder Time (Optional)
                    _buildLabel(Icons.alarm, 'REMINDER TIME (Optional)', Colors.blueGrey),
                    GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => selectedReminderTime = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedReminderTime != null
                                  ? selectedReminderTime!.format(context)
                                  : 'No reminder set',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                color: selectedReminderTime != null
                                    ? kTextDarkPrimary
                                    : Colors.grey[400],
                              ),
                            ),
                            const Icon(Icons.access_time, color: kTextDarkPrimary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kTextDarkSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (topicController.text.isNotEmpty) {
                                final user = ref.read(authStateChangeProvider).value;
                                if (user != null) {
                                  // Calculate initial next due date based on interval
                                  final now = DateTime.now();
                                  DateTime nextDue;
                                  final value = int.parse(selectedInterval.substring(0, selectedInterval.length - 1));
                                  final unit = selectedInterval.substring(selectedInterval.length - 1);
                                  
                                  if (unit == 'd') {
                                    nextDue = now.add(Duration(days: value));
                                  } else if (unit == 'w') {
                                    nextDue = now.add(Duration(days: value * 7));
                                  } else if (unit == 'm') {
                                    nextDue = now.add(Duration(days: value * 30));
                                  } else {
                                    nextDue = now.add(const Duration(days: 7));
                                  }

                                  final newTopic = RevisionTopic(
                                    topicName: topicController.text.trim(),
                                    subject: subjectController.text.trim(),
                                    lastRevisedOn: Timestamp.now(),
                                    nextRevisionDue: Timestamp.fromDate(nextDue),
                                    revisionCount: 0,
                                    revisionInterval: selectedInterval,
                                    reminderTime: selectedReminderTime != null
                                        ? '${selectedReminderTime!.hour}:${selectedReminderTime!.minute}'
                                        : null,
                                  );
                                  
                                  final docRef = await ref.read(firestoreServiceProvider).addRevisionTopic(user.uid, newTopic);
                                  
                                  // Always schedule hybrid notification for revision reminders
                                  final hybridService = ref.read(hybridNotificationServiceProvider);
                                  await hybridService.scheduleRevisionReminderHybrid(
                                    userId: user.uid,
                                    topicId: docRef.id,
                                    topicName: topicController.text.trim(),
                                    subject: subjectController.text.trim(),
                                    dueDate: nextDue,
                                    reminderTime: selectedReminderTime, // Service now handles null by defaulting to morning
                                  );
                                }
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E232C),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: Text(
                              'Add Revision',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
