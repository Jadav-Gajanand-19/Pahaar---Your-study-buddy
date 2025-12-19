import 'package:flutter/material.dart';
import 'package:prahar/data/models/study_session_model.dart';
import 'package:intl/intl.dart';

class SessionLogTile extends StatelessWidget {
  const SessionLogTile({
    super.key,
    required this.session,
    this.onDelete,
  });

  final StudySession session;
  final VoidCallback? onDelete;

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.military_tech_outlined, color: Theme.of(context).colorScheme.secondary),
            Text(_formatDuration(session.durationInSeconds), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        title: Text(session.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
        // --- MODIFIED: "Notes: " prefix is removed ---
        subtitle: Text(
          session.notes != null && session.notes!.isNotEmpty ? session.notes! : 'No notes added',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: onDelete,
                tooltip: 'Delete Session',
              )
            : null,
      ),
    );
  }
}