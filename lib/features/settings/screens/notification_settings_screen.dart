import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prahar/core/services/notification_service.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';
import 'package:prahar/providers/settings_providers.dart';
import 'package:prahar/features/settings/models/user_settings_model.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await _notificationService.hasPermission();
    setState(() {
      _hasPermission = hasPermission;
    });
  }

  Future<void> _requestPermission() async {
    final granted = await _notificationService.requestPermission();
    setState(() {
      _hasPermission = granted;
    });
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permission denied. Enable it in system settings.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickTime(BuildContext context, String? currentTime, Function(String) onTimePicked) async {
    final TimeOfDay initialTime = currentTime != null
        ? TimeOfDay(
            hour: int.parse(currentTime.split(':')[0]),
            minute: int.parse(currentTime.split(':')[1]),
          )
        : const TimeOfDay(hour: 6, minute: 0);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onTimePicked(timeString);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangeProvider).value;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in')),
      );
    }

    final settingsAsync = ref.watch(userSettingsProvider);

    return Scaffold(
      backgroundColor: kLightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextDarkPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NOTIFICATION CONTROL',
          style: GoogleFonts.blackOpsOne(
            fontSize: 18,
            color: kTextDarkPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: settingsAsync.when(
        data: (settings) {
          // Create default settings if they don't exist
          if (settings == null) {
            // Initialize default settings in Firestore subcollection
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                final defaultSettings = UserSettings(
                  userId: user.uid,
                  displayName: user.displayName ?? 'Cadet',
                  email: user.email,
                  notificationsEnabled: true,
                  habitReminders: true,
                  studyReminders: true,
                  dailyChallengeReminders: true,
                  revisionReminders: true,
                  achievementNotifications: true,
                  darkModeEnabled: false,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await ref.read(firestoreServiceProvider).saveUserSettings(defaultSettings);
                print('✅ Default notification settings created');
              } catch (e) {
                print('Error creating default settings: $e');
              }
            });
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: kOlivePrimary),
                  SizedBox(height: 16),
                  Text('Initializing settings...'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Permission Status Card
                if (!_hasPermission)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'PERMISSION REQUIRED',
                                style: GoogleFonts.blackOpsOne(
                                  fontSize: 14,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Notification permission is not granted. Grant permission to receive alerts.',
                          style: GoogleFonts.lato(fontSize: 14, color: Colors.red.shade900),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _requestPermission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('GRANT PERMISSION', style: GoogleFonts.blackOpsOne(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                // Master Toggle
                _buildSectionHeader('MASTER CONTROL'),
                _buildSettingCard(
                  icon: Icons.notifications_active,
                  title: 'All Notifications',
                  subtitle: 'Enable or disable all notifications',
                  value: settings.notificationsEnabled,
                  onChanged: (value) {
                    ref.read(firestoreServiceProvider).updateUserSettings(
                      user.uid,
                      {'notificationsEnabled': value, 'updatedAt': DateTime.now()},
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Habit Reminders
                _buildSectionHeader('DIRECTIVE ALERTS'),
                _buildSettingCard(
                  icon: Icons.task_alt,
                  title: 'Habit Reminders',
                  subtitle: 'Get notified about your daily directives',
                  value: settings.habitReminders,
                  onChanged: settings.notificationsEnabled
                      ? (value) {
                          ref.read(firestoreServiceProvider).updateUserSettings(
                            user.uid,
                            {'habitReminders': value, 'updatedAt': DateTime.now()},
                          );
                        }
                      : null,
                ),

                const SizedBox(height: 12),

                // Revision Reminders
                _buildSettingCard(
                  icon: Icons.school,
                  title: 'Revision Alerts',
                  subtitle: 'Notifications when revision topics are due',
                  value: settings.revisionReminders,
                  onChanged: settings.notificationsEnabled
                      ? (value) {
                          ref.read(firestoreServiceProvider).updateUserSettings(
                            user.uid,
                            {'revisionReminders': value, 'updatedAt': DateTime.now()},
                          );
                        }
                      : null,
                ),

                const SizedBox(height: 24),

                // Daily Motivation
                _buildSectionHeader('DAILY BRIEFING'),
                _buildTimeSettingCard(
                  icon: Icons.wb_sunny,
                  title: 'Daily Motivation',
                  subtitle: settings.dailyMotivationTime != null
                      ? 'Scheduled at ${_formatTime(settings.dailyMotivationTime!)}'
                      : 'Not scheduled',
                  currentTime: settings.dailyMotivationTime,
                  enabled: settings.notificationsEnabled,
                  onTimePicked: (timeString) async {
                    await ref.read(firestoreServiceProvider).updateUserSettings(
                      user.uid,
                      {'dailyMotivationTime': timeString, 'updatedAt': DateTime.now()},
                    );
                    
                    // Schedule the notification
                    final parts = timeString.split(':');
                    final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
                    await _notificationService.scheduleDailyMotivation(time: time);
                  },
                  onClear: settings.dailyMotivationTime != null
                      ? () async {
                          await ref.read(firestoreServiceProvider).updateUserSettings(
                            user.uid,
                            {'dailyMotivationTime': null, 'updatedAt': DateTime.now()},
                          );
                          await _notificationService.cancelNotification(999999);
                        }
                      : null,
                ),

                const SizedBox(height: 24),

                // Achievement Notifications
                _buildSectionHeader('ACHIEVEMENT SYSTEM'),
                _buildSettingCard(
                  icon: Icons.emoji_events,
                  title: 'Achievement Alerts',
                  subtitle: 'Get notified when you unlock achievements',
                  value: settings.achievementNotifications,
                  onChanged: settings.notificationsEnabled
                      ? (value) {
                          ref.read(firestoreServiceProvider).updateUserSettings(
                            user.uid,
                            {'achievementNotifications': value, 'updatedAt': DateTime.now()},
                          );
                        }
                      : null,
                ),

                const SizedBox(height: 24),

                // Test Notification Button
                if (_hasPermission)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _notificationService.showAchievementNotification(
                          achievementTitle: 'Test Achievement',
                          achievementDescription: 'This is a test notification!',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Test notification sent!'),
                            backgroundColor: kOlivePrimary,
                          ),
                        );
                      },
                      icon: const Icon(Icons.send),
                      label: Text('SEND TEST NOTIFICATION', style: GoogleFonts.blackOpsOne(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOlivePrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: kOlivePrimary)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.blackOpsOne(
          fontSize: 12,
          color: kTextDarkSecondary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool)? onChanged,
  }) {
    final isEnabled = onChanged != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isEnabled ? kOlivePrimary.withOpacity(0.1) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isEnabled ? kOlivePrimary : Colors.grey, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.blackOpsOne(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isEnabled ? kTextDarkPrimary : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: isEnabled ? kTextDarkSecondary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: kOlivePrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String? currentTime,
    required bool enabled,
    required Function(String) onTimePicked,
    required VoidCallback? onClear,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: enabled ? kCommandGold.withOpacity(0.1) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: enabled ? kCommandGold : Colors.grey, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.blackOpsOne(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: enabled ? kTextDarkPrimary : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: enabled ? kTextDarkSecondary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (enabled) ...[
            if (onClear != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: onClear,
                color: Colors.red,
              ),
            IconButton(
              icon: const Icon(Icons.access_time, size: 24),
              onPressed: () => _pickTime(context, currentTime, onTimePicked),
              color: kOlivePrimary,
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
