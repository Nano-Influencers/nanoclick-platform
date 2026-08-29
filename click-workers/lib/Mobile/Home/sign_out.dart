import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> showSignOutDialog(BuildContext context) async {
  final shouldSignOut = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text("No", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );

  if (shouldSignOut == true) {
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
