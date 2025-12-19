import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/providers/automation_enhancement_providers.dart';
import 'package:prahar/providers/auth_providers.dart';

/// Workout Plan Display Screen
/// Shows personalized workout plan with weekly schedule
class WorkoutPlanScreen extends ConsumerWidget {
  const WorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangeProvider).value;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout Plan')),
        body: const Center(child: Text('Please log in')),
      );
    }

    final planAsync = ref.watch(userWorkoutPlanProvider(user.uid));

    return Scaffold(
      backgroundColor: kLightBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SSB FITNESS PLAN',
              style: AppTextStyles.cardTitle.copyWith(
                color: kCommandGold,
                fontSize: 11,
                letterSpacing: 2.5,
              ),
            ),
            Text(
              'TRAINING PROTOCOL',
              style: AppTextStyles.sectionHeader.copyWith(fontSize: 22),
            ),
          ],
        ),
      ),
      body: planAsync.when(
        data: (plan) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppGradients.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kCommandGold, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name.toUpperCase(),
                              style: AppTextStyles.countdown.copyWith(fontSize: 28),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plan.description,
                              style: AppTextStyles.bodyMedium.copyWith(color: kTextSecondary),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: kCommandGold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            plan.level.toUpperCase(),
                            style: GoogleFonts.blackOpsOne(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: kCommandGold, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${plan.weeks} week program',
                          style: AppTextStyles.bodyMedium.copyWith(color: kTextPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Weekly Schedule Header
              Text(
                'WEEKLY SCHEDULE',
                style: AppTextStyles.sectionHeader,
              ),
              const SizedBox(height: 12),
              
              // Schedule Cards
              ...plan.weeklySchedule.entries.map((entry) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppGradients.goldAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key.toUpperCase(),
                            style: GoogleFonts.blackOpsOne(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: kCommandGold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.value,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: false,
                      onChanged: (val) {
                        // TODO: Track workout completion
                      },
                      activeColor: kMilitaryGreen,
                    ),
                  ],
                ),
              )),
              
              const SizedBox(height: 24),
              
              // SSB Standards Reference
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kMilitaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kMilitaryGreen.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SSB TARGET STANDARDS',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: kMilitaryGreen,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStandardRow('Running', '5 km'),
                    _buildStandardRow('Push-ups', '40 reps'),
                    _buildStandardRow('Sit-ups', '50 reps'),
                    _buildStandardRow('Pull-ups', '8 reps'),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: kCommandGold),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Unable to generate workout plan\n$e',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardRow(String exercise, String target) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            exercise,
            style: AppTextStyles.bodyMedium,
          ),
          Text(
            target,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: kMilitaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
