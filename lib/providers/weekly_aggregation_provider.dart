import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/core/services/weekly_aggregation_service.dart';
import 'package:prahar/providers/firestore_providers.dart';
import 'package:prahar/providers/database_integration_providers.dart';

/// Provider for Weekly Aggregation Service
final weeklyAggregationServiceProvider = Provider<WeeklyAggregationService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final dbIntegration = ref.watch(databaseIntegrationServiceProvider);
  return WeeklyAggregationService(firestoreService, dbIntegration);
});
