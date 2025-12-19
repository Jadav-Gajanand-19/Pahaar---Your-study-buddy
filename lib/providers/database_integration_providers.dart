import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/core/services/database_integration_service.dart';

/// Provider for Database Integration Service
final databaseIntegrationServiceProvider = Provider<DatabaseIntegrationService>((ref) {
  return DatabaseIntegrationService();
});
