import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/data/datasources/firestore_service.dart';
import 'package:prahar/core/services/xp_service.dart';
import 'package:prahar/core/services/achievement_service.dart';

import 'package:prahar/core/services/automation_service.dart';
import 'package:prahar/providers/firestore_providers.dart';
import 'package:prahar/providers/database_integration_providers.dart';

// XP Service Provider
final xpServiceProvider = Provider<XPService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return XPService(firestoreService);
});

// Achievement Service Provider
final achievementServiceProvider = Provider<AchievementService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final xpService = ref.watch(xpServiceProvider);
  return AchievementService(firestoreService, xpService);
});



/// Combined Automation Service Provider (with DB integration)
final automationServiceProvider = Provider<AutomationService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final xpService = ref.watch(xpServiceProvider);
  final achievementService = ref.watch(achievementServiceProvider);
  final dbIntegration = ref.watch(databaseIntegrationServiceProvider);
  
  return AutomationService(
    firestoreService,
    xpService,
    achievementService,
    dbIntegration,
  );
});
