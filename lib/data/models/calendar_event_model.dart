import 'package:cloud_firestore/cloud_firestore.dart';

enum EventType { official, user, testDay }

class CalendarEvent {
  final String? id;
  final String title;
  final DateTime date;
  final EventType eventType;
  final String? description;

  CalendarEvent({
    this.id,
    required this.title,
    required this.date,
    required this.eventType,
    this.description,
  });

  factory CalendarEvent.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return CalendarEvent(
      id: snapshot.id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      eventType: EventType.values.firstWhere((e) => e.toString() == data['eventType'], orElse: () => EventType.user),
      description: data['description'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'eventType': eventType.toString(),
      if (description != null) 'description': description,
    };
  }
}