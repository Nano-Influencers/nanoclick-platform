import 'package:flutter/material.dart';
class TreasureHunt extends StatelessWidget {
  const TreasureHunt({super.key, required this.controller, required this.kycCompleted});
  final PageController controller; final bool kycCompleted;
  @override Widget build(BuildContext context) => Card(child: ListTile(leading: const Icon(Icons.explore), title: const Text('Treasure Hunt'), subtitle: Text(kycCompleted ? 'This feature is being migrated to the backend.' : 'Complete KYC to unlock eligible rewards.')));
}
