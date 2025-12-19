import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/data/models/weekly_goal_model.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';

class ManageWeeklyGoalsScreen extends ConsumerWidget {
  const ManageWeeklyGoalsScreen({super.key});

  // Helper to get an icon based on category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'physical': return Icons.fitness_center;
      case 'mental': return Icons.psychology_outlined;
      case 'spiritual': return Icons.self_improvement;
      case 'educational': return Icons.school_outlined;
      default: return Icons.star_border_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(weeklyGoalsProvider);
    final user = ref.read(authStateChangeProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Weekly Goals"),
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return const Center(child: Text("No goals set for this week yet."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return Dismissible(
                key: ValueKey(goal.id!),
                direction: DismissDirection.horizontal,
                
                // Background for RIGHT swipe (Edit)
                background: Container(
                  color: Colors.blue.shade600,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                
                // Background for LEFT swipe (Delete)
                secondaryBackground: Container(
                  color: Colors.red.shade900,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete_forever, color: Colors.white),
                ),

                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) { // RIGHT swipe
                    _showAddOrEditGoalDialog(context, ref, goal: goal);
                    return false; // Don't dismiss
                  } else { // LEFT swipe
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: Text('Are you sure you want to delete the goal "${goal.title}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                        ],
                      ),
                    );
                  }
                },
                
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart && user != null) {
                    ref.read(firestoreServiceProvider).deleteWeeklyGoal(user.uid, goal.id!);
                  }
                },
                
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Icon(_getCategoryIcon(goal.category), color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(goal.category),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditGoalDialog(context, ref),
        child: const Icon(Icons.add),
        tooltip: 'Add Weekly Goal',
      ),
    );
  }
}

// This dialog function is now used for both Adding and Editing
void _showAddOrEditGoalDialog(BuildContext context, WidgetRef ref, {WeeklyGoal? goal}) {
  final isEditing = goal != null;
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController(text: isEditing ? goal.title : '');
  String selectedCategory = isEditing ? goal.category : 'Educational';
  final categories = ['Physical', 'Mental', 'Spiritual', 'Educational'];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(isEditing ? 'Edit Goal' : 'Add Weekly Goal'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Goal Title'),
                    validator: (v) => v!.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedCategory = value);
                    },
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final user = ref.read(authStateChangeProvider).value;
                    if (user == null) return;
                    
                    final firestoreService = ref.read(firestoreServiceProvider);

                    if (isEditing) {
                      firestoreService.updateWeeklyGoal(
                        user.uid,
                        goal.id!,
                        title: titleController.text.trim(),
                        category: selectedCategory,
                      );
                    } else {
                      final newGoal = WeeklyGoal(
                        title: titleController.text.trim(),
                        category: selectedCategory,
                        weekId: firestoreService.getWeekId(DateTime.now()),
                        createdAt: Timestamp.now(),
                      );
                      firestoreService.addWeeklyGoal(user.uid, newGoal);
                    }
                    Navigator.of(context).pop();
                  }
                },
                child: Text(isEditing ? 'Save Changes' : 'Add Goal'),
              ),
            ],
          );
        },
      );
    },
  );
}