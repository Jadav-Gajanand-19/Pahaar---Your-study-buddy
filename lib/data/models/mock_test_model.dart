import 'package:cloud_firestore/cloud_firestore.dart';

class MockTest {
  final String? id;
  final String subject;
  final String topic; // Added topic field
  final Timestamp date;
  
  // New scoring fields
  final int correctCount;
  final int incorrectCount;
  final int unattemptedCount;
  final double totalMarks; // Max marks for the test (e.g., 100 for CDS, 300 for AFCAT)
  final String markingScheme; // "CDS", "AFCAT"
  final double finalScore; // The calculated score

  final List<String> strengths;
  final List<String> weakAreas;

  MockTest({
    this.id,
    required this.subject,
    this.topic = '', // Default to empty
    required this.date,
    required this.correctCount,
    required this.incorrectCount,
    required this.unattemptedCount,
    required this.totalMarks,
    required this.markingScheme,
    required this.finalScore,
    this.strengths = const [],
    this.weakAreas = const [],
  });

  factory MockTest.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return MockTest(
      id: snapshot.id,
      subject: data['subject'] ?? '',
      topic: data['topic'] ?? '', // Read topic
      date: data['date'] ?? Timestamp.now(),
      correctCount: data['correctCount'] ?? 0,
      incorrectCount: data['incorrectCount'] ?? 0,
      unattemptedCount: data['unattemptedCount'] ?? 0,
      totalMarks: (data['totalMarks'] as num?)?.toDouble() ?? 100.0,
      markingScheme: data['markingScheme'] ?? 'CDS',
      finalScore: (data['finalScore'] as num?)?.toDouble() ?? 0.0,
      strengths: List<String>.from(data['strengths'] ?? []),
      weakAreas: List<String>.from(data['weakAreas'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'subject': subject,
      'topic': topic, // Write topic
      'date': date,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'unattemptedCount': unattemptedCount,
      'totalMarks': totalMarks,
      'markingScheme': markingScheme,
      'finalScore': finalScore,
      'strengths': strengths,
      'weakAreas': weakAreas,
    };
  }
}