import 'package:flutter/material.dart';

class TaskFilterWidget extends StatelessWidget {
  const TaskFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 12,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 375,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min, // So it wraps content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Filter',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Clear logic
                  },
                  child: const Text('Clear all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Category'),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              items: ['All', 'Content', 'Survey', 'Promo']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              value: 'All',
              onChanged: (val) {},
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            const Text('Period'),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              items: ['All', '7 days', '30 days']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              value: 'All',
              onChanged: (val) {},
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            const Text('Budget'),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              items: ['Any', '₦1000 - ₦5000', '₦5000+']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              value: 'Any',
              onChanged: (val) {},
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }
}
