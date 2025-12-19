import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/data/datasources/firestore_service.dart';
import 'package:prahar/features/settings/models/user_settings_model.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';

// User Settings Provider
final userSettingsProvider = StreamProvider<UserSettings?>((ref) {
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return Stream.value(null);
  
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserSettingsStream(user.uid);
});

// Exam Date Provider (derived from settings)
final examDateProvider = Provider<DateTime?>((ref) {
  final settings = ref.watch(userSettingsProvider).value;
  return settings?.examDate;
});

// Days Until Exam Provider
final daysUntilExamProvider = Provider<int?>((ref) {
  final settings = ref.watch(userSettingsProvider).value;
  return settings?.getDaysUntilExam();
});

// Display Name Provider
final displayNameProvider = Provider<String>((ref) {
  final settings = ref.watch(userSettingsProvider).value;
  return settings?.displayName ?? 'Cadet';
});

// Notification Preferences Provider
final notificationsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(userSettingsProvider).value;
  return settings?.notificationsEnabled ?? true;
});
