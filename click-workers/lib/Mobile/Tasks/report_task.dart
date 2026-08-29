import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> showReportTaskDialog(
    BuildContext context, String offendingUID, String offendingSubtext) async {
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
                await FirebaseFirestore.instance.collection('reports').add({
                  'offendingUID': offendingUID,
                  'offendingSubtext': offendingSubtext,
                  'reason': reason,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                } // Close dialog after reporting
              }
            },
            child: const Text("Report"),
          ),
        ],
      );
    },
  );
}
