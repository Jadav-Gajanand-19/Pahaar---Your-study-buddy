import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/data/models/study_session_model.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';
import 'package:prahar/providers/automation_providers.dart';
import 'package:prahar/core/services/automation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prahar/features/tracking/widgets/study_session_success_dialog.dart';

class StudyTimerScreen extends ConsumerStatefulWidget {
  const StudyTimerScreen({
    super.key,
    this.restoredStartTime,
    this.restoredPreviouslyElapsed,
    this.restoredSubject,
  });

  final DateTime? restoredStartTime;
  final Duration? restoredPreviouslyElapsed;
  final String? restoredSubject;

  @override
  ConsumerState<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends ConsumerState<StudyTimerScreen> with TickerProviderStateMixin {
  Timer? _timer;
  DateTime? _startTime; // Track actual start time
  Duration _elapsedWhenPaused = Duration.zero; // Track elapsed time when paused
  bool _isTimerRunning = false;
  
  final _subjectController = TextEditingController(text: "General Studies");
  final _sectionController = TextEditingController(text: "Section II - History");
  
  // Calculate current elapsed duration based on actual time
  Duration get _elapsedDuration {
    if (_startTime == null) return _elapsedWhenPaused;
    if (_isTimerRunning) {
      return _elapsedWhenPaused + DateTime.now().difference(_startTime!);
    } else {
      // When paused, return the saved elapsed time
      return _elapsedWhenPaused;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.restoredStartTime != null) {
      // Restoration logic - timer was running before
      _startTime = widget.restoredStartTime;
      _elapsedWhenPaused = widget.restoredPreviouslyElapsed ?? Duration.zero;
      _isTimerRunning = true;
      
      _subjectController.text = widget.restoredSubject ?? "General Studies";
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subjectController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  void _startTimer() {
    // Set start time for this run segment
    _startTime = DateTime.now();
    
    setState(() {
      _isTimerRunning = true;
    });
    
    // Timer is only used to trigger UI updates, not to track time
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // UI will update automatically via the getter
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    
    // Save the current elapsed time when pausing
    if (_startTime != null) {
      _elapsedWhenPaused = _elapsedDuration;
      _startTime = null; // Reset start time for next resume
    }
    
    setState(() {
      _isTimerRunning = false;
    });
  }

  Future<void> _showEditDialog() async {
    final sController = TextEditingController(text: _subjectController.text);
    final secController = TextEditingController(text: _sectionController.text);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Mission Objective', style: GoogleFonts.blackOpsOne()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             TextField(controller: sController, decoration: const InputDecoration(labelText: 'Subject', hintText: 'General Studies')),
             TextField(controller: secController, decoration: const InputDecoration(labelText: 'Section', hintText: 'Section II - History')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              setState(() {
                _subjectController.text = sController.text;
                _sectionController.text = secController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  Future<void> _finishSession() async {
    // Capture the elapsed duration BEFORE stopping the timer
    // This ensures we get the correct time even if timer was running
    final Duration finalElapsedDuration = _elapsedDuration;
    
    _timer?.cancel();
    // Update elapsed time if timer was running
    if (_isTimerRunning && _startTime != null) {
      _elapsedWhenPaused = finalElapsedDuration;
      _startTime = null;
    }
    setState(() => _isTimerRunning = false);
    
    // Check if study duration is at least 1 minute
    if (finalElapsedDuration.inSeconds < 60) {
      // Too short to save
       if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session must be at least 1 minute to record.')));
         Navigator.pop(context);
       }
       return;
    }

    final bool? shouldSave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Mission Report', style: GoogleFonts.blackOpsOne()),
        content: Text('Mission lasted ${_formatDuration(_elapsedDuration)}. Save to logs?', style: GoogleFonts.lato()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('DISCARD', style: TextStyle(color: Colors.red)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: kOlivePrimary),
            child: const Text('SAVE RECORD'),
          ),
        ],
      ),
    );

    if (shouldSave == true && mounted) {
      final user = ref.read(authStateChangeProvider).value;
      if (user == null) return;
      
      final notesController = TextEditingController();
      final notes = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Debrief Notes', style: GoogleFonts.blackOpsOne()),
          content: TextField(
            controller: notesController,
            decoration: const InputDecoration(hintText: 'Key findings...'),
            maxLines: 3,
          ),
          actions: [
             TextButton(onPressed: () => Navigator.pop(context, ''), child: const Text('Skip')),
             FilledButton(onPressed: () => Navigator.pop(context, notesController.text), child: const Text('Save Entry')),
          ],
        ),
      );

       // Save session to Firestore
      final session = StudySession(
        subject: _subjectController.text.trim(),
        durationInSeconds: _elapsedDuration.inSeconds,
        startTime: DateTime.now().subtract(_elapsedDuration),
        endTime: DateTime.now(),
        notes: notes ?? '',
      );
      
      // Save and get the document reference to get session ID
      final sessionRef = await ref.read(firestoreServiceProvider).addStudySession(user.uid, session);
      
      // Trigger automation for XP, achievements, and challenges WITH sessionId
      String? achievementsText;
      int xpEarned = 0;
      try {
        final automationResults = await ref.read(automationServiceProvider).onStudySessionComplete(
          user.uid,
          sessionRef.id, // NEW: Pass session ID for duplicate prevention
          _elapsedDuration.inMinutes,
        );
        
        // Extract XP and achievements from automation results
        if (automationResults.isNotEmpty) {
          achievementsText = AutomationService.formatResults(automationResults);
          // Try to extract XP from results (rough estimate)
          xpEarned = (_elapsedDuration.inMinutes / 30 * 10).floor();
        }
      } catch (e) {
        print('Automation error: $e');
        // Don't block the user flow if automation fails
      }
      
      // Show success dialog and redirect to home
      if (mounted) {
        await showStudySessionSuccessDialog(
          context,
          duration: _formatDuration(_elapsedDuration),
          xpEarned: xpEarned,
          achievements: achievementsText,
        );
        
        // Navigate back to home screen (pop all routes until first route)
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } else {
      // User chose to discard - just close the timer
      if (mounted) Navigator.pop(context);
    } 
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    // Show HH:MM:SS format to support up to 10 hours of study time
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // Check if session has started
    final hasStarted = _elapsedDuration.inSeconds > 0;
    
    return Scaffold(
      backgroundColor: kLightBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // 1. Top Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: kMilitaryGreen, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'SYSTEM ONLINE',
                              style: GoogleFonts.blackOpsOne(fontSize: 12, color: kTextDarkSecondary, letterSpacing: 1.5),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 20, color: kTextDarkPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 2. Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Battle Mode',
                            style: GoogleFonts.blackOpsOne(fontSize: 32, fontWeight: FontWeight.bold, color: kTextDarkPrimary),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 3. Mission Objective Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'MISSION OBJECTIVE',
                                  style: GoogleFonts.blackOpsOne(fontSize: 12, color: kTextDarkSecondary, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: kLimeAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: kLimeAccent),
                                  ),
                                  child: Text(
                                    'ACTIVE',
                                    style: GoogleFonts.blackOpsOne(fontSize: 10, color: kOlivePrimary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: kLightBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: kLimeAccent),
                                    ),
                                    child: const Icon(Icons.menu_book, color: kOlivePrimary),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _subjectController.text.isEmpty ? 'General Studies' : _subjectController.text,
                                          style: GoogleFonts.blackOpsOne(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDarkPrimary),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          _sectionController.text.isEmpty ? 'Section X' : _sectionController.text,
                                          style: GoogleFonts.lato(fontSize: 14, color: kTextDarkSecondary),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _showEditDialog,
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(color: kLightBackground, shape: BoxShape.circle),
                                      child: const Icon(Icons.edit, size: 16, color: kTextDarkSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // 4. Circular Timer Display
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Infinite rotating ring to show timer is active
                            if (_isTimerRunning)
                              SizedBox(
                                width: 300,
                                height: 300,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  backgroundColor: Colors.grey[100],
                                  valueColor: AlwaysStoppedAnimation<Color>(kLimeAccent.withOpacity(0.3)),
                                ),
                              ),
                            // Main progress ring
                            SizedBox(
                              width: 260,
                              height: 260,
                              child: CircularProgressIndicator(
                                value: null, // Indeterminate - shows continuous animation
                                strokeWidth: 8,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(kOlivePrimary),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'ELAPSED TIME',
                                  style: GoogleFonts.blackOpsOne(fontSize: 12, color: kOlivePrimary, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatDuration(_elapsedDuration),
                                  style: GoogleFonts.blackOpsOne(
                                    fontSize: 64,
                                    fontWeight: FontWeight.bold,
                                    color: kTextDarkPrimary,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: kLightBackground,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(width: 6, height: 6, decoration: BoxDecoration(color: _isTimerRunning ? kLimeAccent : Colors.grey, shape: BoxShape.circle)),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isTimerRunning ? 'IN PROGRESS' : 'PAUSED',
                                        style: GoogleFonts.blackOpsOne(fontSize: 10, color: kTextDarkSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: _isTimerRunning ? _pauseTimer : _startTimer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kOlivePrimary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 5,
                                  shadowColor: kOlivePrimary.withOpacity(0.4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
                                    const SizedBox(width: 12),
                                    Text(
                                      _isTimerRunning ? 'PAUSE MISSION' : (hasStarted ? 'RESUME MISSION' : 'START MISSION'),
                                      style: GoogleFonts.blackOpsOne(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (hasStarted) ...[ // Show finish button whenever timer has started
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton(
                                  onPressed: _finishSession,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: kTextDarkPrimary,
                                    side: const BorderSide(color: kTextDarkSecondary),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: Text(
                                    'FINISH MISSION',
                                    style: GoogleFonts.blackOpsOne(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
