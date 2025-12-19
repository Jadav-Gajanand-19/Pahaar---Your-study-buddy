import 'package:cloud_firestore/cloud_firestore.dart';

class StudySession {
  final String? id;
  final String subject;
  final int durationInSeconds;
  final DateTime startTime;
  final DateTime? endTime;
  final String? notes;

  StudySession({
    this.id,
    required this.subject,
    required this.durationInSeconds,
    required this.startTime,
    this.endTime,
    this.notes,
  });

  // ADD THIS FACTORY CONSTRUCTOR
  factory StudySession.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return StudySession(
      id: snapshot.id,
      subject: data['subject'],
      durationInSeconds: data['durationInSeconds'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null ? (data['endTime'] as Timestamp).toDate() : null,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'subject': subject,
      'durationInSeconds': durationInSeconds,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'notes': notes,
    };
  }
}