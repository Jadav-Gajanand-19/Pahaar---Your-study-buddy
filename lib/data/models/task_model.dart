import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String? id;
  final String title;
  final bool isCompleted;
  final Timestamp createdAt; // Renamed from dueDate

  Task({
    this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Task(
      id: snapshot.id,
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(), // Updated field
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt, // Updated field
    };
  }
}