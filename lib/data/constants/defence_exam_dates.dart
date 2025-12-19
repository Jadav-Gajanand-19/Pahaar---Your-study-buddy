import 'package:prahar/data/models/calendar_event_model.dart';

/// Pre-defined defence exam dates for CDS aspirants
/// Updated for 2025-2027
class DefenceExamDates {
  /// Get all defence exam dates from 2025-2027
  static List<CalendarEvent> getAllExamDates() {
    return [
      // CDS (Combined Defence Services) Exams
      _createExam('CDS I - 2025', DateTime(2025, 2, 9)),
      _createExam('CDS II - 2025', DateTime(2025, 9, 14)),
      _createExam('CDS I - 2026', DateTime(2026, 2, 8)),
      _createExam('CDS II - 2026', DateTime(2026, 9, 13)),
      _createExam('CDS I - 2027', DateTime(2027, 2, 7)),
      _createExam('CDS II - 2027', DateTime(2027, 9, 12)),

      // AFCAT (Air Force Common Admission Test)
      _createExam('AFCAT I - 2025 (Day 1)', DateTime(2025, 2, 22)),
      _createExam('AFCAT I - 2025 (Day 2)', DateTime(2025, 2, 23)),
      _createExam('AFCAT I - 2025 (Day 3)', DateTime(2025, 2, 24)),
      _createExam('AFCAT II - 2025 (Day 1)', DateTime(2025, 8, 23)),
      _createExam('AFCAT II - 2025 (Day 2)', DateTime(2025, 8, 24)),
      _createExam('AFCAT II - 2025 (Day 3)', DateTime(2025, 8, 25)),
      _createExam('AFCAT I - 2026 (Day 1)', DateTime(2026, 2, 21)),
      _createExam('AFCAT I - 2026 (Day 2)', DateTime(2026, 2, 22)),
      _createExam('AFCAT I - 2026 (Day 3)', DateTime(2026, 2, 23)),
      _createExam('AFCAT II - 2026 (Day 1)', DateTime(2026, 8, 22)),
      _createExam('AFCAT II - 2026 (Day 2)', DateTime(2026, 8, 23)),
      _createExam('AFCAT II - 2026 (Day 3)', DateTime(2026, 8, 24)),
      _createExam('AFCAT I - 2027 (Day 1)', DateTime(2027, 2, 20)),
      _createExam('AFCAT I - 2027 (Day 2)', DateTime(2027, 2, 21)),
      _createExam('AFCAT I - 2027 (Day 3)', DateTime(2027, 2, 22)),
      _createExam('AFCAT II - 2027 (Day 1)', DateTime(2027, 8, 21)),
      _createExam('AFCAT II - 2027 (Day 2)', DateTime(2027, 8, 22)),
      _createExam('AFCAT II - 2027 (Day 3)', DateTime(2027, 8, 23)),

      // TES (Technical Entry Scheme) - Army
      _createExam('Army TES - 2025', DateTime(2025, 6, 15)),
      _createExam('Army TES - 2026', DateTime(2026, 6, 14)),
      _createExam('Army TES - 2027', DateTime(2027, 6, 13)),

      // Indian Navy - INET (Indian Navy Entrance Test)
      _createExam('INET I - 2025', DateTime(2025, 2, 16)),
      _createExam('INET II - 2025', DateTime(2025, 8, 17)),
      _createExam('INET I - 2026', DateTime(2026, 2, 15)),
      _createExam('INET II - 2026', DateTime(2026, 8, 16)),
      _createExam('INET I - 2027', DateTime(2027, 2, 14)),
      _createExam('INET II - 2027', DateTime(2027, 8, 15)),

      // Indian Army - JAG (Judge Advocate General)
      _createExam('JAG Entry - 2025', DateTime(2025, 7, 20)),
      _createExam('JAG Entry - 2026', DateTime(2026, 7, 19)),
      _createExam('JAG Entry - 2027', DateTime(2027, 7, 18)),

      // Graduate Entry - UES (University Entry Scheme)
      _createExam('UES Final Year - 2025', DateTime(2025, 5, 25)),
      _createExam('UES Final Year - 2026', DateTime(2026, 5, 24)),
      _createExam('UES Final Year - 2027', DateTime(2027, 5, 23)),

      // CDSE (Combined Defence Services Examination) - Written Results
      _createExam('CDS I Results - 2025', DateTime(2025, 4, 15), isOfficial: true),
      _createExam('CDS II Results - 2025', DateTime(2025, 11, 20), isOfficial: true),
      _createExam('CDS I Results - 2026', DateTime(2026, 4, 14), isOfficial: true),
      _createExam('CDS II Results - 2026', DateTime(2026, 11, 19), isOfficial: true),
      _createExam('CDS I Results - 2027', DateTime(2027, 4, 13), isOfficial: true),
      _createExam('CDS II Results - 2027', DateTime(2027, 11, 18), isOfficial: true),

      // SSB (Service Selection Board) - Indicative dates for batches
      _createExam('SSB Allahabad - Batch Start', DateTime(2025, 3, 1), isOfficial: true),
      _createExam('SSB Bangalore - Batch Start', DateTime(2025, 3, 1), isOfficial: true),
      _createExam('SSB Bhopal - Batch Start', DateTime(2025, 3, 1), isOfficial: true),
      _createExam('SSB Allahabad - Batch Start', DateTime(2025, 10, 1), isOfficial: true),
      _createExam('SSB Bangalore - Batch Start', DateTime(2025, 10, 1), isOfficial: true),
      _createExam('SSB Bhopal - Batch Start', DateTime(2025, 10, 1), isOfficial: true),
    ];
  }

  /// Helper method to create exam event
  static CalendarEvent _createExam(String title, DateTime date, {bool isOfficial = false}) {
    return CalendarEvent(
      title: title,
      date: date,
      eventType: isOfficial ? EventType.official : EventType.testDay,
      description: isOfficial ? 'Results/Official Event' : 'Defence Examination',
    );
  }

  /// Get exams for a specific month
  static List<CalendarEvent> getExamsForMonth(DateTime month) {
    return getAllExamDates().where((exam) {
      return exam.date.year == month.year && exam.date.month == month.month;
    }).toList();
  }

  /// Get upcoming exams from today
  static List<CalendarEvent> getUpcomingExams({int count = 5}) {
    final now = DateTime.now();
    final upcoming = getAllExamDates()
        .where((exam) => exam.date.isAfter(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    return upcoming.take(count).toList();
  }
}
