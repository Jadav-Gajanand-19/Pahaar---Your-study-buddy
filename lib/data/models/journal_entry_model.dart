import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String? id;
  final Timestamp date;
  final String mood;
  final double energyLevel;
  final String gratitude;
  final String reflection;
  final String? keyLesson; // NEW

  JournalEntry({
    this.id,
    required this.date,
    required this.mood,
    required this.energyLevel,
    required this.gratitude,
    required this.reflection,
    this.keyLesson, // NEW
  });

  factory JournalEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return JournalEntry(
      id: snapshot.id,
      date: data['date'] ?? Timestamp.now(),
      mood: data['mood'] ?? 'Okay',
      energyLevel: (data['energyLevel'] as num?)?.toDouble() ?? 3.0,
      gratitude: data['gratitude'] ?? '',
      reflection: data['reflection'] ?? '',
      keyLesson: data['keyLesson'], // NEW
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'mood': mood,
      'energyLevel': energyLevel,
      'gratitude': gratitude,
      'reflection': reflection,
      'keyLesson': keyLesson, // NEW
    };
  }
}