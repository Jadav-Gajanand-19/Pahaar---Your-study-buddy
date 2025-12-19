import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/data/models/habit_challenge_model.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';

/// Dialog for creating a new 30/60-day habit challenge
void showAddHabitChallengeDialog(BuildContext context, WidgetRef ref) {
  final titleController = TextEditingController();
  int selectedDuration = 30; // Default to 30 days
  DateTime selectedStartDate = DateTime.now();

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            // Military-style header with gold accent
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kCommandGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.emoji_events, color: kCommandGold, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              'NEW CHALLENGE',
              style: GoogleFonts.blackOpsOne(
                fontSize: 20,
                color: kTextDarkPrimary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Create your mission directive',
              style: GoogleFonts.lato(
                fontSize: 13,
                color: kTextDarkSecondary,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Challenge Title
              Text(
                'CHALLENGE TITLE',
                style: GoogleFonts.blackOpsOne(
                  fontSize: 11,
                  color: kTextDarkSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'e.g., Morning Exercise, Daily Reading',
                  hintStyle: GoogleFonts.lato(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kCommandGold, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: GoogleFonts.lato(fontSize: 15),
              ),
              const SizedBox(height: 20),

              // Duration Selector
              Text(
                'DURATION',
                style: GoogleFonts.blackOpsOne(
                  fontSize: 11,
                  color: kTextDarkSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DurationButton(
                      label: '30 DAYS',
                      isSelected: selectedDuration == 30,
                      onTap: () => setState(() => selectedDuration = 30),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DurationButton(
                      label: '60 DAYS',
                      isSelected: selectedDuration == 60,
                      onTap: () => setState(() => selectedDuration = 60),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Start Date Picker
              Text(
                'START DATE',
                style: GoogleFonts.blackOpsOne(
                  fontSize: 11,
                  color: kTextDarkSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedStartDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 7)),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() => selectedStartDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${selectedStartDate.day}/${selectedStartDate.month}/${selectedStartDate.year}',
                        style: GoogleFonts.lato(fontSize: 15, color: kTextDarkPrimary),
                      ),
                      Icon(Icons.calendar_today, color: kCommandGold, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CANCEL', style: GoogleFonts.lato(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a challenge title')),
                );
                return;
              }

              final user = ref.read(authStateChangeProvider).value;
              if (user != null) {
                final challenge = HabitChallenge(
                  title: titleController.text.trim(),
                  duration: selectedDuration,
                  startDate: Timestamp.fromDate(selectedStartDate),
                  createdAt: Timestamp.now(),
                );

                ref.read(firestoreServiceProvider).addHabitChallenge(user.uid, challenge);
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Challenge created! $selectedDuration days to victory!'),
                    backgroundColor: kMilitaryGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kCommandGold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('CREATE CHALLENGE', style: GoogleFonts.blackOpsOne(fontSize: 12)),
          ),
        ],
      ),
    ),
  );
}

/// Duration selection button widget
class _DurationButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? kCommandGold : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kCommandGold : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.blackOpsOne(
              fontSize: 13,
              color: isSelected ? Colors.black : kTextDarkSecondary,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
