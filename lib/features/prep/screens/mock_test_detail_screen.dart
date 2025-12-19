import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prahar/data/models/mock_test_model.dart';

class MockTestDetailScreen extends StatelessWidget {
  const MockTestDetailScreen({super.key, required this.test});
  final MockTest test;

  IconData _getSubjectIcon(String subject) {
    final lowerCaseSubject = subject.toLowerCase();
    if (lowerCaseSubject.contains('math')) return Icons.functions;
    if (lowerCaseSubject.contains('science')) return Icons.science;
    if (lowerCaseSubject.contains('history')) return Icons.history_edu;
    if (lowerCaseSubject.contains('geography')) return Icons.map;
    if (lowerCaseSubject.contains('english')) return Icons.language;
    if (lowerCaseSubject.contains('gk')) return Icons.public;
    return Icons.menu_book;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = test.totalMarks > 0 ? (test.finalScore / test.totalMarks) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(test.subject),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_getSubjectIcon(test.subject), color: theme.colorScheme.primary, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(test.subject, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(DateFormat.yMMMd().add_jm().format(test.date.toDate()), style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),

            // Score Card
            Card(
              elevation: 0,
              color: theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                    Text('Overall Percentage (${test.finalScore.toStringAsFixed(2)} / ${test.totalMarks})'),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: percentage / 100, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ScoreTile(title: 'Correct', value: test.correctCount.toString(), color: Colors.green.shade700),
                        _ScoreTile(title: 'Incorrect', value: test.incorrectCount.toString(), color: Colors.red.shade900),
                        _ScoreTile(title: 'Unattempted', value: test.unattemptedCount.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Analysis
            if (test.strengths.isNotEmpty)
              _AnalysisSection(title: 'Strengths', items: test.strengths, icon: Icons.thumb_up_alt_outlined, color: Colors.green.shade700),
            if (test.weakAreas.isNotEmpty) ...[
              const SizedBox(height: 16),
              _AnalysisSection(title: 'Weak Areas', items: test.weakAreas, icon: Icons.thumb_down_alt_outlined, color: Colors.redAccent),
            ]
          ],
        ),
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({required this.title, required this.value, this.color});
  final String title;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _AnalysisSection extends StatelessWidget {
  const _AnalysisSection({required this.title, required this.items, required this.icon, required this.color});
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: items.map((item) => Chip(
            label: Text(item),
            backgroundColor: color.withOpacity(0.1),
            side: BorderSide(color: color.withOpacity(0.3)),
            labelStyle: TextStyle(color: color, fontSize: 12),
          )).toList(),
        ),
      ],
    );
  }
}