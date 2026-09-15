import 'package:flutter/material.dart';
import 'package:click_workers/Mobile/Wallet/filter_modal.dart';
import 'package:intl/intl.dart';
import 'package:click_workers/services/api_client.dart';

class WithdrawHistoryScreen extends StatefulWidget {
  const WithdrawHistoryScreen({super.key});

  @override
  State<WithdrawHistoryScreen> createState() => _WithdrawHistoryScreenState();
}

class _WithdrawHistoryScreenState extends State<WithdrawHistoryScreen> {
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String selectedStatus = 'All';

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filter',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.topCenter,
        child: FilterModal(
          selectedStatus: selectedStatus,
          minController: _minAmountController,
          maxController: _maxAmountController,
          onStatusChange: (status) => setState(() => selectedStatus = status),
        ),
      ),
      transitionBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween(begin: const Offset(0, -1), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
    );
  }

  bool _matchesStatus(String status) {
    switch (selectedStatus) {
      case 'Completed':
        return status == 'successful';
      case 'Pending':
        return status == 'requested' || status == 'processing';
      case 'Failed':
        return status == 'failed' || status == 'reversed';
      default:
        return true;
    }
  }

  List<dynamic> _applyFilters(List<dynamic> withdrawals) {
    final query = _searchController.text.trim().toLowerCase();
    final min = double.tryParse(_minAmountController.text.trim());
    final max = double.tryParse(_maxAmountController.text.trim());

    return withdrawals.where((item) {
      final data = item as Map<String, dynamic>;
      final status = (data['status'] ?? '').toString();
      final amount = (data['amount_ngn'] as num?)?.toDouble() ?? 0;
      final reference = (data['reference'] ?? '').toString().toLowerCase();
      final accountName = (data['account_name'] ?? '').toString().toLowerCase();
      final accountNumber = (data['account_number'] ?? '').toString().toLowerCase();

      if (!_matchesStatus(status)) return false;
      if (min != null && amount < min) return false;
      if (max != null && amount > max) return false;
      if (query.isNotEmpty &&
          !reference.contains(query) &&
          !accountName.contains(query) &&
          !accountNumber.contains(query)) return false;
      return true;
    }).toList();
  }

  String _displayStatus(String raw) {
    if (raw.isEmpty) return 'Unknown';
    return raw[0].toUpperCase() + raw.substring(1);
  }

  Color _statusColor(String raw) {
    if (raw == 'successful') return Colors.green;
    if (raw == 'requested' || raw == 'processing') return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Withdrawal History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search Withdrawals',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _showFilterModal,
                    child: Image.asset('assets/icons/filter_funnel.png'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<dynamic>>(
                future: ApiClient.instance.getWithdrawals(limit: 100),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.black));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final docs = _applyFilters(snapshot.data ?? []);
                  if (docs.isEmpty) {
                    return const Center(child: Text('Nothing to see here.'));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index] as Map<String, dynamic>;
                      final amount = (data['amount_ngn'] as num?)?.toStringAsFixed(2) ?? '0.00';
                      final rawStatus = (data['status'] ?? '').toString();
                      final status = _displayStatus(rawStatus);
                      final reference = (data['reference'] ?? '').toString();
                      final accountName = (data['account_name'] ?? '').toString();
                      final accountNumber = (data['account_number'] ?? '').toString();
                      final failureReason = (data['failure_reason'] ?? '').toString();
                      final details = rawStatus == 'failed' || rawStatus == 'reversed'
                          ? (failureReason.isNotEmpty ? failureReason : 'Withdrawal could not be completed')
                          : 'To $accountName • $accountNumber';
                      final dateTime = DateTime.tryParse((data['created_at'] ?? '').toString());
                      final dateString = dateTime != null
                          ? DateFormat("MMMM d 'at' h:mm a").format(dateTime)
                          : 'Unknown date';
                      final statusColor = _statusColor(rawStatus);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(dateString, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                  child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text('₦$amount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(details),
                            if (reference.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(reference, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
