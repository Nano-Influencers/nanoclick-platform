import 'package:flutter/material.dart';
class TaskStreak extends StatelessWidget {
  final String endsIn; final bool checkedIn; final int streak; final PageController controller;
  const TaskStreak({super.key, required this.endsIn, required this.checkedIn, required this.streak, required this.controller});
  @override Widget build(BuildContext context) => Card(child: ListTile(leading: const Icon(Icons.local_fire_department), title: const Text('Task streak'), subtitle: Text('$streak day streak'), trailing: Text(checkedIn ? 'Checked in' : endsIn)));
}
