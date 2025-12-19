import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String? id;
  final String title;
  final String category;
  final Timestamp createdAt; // This will now serve as our "Start Date"
  final String? reminderTime;

  Habit({
    this.id,
    required this.title,
    required this.category,
    required this.createdAt,
    this.reminderTime,
  });

  factory Habit.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Habit(
      id: snapshot.id,
      title: data['title'],
      category: data['category'],
      createdAt: data['createdAt'],
      reminderTime: data['reminderTime'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'createdAt': createdAt,
      'reminderTime': reminderTime,
    };
  }
}