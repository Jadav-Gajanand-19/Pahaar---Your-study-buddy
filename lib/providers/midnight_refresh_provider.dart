import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current date provider that automatically refreshes at midnight
/// This triggers all date-dependent providers to refresh
final currentDateProvider = StreamProvider<DateTime>((ref) {
  final controller = StreamController<DateTime>();
  Timer? midnightTimer;
  
  void emitCurrentDate() {
    final now = DateTime.now();
    controller.add(DateTime(now.year, now.month, now.day));
  }
  
  void scheduleMidnightRefresh() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);
    
    midnightTimer?.cancel();
    midnightTimer = Timer(durationUntilMidnight, () {
      emitCurrentDate();
      scheduleMidnightRefresh(); // Schedule next midnight
    });
  }
  
  // Emit current date immediately
  emitCurrentDate();
  
  // Schedule midnight refresh
  scheduleMidnightRefresh();
  
  ref.onDispose(() {
    midnightTimer?.cancel();
    controller.close();
  });
  
  return controller.stream;
});
