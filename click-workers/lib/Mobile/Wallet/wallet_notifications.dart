import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/services/api_client.dart';

/// Was ~1,400 lines mixing two different Firestore data sources: a
/// wallets/{uid}/transactions collection (queried via a filter() helper
/// supporting category/subCategory/date-range filters) and a separate
/// wallets/{uid}/notifications collection filtered by 'type' per tab
/// ("Earnings", "Points"). Both are replaced by the one real backend
/// feed, GET /notifications (app/routers/notifications.py) — its
/// type/title/body/created_at fields map directly onto what this screen
/// already displayed (icon-by-type, title, message, time-ago), fetched
/// once and filtered client-side per tab, matching the same pattern
/// used for tasks.dart's filter tabs (the list is capped at 100
/// server-side, small enough for that to be fine).
///
/// The elaborate multi-field filter modal (category/subcategory chips,
/// date range) is simplified to a date-range filter over the same
/// fetched list — the granular sub-category taxonomy it filtered by
/// doesn't exist on the backend's notification model (type is a single
/// flat string: task_approved, deposit_success, referral_bonus, etc.).
class WalletNotifs extends StatefulWidget {
  const WalletNotifs(
      {super.key, required this.isSelected, required this.mainCategories});

  final String isSelected;
  final List<String> mainCategories;

  @override
  State<WalletNotifs> createState() => _WalletNotifsState();
}

const _earningsTypes = {
  'task_approved', 'deposit_success', 'referral_bonus', 'reward_tier_unlocked'
};
const _pointsTypes = {'spin_win', 'checkin_reward'};

class _WalletNotifsState extends State<WalletNotifs> {
  late String isSelected;
  List<dynamic> _all = [];
  bool _loading = true;
  String? _error;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
    _load();
  }

  Future<void> _load() async {
    try {
      final notifications = await ApiClient.instance.listNotifications();
      if (mounted) setState(() { _all = notifications; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<dynamic> get _filtered {
    Iterable<dynamic> list = _all;
    switch (isSelected) {
      case "Earnings":
        list = list.where((n) => _earningsTypes.contains(n['type']));
        break;
      case "Points":
        list = list.where((n) => _pointsTypes.contains(n['type']));
        break;
      case "Filtered":
        if (_fromDate != null && _toDate != null) {
          list = list.where((n) {
            final created = DateTime.tryParse((n['created_at'] ?? '').toString());
            return created != null &&
                created.isAfter(_fromDate!) &&
                created.isBefore(_toDate!.add(const Duration(days: 1)));
          });
        }
        break;
      default: // "All"
        break;
    }
    return list.toList();
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (range != null) {
      setState(() {
        _fromDate = range.start;
        _toDate = range.end;
        isSelected = "Filtered";
      });
    }
  }

  IconData _iconFor(String type) {
    if (type.contains('task')) return Icons.checklist;
    if (_earningsTypes.contains(type)) return Icons.attach_money;
    if (type.contains('referral')) return Icons.person_add;
    if (type == 'kyc_approved' || type == 'kyc_rejected') return Icons.verified_user;
    return Icons.notifications;
  }

  Widget _tabButton(String label) {
    final selected = isSelected == label;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ElevatedButton(
        onPressed: () => setState(() => isSelected = label),
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? Colors.black : Colors.white,
          foregroundColor: selected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xffd1d5db)),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Wallet Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _tabButton("All"),
                      _tabButton("Earnings"),
                      _tabButton("Points"),
                    ]),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _pickDateRange,
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _filtered.isEmpty
                        ? const Center(child: Text('No notifications yet.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final data = _filtered[index] as Map<String, dynamic>;
                              final type = (data['type'] ?? '').toString();
                              final title = (data['title'] ?? 'Untitled').toString();
                              final message = (data['body'] ?? 'No message').toString();
                              final createdAt =
                                  DateTime.tryParse((data['created_at'] ?? '').toString());
                              String timeAgo = 'Just now';
                              if (createdAt != null) {
                                final difference = DateTime.now().difference(createdAt);
                                if (difference.inMinutes < 60) {
                                  timeAgo = '${difference.inMinutes} minutes ago';
                                } else if (difference.inHours < 24) {
                                  timeAgo = '${difference.inHours} hours ago';
                                } else {
                                  timeAgo = '${difference.inDays} days ago';
                                }
                              }
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 4,
                                      color: Colors.black.withOpacity(0.05),
                                    )
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: Color(0xffeeeeee),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(_iconFor(type), color: Colors.black, size: 20),
                                    ),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(title,
                                              style: const TextStyle(fontWeight: FontWeight.bold)),
                                          SizedBox(height: 0.5.h),
                                          Text(message,
                                              style: const TextStyle(
                                                  color: Color(0xff6b7280), fontSize: 12)),
                                          SizedBox(height: 0.5.h),
                                          Text(timeAgo,
                                              style: const TextStyle(
                                                  color: Color(0xff9ca3af), fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
