import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:prahar/data/models/calendar_event_model.dart';
import 'package:prahar/data/models/habit_model.dart';
import 'package:prahar/data/models/habit_challenge_model.dart';
import 'package:prahar/data/models/journal_entry_model.dart';
import 'package:prahar/data/models/mock_test_model.dart';
import 'package:prahar/data/models/revision_topic_model.dart';
import 'package:prahar/data/models/study_session_model.dart';
import 'package:prahar/data/models/task_model.dart';
import 'package:prahar/data/models/weekly_goal_model.dart';
import 'package:prahar/features/fitness/models/workout_model.dart';
import 'package:prahar/features/gamification/models/leaderboard_model.dart';
import 'package:prahar/features/gamification/models/user_stats_model.dart';

import 'package:prahar/features/quiz/models/question_model.dart';
import 'package:prahar/features/settings/models/user_settings_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Task Methods ---
  Stream<List<Task>> getUncompletedTasks(String userId) {
    return _db.collection('users').doc(userId).collection('tasks').where('isCompleted', isEqualTo: false).orderBy('createdAt', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }
  Future<void> addTask(String userId, Task task) {
    return _db.collection('users').doc(userId).collection('tasks').add(task.toFirestore());
  }
  Future<void> updateTaskStatus(String userId, String taskId, bool isCompleted) {
    return _db.collection('users').doc(userId).collection('tasks').doc(taskId).update({'isCompleted': isCompleted});
  }
  Future<void> deleteTask(String userId, String taskId) {
    return _db.collection('users').doc(userId).collection('tasks').doc(taskId).delete();
  }
  Stream<List<Task>> getTasksForDateRange(String userId, DateTime start, DateTime end) {
    return _db.collection('users').doc(userId).collection('tasks').where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start)).where('createdAt', isLessThan: Timestamp.fromDate(end)).snapshots().map((snapshot) => snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // --- Study Session Methods ---
  Stream<List<StudySession>> getTodaysStudySessions(String userId) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = DateTime(now.year, now.month, now.day + 1);
    return getSessionsForDateRange(userId, startOfToday, endOfToday);
  }
  Stream<List<StudySession>> getSessionsForDateRange(String userId, DateTime start, DateTime end) {
    return _db.collection('users').doc(userId).collection('study_sessions').where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start)).where('startTime', isLessThan: Timestamp.fromDate(end)).snapshots().map((snapshot) => snapshot.docs.map((doc) => StudySession.fromFirestore(doc)).toList());
  }
  Future<DocumentReference> addStudySession(String userId, StudySession session) {
    return _db.collection('users').doc(userId).collection('study_sessions').add(session.toFirestore());
  }
  Future<void> deleteStudySession(String userId, String sessionId) {
    return _db.collection('users').doc(userId).collection('study_sessions').doc(sessionId).delete();
  }
  Future<void> updateStudySession(String userId, String sessionId, { required String subject, String? notes, }) {
    return _db.collection('users').doc(userId).collection('study_sessions').doc(sessionId).update({ 'subject': subject, 'notes': notes });
  }
  Stream<List<StudySession>> getSessionsForMonth(String userId, DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 1);
    return getSessionsForDateRange(userId, startOfMonth, endOfMonth);
  }

  // --- Habit Methods ---
  Stream<List<Habit>> getHabits(String userId) {
    return _db.collection('users').doc(userId).collection('habits').orderBy('createdAt', descending: false).snapshots().map((snapshot) => snapshot.docs.map((doc) => Habit.fromFirestore(doc)).toList());
  }
  Future<DocumentReference> addHabit(String userId, Habit habit) {
    return _db.collection('users').doc(userId).collection('habits').add(habit.toFirestore());
  }
  Future<void> updateHabit(String userId, String habitId, { String? title, String? category, String? reminderTime, }) {
    final dataToUpdate = <String, dynamic>{};
    if (title != null) dataToUpdate['title'] = title;
    if (category != null) dataToUpdate['category'] = category;
    dataToUpdate['reminderTime'] = reminderTime;
    return _db.collection('users').doc(userId).collection('habits').doc(habitId).update(dataToUpdate);
  }
  Future<void> deleteHabit(String userId, String habitId) {
    return _db.collection('users').doc(userId).collection('habits').doc(habitId).delete();
  }
  Future<void> toggleHabitCompletion(String userId, String habitId, bool isCompleted, DocumentSnapshot? logDoc) async {
    final now = DateTime.now();
    final date = Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    if (logDoc != null && logDoc.exists) {
      await logDoc.reference.update({'isCompleted': isCompleted});
    } else {
      await _db.collection('users').doc(userId).collection('habit_logs').add({'habitId': habitId,'date': date,'isCompleted': isCompleted,});
    }
  }
  Stream<List<Timestamp>> getHabitLogsForStreak(String userId, String habitId) {
    return _db.collection('users').doc(userId).collection('habit_logs').where('habitId', isEqualTo: habitId).where('isCompleted', isEqualTo: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()['date'] as Timestamp).toList());
  }
  Stream<List<DocumentSnapshot>> getHabitLogsForDateRange(String userId, DateTime start, DateTime end) {
    return _db.collection('users').doc(userId).collection('habit_logs').where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start)).where('date', isLessThan: Timestamp.fromDate(end)).snapshots().map((snapshot) => snapshot.docs);
  }
  
  // --- Habit Challenge Methods (30/60-Day Challenges) ---
  Stream<List<HabitChallenge>> getHabitChallenges(String userId) {
    return _db.collection('users').doc(userId).collection('habit_challenges')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => HabitChallenge.fromFirestore(doc)).toList());
  }

  Future<DocumentReference> addHabitChallenge(String userId, HabitChallenge challenge) {
    return _db.collection('users').doc(userId).collection('habit_challenges').add(challenge.toFirestore());
  }

  Future<void> updateHabitChallengeCompletion(String userId, String challengeId, int dayNumber, bool isCompleted) async {
    final docRef = _db.collection('users').doc(userId).collection('habit_challenges').doc(challengeId);
    
    // Update the specific day's completion status
    return docRef.update({
      'dailyCompletions.$dayNumber': isCompleted,
    });
  }

  Future<void> deleteHabitChallenge(String userId, String challengeId) {
    return _db.collection('users').doc(userId).collection('habit_challenges').doc(challengeId).delete();
  }
  

  // --- Mission Prep Methods ---
  Stream<List<MockTest>> getMockTests(String userId) {
    return _db.collection('users').doc(userId).collection('mock_tests')
        .orderBy('date', descending: true) // UPDATED to descending
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MockTest.fromFirestore(doc)).toList());
  }
  Future<void> addMockTest(String userId, MockTest test) {
    return _db.collection('users').doc(userId).collection('mock_tests').add(test.toFirestore());
  }
  Future<void> deleteMockTest(String userId, String testId) {
    return _db.collection('users').doc(userId).collection('mock_tests').doc(testId).delete();
  }
  Future<void> updateMockTest(String userId, String testId, MockTest test) {
    return _db.collection('users').doc(userId).collection('mock_tests').doc(testId).update(test.toFirestore());
  }
  Stream<List<RevisionTopic>> getRevisionTopics(String userId) {
    return _db.collection('users').doc(userId).collection('revision_topics').orderBy('nextRevisionDue').snapshots().map((snapshot) => snapshot.docs.map((doc) => RevisionTopic.fromFirestore(doc)).toList());
  }
  Future<DocumentReference> addRevisionTopic(String userId, RevisionTopic topic) {
    return _db.collection('users').doc(userId).collection('revision_topics').add(topic.toFirestore());
  }
  Future<void> deleteRevisionTopic(String userId, String topicId) {
    return _db.collection('users').doc(userId).collection('revision_topics').doc(topicId).delete();
  }
  Future<void> updateRevisionTopic(String userId, String topicId, { required String topicName, required String subject, required String revisionInterval, String? reminderTime, }) {
    return _db.collection('users').doc(userId).collection('revision_topics').doc(topicId).update({'topicName': topicName, 'subject': subject, 'revisionInterval': revisionInterval, 'reminderTime': reminderTime, });
  }
  Future<DateTime> markTopicAsRevised(String userId, RevisionTopic topic) async {
    final now = DateTime.now();
    late DateTime nextDueDate;
    final int value = int.parse(topic.revisionInterval.substring(0, topic.revisionInterval.length - 1));
    final String unit = topic.revisionInterval.substring(topic.revisionInterval.length - 1);
    if (unit == 'd') { nextDueDate = now.add(Duration(days: value)); } 
    else if (unit == 'w') { nextDueDate = now.add(Duration(days: value * 7)); } 
    else if (unit == 'm') { nextDueDate = now.add(Duration(days: value * 30)); } 
    else { nextDueDate = now.add(const Duration(days: 7)); }
    await _db.collection('users').doc(userId).collection('revision_topics').doc(topic.id).update({'lastRevisedOn': Timestamp.fromDate(now), 'nextRevisionDue': Timestamp.fromDate(nextDueDate), 'revisionCount': topic.revisionCount + 1,});
    return nextDueDate;
  }

  // --- Journal Methods ---
  Stream<List<JournalEntry>> getJournalEntries(String userId) {
    return _db.collection('users').doc(userId).collection('journal_entries').orderBy('date', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => JournalEntry.fromFirestore(doc)).toList());
  }
  Future<void> upsertJournalEntry(String userId, JournalEntry entry) {
    final docId = DateFormat('yyyy-MM-dd').format(entry.date.toDate());
    return _db.collection('users').doc(userId).collection('journal_entries').doc(docId).set(entry.toFirestore(), SetOptions(merge: true));
  }
  
  // --- Weekly Goal Methods ---
  String getWeekId(DateTime date) {
    final year = date.year;
    final weekNumber = (date.difference(DateTime(year, 1, 1)).inDays / 7).ceil();
    return '$year-$weekNumber';
  }
  Stream<List<WeeklyGoal>> getGoalsForCurrentWeek(String userId) {
    // Return all weekly goals - they persist until manually deleted
    // weekId is still stored for tracking purposes but doesn't filter display
    return _db
        .collection('users').doc(userId).collection('weekly_goals')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => WeeklyGoal.fromFirestore(doc)).toList());
  }
  Future<void> addWeeklyGoal(String userId, WeeklyGoal goal) {
    return _db.collection('users').doc(userId).collection('weekly_goals').add(goal.toFirestore());
  }
  Future<void> updateWeeklyGoal(String userId, String goalId, {required String title, required String category}) {
    return _db.collection('users').doc(userId).collection('weekly_goals').doc(goalId).update({'title': title, 'category': category});
  }
  Future<void> updateWeeklyGoalStatus(String userId, String goalId, bool isCompleted) {
    return _db.collection('users').doc(userId).collection('weekly_goals').doc(goalId).update({'isCompleted': isCompleted});
  }
  
  /// Update daily goal completion for a specific day
  Future<void> updateDailyGoalCompletion(String userId, String goalId, int dayOfWeek, bool isCompleted) {
    return _db.collection('users').doc(userId).collection('weekly_goals').doc(goalId).update({
      'dailyCompletions.$dayOfWeek': isCompleted,
    });
  }
  
  Future<void> deleteWeeklyGoal(String userId, String goalId) {
    return _db.collection('users').doc(userId).collection('weekly_goals').doc(goalId).delete();
  }

  // --- Ops Calendar Methods ---
  Stream<List<CalendarEvent>> getEventsForMonth(String userId, DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    return _db.collection('users').doc(userId).collection('calendar_events').where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth)).where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth)).snapshots().map((snapshot) => snapshot.docs.map((doc) => CalendarEvent.fromFirestore(doc)).toList());
  }
  Future<void> addUserEvent(String userId, CalendarEvent event) {
    return _db.collection('users').doc(userId).collection('calendar_events').add(event.toFirestore());
  }
  Future<void> deleteUserEvent(String userId, String eventId) {
    return _db.collection('users').doc(userId).collection('calendar_events').doc(eventId).delete();
  }
  Future<void> initializeOfficialEvents(String userId) async {
    final batch = _db.batch();
    final officialEvents = [
      CalendarEvent(title: 'CDS 1 (2026) Notification', date: DateTime(2025, 12, 10), eventType: EventType.official),
      CalendarEvent(title: 'CDS 1 (2026) Application Ends', date: DateTime(2025, 12, 30), eventType: EventType.official),
      CalendarEvent(title: 'CDS 1 (2026) Exam Day', date: DateTime(2026, 4, 12), eventType: EventType.official),
      CalendarEvent(title: 'AFCAT 1 (2026) Notification', date: DateTime(2025, 12, 1), eventType: EventType.official),
      CalendarEvent(title: 'AFCAT 1 (2026) Exam', date: DateTime(2026, 2, 15), eventType: EventType.official),
      CalendarEvent(title: 'TGC 143 Application Starts', date: DateTime(2025, 10, 8), eventType: EventType.official),
      CalendarEvent(title: 'TGC 143 Application Ends', date: DateTime(2025, 11, 6), eventType: EventType.official),
    ];
    for (final event in officialEvents) {
      final docRef = _db.collection('users').doc(userId).collection('calendar_events').doc();
      batch.set(docRef, event.toFirestore());
    }
    await batch.commit();
  }

  // --- Fitness Tracker Methods ---
  Stream<List<WorkoutModel>> getWorkouts(String userId) {
    return _db.collection('users').doc(userId).collection('workouts')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkoutModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<WorkoutModel>> getWorkoutsForDateRange(
      String userId, DateTime start, DateTime end) {
    return _db.collection('users').doc(userId).collection('workouts')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkoutModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<WorkoutModel>> getTodaysWorkouts(String userId) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = DateTime(now.year, now.month, now.day + 1);
    return getWorkoutsForDateRange(userId, startOfToday, endOfToday);
  }

  Future<void> addWorkout(String userId, WorkoutModel workout) {
    return _db.collection('users').doc(userId).collection('workouts')
        .add(workout.toFirestore());
  }

  Future<void> updateWorkout(String userId, String workoutId, WorkoutModel workout) {
    return _db.collection('users').doc(userId).collection('workouts')
        .doc(workoutId).update(workout.toFirestore());
  }

  Future<void> deleteWorkout(String userId, String workoutId) {
    return _db.collection('users').doc(userId).collection('workouts')
        .doc(workoutId).delete();
  }

  // Get personal best for a workout type
  Future<double?> getPersonalBest(String userId, WorkoutType type) async {
    final querySnapshot = await _db.collection('users').doc(userId).collection('workouts')
        .where('type', isEqualTo: type.toString())
        .orderBy('value', descending: true)
        .limit(1)
        .get();
    
    if (querySnapshot.docs.isEmpty) return null;
    return (querySnapshot.docs.first.data()['value'] as num).toDouble();
  }

  // Get workout streak (consecutive days with any workout)
  Future<int> getWorkoutStreak(String userId) async {
    final now = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day + 1);
      
      final querySnapshot = await _db.collection('users').doc(userId).collection('workouts')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        break;
      }
      streak++;
    }
    
    return streak;
  }
  
  // --- Quiz System Methods ---

  // Get questions by subject and difficulty
  Future<List<Question>> getQuestions({
    required CDSSubject subject,
    required DifficultyLevel difficulty,
    int limit = 10,
  }) async {
    final querySnapshot = await _db.collection('questions')
        .where('subject', isEqualTo: subject.toString())
        .where('difficulty', isEqualTo: difficulty.toString())
        .limit(limit)
        .get();

    return querySnapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();
  }

  // Save quiz session result
  Future<void> saveQuizSession(String userId, QuizSession session) {
    return _db.collection('users').doc(userId).collection('quiz_sessions')
        .add(session.toFirestore());
  }

  // Get user's quiz history
  Stream<List<QuizSession>> getUserQuizSessions(String userId) {
    return _db.collection('users').doc(userId).collection('quiz_sessions')
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuizSession.fromFirestore(doc))
            .toList());
  }




  // --- Gamification Methods ---

  // User Stats
  Stream<UserStats?> getUserStatsStream(String userId) {
    return _db.collection('users').doc(userId).collection('stats').doc('main')
        .snapshots()
        .map((doc) => doc.exists ? UserStats.fromFirestore(doc) : null);
  }

  Future<UserStats?> getUserStats(String userId) async {
    final doc = await _db.collection('users').doc(userId).collection('stats').doc('main').get();
    return doc.exists ? UserStats.fromFirestore(doc) : null;
  }

  Future<void> createUserStats(UserStats stats) {
    return _db.collection('users').doc(stats.userId).collection('stats').doc('main')
        .set(stats.toFirestore());
  }

  Future<void> updateUserStats(String userId, Map<String, dynamic> data) {
    return _db.collection('users').doc(userId).collection('stats').doc('main')
        .update(data);
  }



  // Leaderboards
  Future<void> updateLeaderboardEntry(String userId, LeaderboardEntry entry) {
    // Update independent collections for easier querying
    // rank is calculated dynamically on fetch, so we just store the score
    
    // We update multiple documents to support diff categories efficiently
    // This is a simplified approach. In a real app, you might use Cloud Functions.
    return _db.collection('leaderboards').doc('global').collection('entries').doc(userId).set({
       ...entry.toFirestore(),
       // Add specific fields for indexing if needed
    }, SetOptions(merge: true));
  }

  Future<List<LeaderboardEntry>> getLeaderboard({
    required LeaderboardCategory category,
    required LeaderboardPeriod period,
    int limit = 50,
  }) async {
    // Simplified query - assumes 'leaderboards/global/entries' has all data
    // In production, you'd likely have separate collections like 'leaderboards/xp_weekly', etc.
    // For now, sorting by the score field corresponding to the category
    
    String textField = 'score'; // Default to XP
    switch (category) {
      case LeaderboardCategory.xp: textField = 'score'; break;
      case LeaderboardCategory.studyHours: textField = 'studyHours'; break; // Need to ensure this exists in entry
      case LeaderboardCategory.challenges: textField = 'challengesCompleted'; break;
      case LeaderboardCategory.fitness: textField = 'workoutsCompleted'; break;
      case LeaderboardCategory.streak: textField = 'streak'; break;
    }

    final querySnapshot = await _db.collection('leaderboards').doc('global').collection('entries')
        .orderBy(textField, descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs.asMap().entries.map((e) {
      return LeaderboardEntry.fromFirestore(e.value.data(), e.key + 1);
    }).toList();
  }

  // --- Achievement Methods ---
  Stream<List<String>> getUnlockedAchievementIds(String userId) {
    return _db.collection('users').doc(userId).collection('achievements')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Future<void> unlockAchievement(String userId, String achievementId, DateTime unlockedAt) {
    return _db.collection('users').doc(userId).collection('achievements').doc(achievementId).set({
      'unlockedAt': Timestamp.fromDate(unlockedAt),
    });
  }

  // Add XP to user stats
  Future<void> addXp(String userId, int amount) async {
    final docRef = _db.collection('users').doc(userId).collection('stats').doc('main');
    
    return _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      
      if (!snapshot.exists) {
        // Create new stats if not exists
        transaction.set(docRef, {
          'userId': userId,
          'xp': amount,
          'level': 1,
          'dailyChallengeStreak': 0,
          'totalChallengesCompleted': 0,
          'lastChallengeDate': Timestamp.now(),
        });
        return;
      }
      
      final currentXp = (snapshot.data()?['xp'] as int?) ?? 0;
      final newXp = currentXp + amount;
      
      // Simple level calculation: Level = floor(sqrt(newXp / 100)) + 1
      // e.g. 0-99 XP = Lvl 1, 100-399 = Lvl 2, 400-899 = Lvl 3
      final newLevel = (newXp / 500).floor() + 1; // Simplified linear-ish progression for MVP
      
      transaction.update(docRef, {
        'xp': newXp,
        'level': newLevel,
      });
    });
  }

  // --- User Settings Methods ---
  
  // Get user settings
  Stream<UserSettings?> getUserSettingsStream(String userId) {
    return _db.collection('users').doc(userId).collection('settings').doc('main')
        .snapshots()
        .map((doc) => doc.exists ? UserSettings.fromFirestore(doc) : null);
  }

  Future<UserSettings?> getUserSettings(String userId) async {
    final doc = await _db.collection('users').doc(userId).collection('settings').doc('main').get();
    return doc.exists ? UserSettings.fromFirestore(doc) : null;
  }

  // Create or update user settings
  Future<void> saveUserSettings(UserSettings settings) {
    return _db.collection('users').doc(settings.userId).collection('settings').doc('main')
        .set(settings.toFirestore(), SetOptions(merge: true));
  }

  // Update specific settings fields
  Future<void> updateUserSettings(String userId, Map<String, dynamic> updates) {
    updates['updatedAt'] = Timestamp.now();
    return _db.collection('users').doc(userId).collection('settings').doc('main')
        .update(updates);
  }

  // Initialize default settings for new user
  Future<void> initializeUserSettings(String userId, String email, String displayName) {
    final settings = UserSettings(
      userId: userId,
      displayName: displayName,
      email: email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return saveUserSettings(settings);
  }
}
