import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prahar/core/theme/theme.dart';

/// Success dialog shown when completing a habit challenge day
class HabitChallengeSuccessDialog extends StatefulWidget {
  const HabitChallengeSuccessDialog({super.key});

  @override
  State<HabitChallengeSuccessDialog> createState() => _HabitChallengeSuccessDialogState();
}

class _HabitChallengeSuccessDialogState extends State<HabitChallengeSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> motivationalQuotes = [
    "One day at a time. You're crushing it! 💪",
    "Discipline today, victory tomorrow! 🎯",
    "Small wins lead to big victories! ⭐",
    "You showed up. That's what matters! 🔥",
    "Consistency is your superpower! ⚡",
    "Another day conquered, soldier! 🎖️",
    "Progress over perfection! 📈",
    "You're building an unstoppable habit! 🚀",
    "Day by day, you're getting stronger! 💎",
    "Excellence is a habit. Well done! 🏆",
  ];

  late String selectedQuote;

  @override
  void initState() {
    super.initState();
    selectedQuote = motivationalQuotes[Random().nextInt(motivationalQuotes.length)];
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kCommandGold.withOpacity(0.9),
                  kMilitaryGreen.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kCommandGold.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon with animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 2 * 3.14159, // Full rotation
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 80 * value,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'DAY COMPLETED!',
                  style: GoogleFonts.blackOpsOne(
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Motivational Quote
                Text(
                  selectedQuote,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Show the success dialog
void showHabitChallengeSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (context) => const HabitChallengeSuccessDialog(),
  );
}
