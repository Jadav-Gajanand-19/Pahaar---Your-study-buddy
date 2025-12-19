import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/core/services/analytics_service.dart';
import 'package:prahar/providers/firestore_providers.dart';
import 'package:prahar/providers/auth_providers.dart';

/// Analytics Service Provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return AnalyticsService(firestoreService);
});

/// Selected Month Provider for Intel Report
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Mock Test Analytics Provider
final mockTestAnalyticsProvider = FutureProvider.autoDispose((ref) async {
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return null;
  
  final month = ref.watch(selectedMonthProvider);
  final monthStart = DateTime(month.year, month.month, 1);
  final monthEnd = DateTime(month.year, month.month + 1, 1);
  
  final service = ref.watch(analyticsServiceProvider);
  return await service.getMockTestAnalytics(user.uid, monthStart, monthEnd);
});

/// Week Comparison Provider
final weekComparisonProvider = FutureProvider.autoDispose((ref) async {
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return null;
  
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  
  final service = ref.watch(analyticsServiceProvider);
  return await service.compareWeeks(user.uid, weekStart);
});

/// Best Week Provider
final bestWeekProvider = FutureProvider.autoDispose((ref) async {
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return null;
  
  final service = ref.watch(analyticsServiceProvider);
  return await service.getBestWeek(user.uid);
});

/// Month Analytics Provider  
final monthAnalyticsProvider = FutureProvider.autoDispose((ref) async {
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return null;
  
final month = ref.watch(selectedMonthProvider);
  
  final service = ref.watch(analyticsServiceProvider);
  return await service.getMonthAnalytics(user.uid, month);
});
