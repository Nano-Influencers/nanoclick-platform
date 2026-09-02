import 'package:flutter/material.dart';
import 'package:click_workers/services/api_client.dart';

/// `taskId` used to be an ambiguous "offendingUID" written straight into a
/// Firestore 'reports' collection with no moderation workflow attached to
/// it at all. The backend's POST /tasks/{task_id}/report is the real
/// equivalent — it's tied to admin review (see app/routers/admin.py's
/// reports/pending + uphold/dismiss endpoints), so a report here actually
/// goes somewhere now instead of sitting in an uninspected collection.
Future<void> showReportTaskDialog(
    BuildContext context, String taskId, String offendingSubtext) async {
  final TextEditingController reasonController = TextEditingController();

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Report Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Why are you reporting this task?"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Type your reason...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final reason = reasonController.text.trim();

              if (reason.isNotEmpty) {
                try {
                  await ApiClient.instance.reportTask(taskId, reason);
                } catch (_) {
                  // Reporting failure shouldn't block the worker from
                  // dismissing the dialog — they can try again from the
                  // task later if it matters.
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text("Report"),
          ),
        ],
      );
    },
  );
}
