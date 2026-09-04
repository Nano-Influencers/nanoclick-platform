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
  String selectedStatus = 'All';

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
          onStatusChange: (status) {
            setState(() => selectedStatus = status);
          },
        ),
      ),
      transitionBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween(begin: const Offset(0, -1), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new), // or any custom icon
          onPressed: () {
            Navigator.of(context).pop(); // Go back
          },
        ),
        title: const Text('Withdrawal History',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      decoration: InputDecoration(
                        hintText: 'Search Transactions',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      _showFilterModal();
                    },
                    child: Image.asset("assets/icons/filter_funnel.png"),
                  )
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<dynamic>>(
                  future: ApiClient.instance.getTransactions().then(
                      (txs) => txs.where((t) => t['type'] == 'withdrawal').toList()),
                  builder: (context, snapshot) {
                    //  Loading state
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: Colors.black,
                      ));
                    }

                    //  Error state
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    // Success
                    final docs = snapshot.data ?? [];

                    if (docs.isEmpty) {
                      return const Center(child: Text('Nothing to see here.'));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index] as Map<String, dynamic>;
                        final amount = (data['amount_ngn'] as num?)?.toStringAsFixed(2) ?? '0';
                        final rawStatus = (data['status'] ?? '').toString();
                        final status = rawStatus.isNotEmpty
                            ? rawStatus[0].toUpperCase() + rawStatus.substring(1)
                            : '';
                        final ref = (data['id'] as String?)?.substring(0, 8) ?? '';
                        final txDetails = (data['description'] ?? '').toString();
                        final statusColor = rawStatus == 'completed'
                            ? Colors.green
                            : rawStatus == 'pending'
                                ? Colors.orange
                                : Colors.red;
                        final dateTime = DateTime.tryParse((data['created_at'] ?? '').toString()) ?? DateTime.now();
                        String dateString =
                            DateFormat("MMMM d 'at' h:mm a").format(dateTime);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateString,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "₦$amount",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(txDetails),
                              Text(ref),
                            ],
                          ),
                        );
                      },
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
