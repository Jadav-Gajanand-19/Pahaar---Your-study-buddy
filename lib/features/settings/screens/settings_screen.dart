import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/features/settings/screens/profile_screen.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/settings_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';

/// Settings Screen - User preferences and configuration
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(userSettingsProvider);
    final user = ref.watch(authStateChangeProvider).value;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: kLightBackground,
      body: settingsAsync.when(
        data: (settings) => CustomScrollView(
          slivers: [
            // Custom App Bar with gradient
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: kCommandGold,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MISSION CONTROL',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'COMMAND SETTINGS',
                      style: AppTextStyles.commandTitle.copyWith(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Settings Content
            SliverToBoxAdapter(
              child: _buildSettingsContent(context, ref, settings, user?.uid),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading settings: $error'),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    WidgetRef ref,
    dynamic settings,
    String? userId,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Profile Section with enhanced design
        _buildSectionCard(
          context,
          title: 'PROFILE',
          icon: Icons.person,
          iconColor: kCommandGold,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Enhanced avatar with gradient border
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.goldAccent,
                      boxShadow: [
                        BoxShadow(
                          color: kCommandGold.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: kCommandGold,
                      child: Text(
                        settings?.displayName?.substring(0, 1).toUpperCase() ?? 'C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings?.displayName ?? 'Cadet',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'View personal record',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: kTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chevron
                  Icon(Icons.chevron_right, color: kCommandGold.withOpacity(0.5)),
                ],
              ),
            ),
          ],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Exam Configuration
        _buildSectionCard(
          context,
          title: 'EXAM CONFIGURATION',
          icon: Icons.school,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today, color: kCommandGold),
              title: const Text('Exam Date'),
              subtitle: Text(
                settings?.hasExamDate == true
                    ? '${settings!.examDate!.day}/${settings.examDate!.month}/${settings.examDate!.year}'
                    : 'Not set',
                style: AppTextStyles.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right, color: kCommandGold),
              onTap: () => _showExamDatePicker(context, ref, userId, settings?.examDate),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.military_tech, color: kCommandGold),
              title: const Text('Exam Type'),
              subtitle: Text(
                settings?.examTypeDisplay ?? 'Not set',
                style: AppTextStyles.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right, color: kCommandGold),
              onTap: () => _showExamTypePicker(context, ref, userId, settings?.examType),
            ),
            if (settings?.hasExamDate == true) ...[
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.timer, color: kStatusActive),
                title: const Text('Days Until Exam'),
                subtitle: Text(
                  '${settings!.getDaysUntilExam()} days remaining',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: kStatusActive,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 16),

        // Notifications
        _buildSectionCard(
          context,
          title: 'NOTIFICATIONS',
          icon: Icons.notifications,
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active, color: kCommandGold),
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive all notifications'),
              value: settings?.notificationsEnabled ?? true,
              activeColor: kCommandGold,
              onChanged: (value) {
                if (userId != null) {
                  ref.read(firestoreServiceProvider).updateUserSettings(
                    userId,
                    {'notificationsEnabled': value},
                  );
                }
              },
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.task_alt, color: kCommandGold),
              title: const Text('Daily Challenge Reminders'),
              subtitle: const Text('Get notified about daily challenges'),
              value: settings?.dailyChallengeReminders ?? true,
              activeColor: kCommandGold,
              onChanged: (value) {
                if (userId != null) {
                  ref.read(firestoreServiceProvider).updateUserSettings(
                    userId,
                    {'dailyChallengeReminders': value},
                  );
                }
              },
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.check_circle, color: kCommandGold),
              title: const Text('Habit Reminders'),
              subtitle: const Text('Get reminded to complete habits'),
              value: settings?.habitReminders ?? true,
              activeColor: kCommandGold,
              onChanged: (value) {
                if (userId != null) {
                  ref.read(firestoreServiceProvider).updateUserSettings(
                    userId,
                    {'habitReminders': value},
                  );
                }
              },
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.timer, color: kCommandGold),
              title: const Text('Study Reminders'),
              subtitle: const Text('Get reminded to study'),
              value: settings?.studyReminders ?? true,
              activeColor: kCommandGold,
              onChanged: (value) {
                if (userId != null) {
                  ref.read(firestoreServiceProvider).updateUserSettings(
                    userId,
                    {'studyReminders': value},
                  );
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Study Preferences
        _buildSectionCard(
          context,
          title: 'STUDY PREFERENCES',
          icon: Icons.book,
          children: [
            ListTile(
              leading: const Icon(Icons.wb_sunny, color: kCommandGold),
              title: const Text('Preferred Study Time'),
              subtitle: Text(
                settings?.preferredStudyTime ?? 'Not set',
                style: AppTextStyles.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right, color: kCommandGold),
              onTap: () => _showStudyTimePicker(context, ref, userId, settings?.preferredStudyTime),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.flag, color: kCommandGold),
              title: const Text('Daily Study Goal'),
              subtitle: Text(
                settings?.dailyStudyGoalMinutes != null
                    ? '${settings!.dailyStudyGoalMinutes} minutes'
                    : 'Not set',
                style: AppTextStyles.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right, color: kCommandGold),
              onTap: () => _showStudyGoalPicker(context, ref, userId, settings?.dailyStudyGoalMinutes),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Account Actions
        _buildSectionCard(
          context,
          title: 'ACCOUNT',
          icon: Icons.account_circle,
          children: [
            ListTile(
              leading: const Icon(Icons.logout, color: kStatusPriority),
              title: const Text('Sign Out'),
              onTap: () => _showSignOutDialog(context, ref),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // App Info
        Center(
          child: Column(
            children: [
              Text(
                'PRAHAAR',
                style: AppTextStyles.commandTitle.copyWith(
                  fontSize: 16,
                  color: kCommandGold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0',
                style: AppTextStyles.bodySmall.copyWith(color: kTextSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    Color? iconColor,
    required List<Widget> children,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header with enhanced styling
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (iconColor ?? kCommandGold).withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor ?? kCommandGold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  void _showExamDatePicker(BuildContext context, WidgetRef ref, String? userId, DateTime? currentDate) async {
    if (userId == null) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kCommandGold,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: kTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await ref.read(firestoreServiceProvider).updateUserSettings(
        userId,
        {'examDate': picked},
      );
    }
  }

  void _showExamTypePicker(BuildContext context, WidgetRef ref, String? userId, String? currentType) {
    if (userId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Exam Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildExamTypeOption(context, ref, userId, 'CDS', 'Combined Defence Services'),
            _buildExamTypeOption(context, ref, userId, 'AFCAT', 'Air Force Common Admission Test'),
            _buildExamTypeOption(context, ref, userId, 'NDA', 'National Defence Academy'),
            _buildExamTypeOption(context, ref, userId, 'INET', 'Indian Navy Entrance Test'),
          ],
        ),
      ),
    );
  }

  Widget _buildExamTypeOption(BuildContext context, WidgetRef ref, String userId, String code, String name) {
    return ListTile(
      title: Text(code),
      subtitle: Text(name, style: const TextStyle(fontSize: 12)),
      onTap: () {
        ref.read(firestoreServiceProvider).updateUserSettings(
          userId,
          {'examType': code},
        );
        Navigator.pop(context);
      },
    );
  }

  void _showStudyTimePicker(BuildContext context, WidgetRef ref, String? userId, String? currentTime) {
    if (userId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preferred Study Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStudyTimeOption(context, ref, userId, 'Morning', '5 AM - 11 AM'),
            _buildStudyTimeOption(context, ref, userId, 'Afternoon', '12 PM - 4 PM'),
            _buildStudyTimeOption(context, ref, userId, 'Evening', '5 PM - 9 PM'),
            _buildStudyTimeOption(context, ref, userId, 'Night', '10 PM - 12 AM'),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyTimeOption(BuildContext context, WidgetRef ref, String userId, String time, String hours) {
    return ListTile(
      title: Text(time),
      subtitle: Text(hours, style: const TextStyle(fontSize: 12)),
      onTap: () {
        ref.read(firestoreServiceProvider).updateUserSettings(
          userId,
          {'preferredStudyTime': time},
        );
        Navigator.pop(context);
      },
    );
  }

  void _showStudyGoalPicker(BuildContext context, WidgetRef ref, String? userId, int? currentGoal) {
    if (userId == null) return;

    final goals = [30, 60, 90, 120, 180, 240, 300];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Study Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: goals.map((minutes) {
            return ListTile(
              title: Text('$minutes minutes'),
              subtitle: Text('${(minutes / 60).toStringAsFixed(1)} hours'),
              onTap: () {
                ref.read(firestoreServiceProvider).updateUserSettings(
                  userId,
                  {'dailyStudyGoalMinutes': minutes},
                );
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(authServiceProvider).signOut();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: kStatusPriority),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
