import 'package:cloud_firestore/cloud_firestore.dart';

class RevisionTopic {
  final String? id;
  final String topicName;
  final String subject;
  final Timestamp lastRevisedOn;
  final Timestamp nextRevisionDue;
  final int revisionCount;
  final String revisionInterval;
  final String? reminderTime; // NEW: e.g., "18:30"

  RevisionTopic({
    this.id,
    required this.topicName,
    required this.subject,
    required this.lastRevisedOn,
    required this.nextRevisionDue,
    this.revisionCount = 0,
    required this.revisionInterval,
    this.reminderTime, // NEW
  });

  factory RevisionTopic.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return RevisionTopic(
      id: snapshot.id,
      topicName: data['topicName'] as String? ?? '',
      subject: data['subject'] as String? ?? '',
      lastRevisedOn: data['lastRevisedOn'] as Timestamp? ?? Timestamp.now(),
      nextRevisionDue: data['nextRevisionDue'] as Timestamp? ?? Timestamp.now(),
      revisionCount: data['revisionCount'] as int? ?? 0,
      revisionInterval: data['revisionInterval'] as String? ?? '7d',
      reminderTime: data['reminderTime'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'topicName': topicName,
      'subject': subject,
      'lastRevisedOn': lastRevisedOn,
      'nextRevisionDue': nextRevisionDue,
      'revisionCount': revisionCount,
      'revisionInterval': revisionInterval,
      'reminderTime': reminderTime, // NEW
    };
  }
}