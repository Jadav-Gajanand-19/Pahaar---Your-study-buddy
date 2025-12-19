import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prahar/core/theme/theme.dart';

/// Success dialog shown after completing a study session
class StudySessionSuccessDialog extends StatefulWidget {
  final String duration;
  final int xpEarned;
  final String? achievements;

  const StudySessionSuccessDialog({
    super.key,
    required this.duration,
    required this.xpEarned,
    this.achievements,
  });

  @override
  State<StudySessionSuccessDialog> createState() => _StudySessionSuccessDialogState();
}

class _StudySessionSuccessDialogState extends State<StudySessionSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> motivationalQuotes = [
    "Knowledge is power. Well done, soldier! 📚",
    "Every minute of study is a step towards victory! 🎯",
    "Discipline beats motivation every time! 💪",
    "You're building the foundation for success! 🏗️",
    "Consistent effort leads to excellence! ⭐",
    "Your dedication will pay off! 🔥",
    "One session closer to your goal! 🎖️",
    "Strategic preparation wins battles! 📈",
    "Knowledge gained is never wasted! 💎",
    "Excellence is earned through persistence! 🏆",
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

    // Auto-dismiss after 3 seconds and redirect to home
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
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
                  kOlivePrimary.withOpacity(0.9),
                  kCommandGold.withOpacity(0.9),
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
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'MISSION COMPLETE!',
                  style: GoogleFonts.blackOpsOne(
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Duration
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Duration: ${widget.duration}',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // XP Earned
                if (widget.xpEarned > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars, color: kCommandGold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '+${widget.xpEarned} XP',
                        style: GoogleFonts.oswald(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Achievements
                if (widget.achievements != null && widget.achievements!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.achievements!,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Motivational Quote
                Text(
                  selectedQuote,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
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

/// Show the study session success dialog
/// Returns true if redirecting to home screen
Future<bool> showStudySessionSuccessDialog(
  BuildContext context, {
  required String duration,
  required int xpEarned,
  String? achievements,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (context) => StudySessionSuccessDialog(
      duration: duration,
      xpEarned: xpEarned,
      achievements: achievements,
    ),
  );
  return result ?? false;
}
