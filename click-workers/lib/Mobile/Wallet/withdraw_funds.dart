import 'package:flutter/material.dart';
import 'package:click_workers/Mobile/Wallet/withdrawal_history.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/services/api_client.dart';

/// Withdrawal UI. Provider transfer credentials and the real payout chain
/// remain server-side; this screen only verifies bank details and calls the
/// backend withdrawal endpoint.
class WithdrawFunds extends StatefulWidget {
  const WithdrawFunds(
      {super.key, required this.balance, required this.kycCompleted});

  final String balance;
  final bool kycCompleted;

  @override
  State<WithdrawFunds> createState() => _WithdrawFundsState();
}

class _WithdrawFundsState extends State<WithdrawFunds> {
  final TextEditingController amountToWithdrawController =
      TextEditingController();
  final TextEditingController bankCodeController = TextEditingController();
  final TextEditingController accountNumberController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _resolvedAccountName;
  bool _resolving = false;
  bool _submitting = false;

  // One key represents one logical withdrawal attempt. If the request times
  // out after the server debits the wallet, retrying with this same key lets
  // the backend return the original withdrawal instead of creating another.
  String? _withdrawalIdempotencyKey;
  String? _withdrawalFingerprint;

  String _withdrawalFingerprintFor(String amount, String bankCode,
      String accountNumber) =>
      '${amount.trim()}|${bankCode.trim()}|${accountNumber.trim()}';

  void _invalidateVerifiedAccount() {
    if (_resolvedAccountName != null) {
      setState(() => _resolvedAccountName = null);
    }
  }

  Future<void> _verifyAccount() async {
    final bankCode = bankCodeController.text.trim();
    final accountNumber = accountNumberController.text.trim();
    if (bankCode.isEmpty || accountNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Enter both a bank code and account number first")),
      );
      return;
    }
    setState(() {
      _resolving = true;
      _resolvedAccountName = null;
    });
    try {
      final result = await ApiClient.instance
          .resolveAccount(bankCode, accountNumber);
      if (!mounted) return;
      setState(() => _resolvedAccountName = result['account_name'] as String?);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_resolvedAccountName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verify the account before withdrawing")),
      );
      return;
    }

    final amountText = amountToWithdrawController.text.trim();
    final bankCode = bankCodeController.text.trim();
    final accountNumber = accountNumberController.text.trim();
    final fingerprint =
        _withdrawalFingerprintFor(amountText, bankCode, accountNumber);

    // Keep the same key across retries of the same logical action. Changing
    // amount or destination starts a new logical action and therefore gets a
    // fresh key.
    if (_withdrawalIdempotencyKey == null ||
        _withdrawalFingerprint != fingerprint) {
      _withdrawalIdempotencyKey = ApiClient.instance.createIdempotencyKey();
      _withdrawalFingerprint = fingerprint;
    }

    setState(() => _submitting = true);
    try {
      final amount = double.parse(amountText.replaceAll(',', ''));
      final result = await ApiClient.instance.withdraw(
        amountNgn: amount,
        bankCode: bankCode,
        accountNumber: accountNumber,
        idempotencyKey: _withdrawalIdempotencyKey,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(result['message']?.toString() ?? "Withdrawal initiated")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    amountToWithdrawController.dispose();
    bankCodeController.dispose();
    accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget amountToWithdraw = TextFormField(
        keyboardType: TextInputType.number,
        controller: amountToWithdrawController,
        validator: (v) {
          if (v == null || v.isEmpty) {
            return "Please enter an amount";
          }
          final withdrawAmount = double.tryParse(v.replaceAll(',', ''));
          if (withdrawAmount == null) return "Enter a valid amount";
          if (withdrawAmount < 500) return "Minimum withdrawal is ₦500";
          final availableBalance =
              double.tryParse(widget.balance.replaceAll(',', '')) ?? 0;
          if (withdrawAmount > availableBalance) {
            return "Insufficient Balance";
          }
          return null;
        },
        decoration: const InputDecoration(
          prefixIcon: Text("₦",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Withdraw Funds',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Center(
            child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 3.h),
              SizedBox(
                  width: 90.w,
                  child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Available Balance",
                                  style: TextStyle(color: Color(0xff6b7280))),
                              SizedBox(height: 1.5.h),
                              Text("₦${widget.balance}",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 1.5.h),
                              Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: widget.kycCompleted
                                        ? const Color(0xff8eeab0)
                                        : Colors.red[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: widget.kycCompleted
                                      ? const Text("Verified Account",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xff22c55e)))
                                      : const Text("Non Verified Account",
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.red))),
                            ],
                          )))),
              SizedBox(height: 3.h),
              SizedBox(
                  width: 90.w,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Bank Details",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 2.h),
                        TextFormField(
                          controller: bankCodeController,
                          onChanged: (_) => _invalidateVerifiedAccount(),
                          decoration: const InputDecoration(
                            labelText: "Bank Code",
                            hintText: "e.g. 058 for GTBank",
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? "Enter a bank code"
                              : null,
                        ),
                        SizedBox(height: 2.h),
                        TextFormField(
                          controller: accountNumberController,
                          onChanged: (_) => _invalidateVerifiedAccount(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Account Number",
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? "Enter an account number"
                              : null,
                        ),
                        SizedBox(height: 2.h),
                        SizedBox(
                          width: 90.w,
                          child: OutlinedButton(
                            onPressed: _resolving ? null : _verifyAccount,
                            child: Text(_resolving
                                ? "Verifying…"
                                : "Verify Account"),
                          ),
                        ),
                        if (_resolvedAccountName != null) ...[
                          SizedBox(height: 1.h),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xff8eeab0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(children: [
                              const Icon(Icons.check_circle,
                                  color: Color(0xff22c55e), size: 18),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(_resolvedAccountName!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                            ]),
                          ),
                        ],
                      ])),
              SizedBox(height: 4.h),
              SizedBox(
                  width: 90.w,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Amount to Withdraw",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 2.h),
                        SizedBox(
                            width: 90.w,
                            child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.white,
                                child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          amountToWithdraw,
                                          SizedBox(height: 0.5.h),
                                          const Text("Minimum: ₦500",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12)),
                                        ]))))
                      ])),
              SizedBox(height: 3.h),
              SizedBox(
                  width: 90.w,
                  height: 8.h,
                  child: ElevatedButton(
                      onPressed: _submitting ? null : _submitWithdrawal,
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(_submitting
                          ? "Processing…"
                          : "Withdraw Now"))),
              SizedBox(height: 1.h),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const WithdrawHistoryScreen()),
                    );
                  },
                  child: const Text("View Withdrawal History")),
              SizedBox(height: 4.h),
            ],
          ),
        )),
      ),
    );
  }
}
