import 'package:click_workers/Mobile/widgets/dotted_outline_button.dart';
import 'package:flutter/material.dart';
import 'package:click_workers/Mobile/Wallet/withdrawal_history.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WithdrawFunds extends StatefulWidget {
  const WithdrawFunds(
      {super.key, required this.balance, required this.kycCompleted});

  final String balance;
  final bool kycCompleted;

  @override
  State<WithdrawFunds> createState() => _WithdrawFundsState();
}

class _WithdrawFundsState extends State<WithdrawFunds> {
  int isSelected = 0;
  String? selectedOption = "0";
  final String apiKey = dotenv.env['MONNIFY_API_KEY'] ?? '';
  final String secretKey = dotenv.env['MONNIFY_SECRET_KEY'] ?? '';
  final String baseUrl =
      dotenv.env['MONNIFY_BASE'] ?? 'https://sandbox.monnify.com';
  TextEditingController amountToWithdrawController = TextEditingController();
  List<Map> accountDetails = [];
  final _formKey = GlobalKey<FormState>();
  String? _cachedToken;
  DateTime? _tokenExpiry;

  @override
  void initState() {
    super.initState();
    fetchTwoAccounts();
    amountToWithdrawController.addListener(() {
      setState(() {}); // rebuild UI on every text change
    });
  }

  Future<void> fetchTwoAccounts() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('accountDetails')
          .orderBy('createdAt', descending: true)
          .limit(2)
          .get();

      final List<Map<String, dynamic>> fetchedAccounts =
          snapshot.docs.map((doc) => doc.data()).toList();

      // Update state
      setState(() {
        accountDetails = fetchedAccounts;
      });
    } catch (e) {
      debugPrint("Error fetching accounts: $e");
    }
  }

  Future<void> withdrawWithPaystack({
    required BuildContext context,
    required String accountNumber,
    required String bankCode,
    required double amount, // in Naira
    required String accountName,
  }) async {
    final secretKey = dotenv.env['PAYSTACK_SECRET_KEY'];

    if (secretKey == null || secretKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paystack Secret Key not found.')),
      );
      return;
    }

    try {
      // Step 1️⃣: Create Transfer Recipient
      final recipientResponse = await http.post(
        Uri.parse("https://api.paystack.co/transferrecipient"),
        headers: {
          "Authorization": "Bearer $secretKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "type": "nuban",
          "name": accountName,
          "account_number": accountNumber,
          "bank_code": bankCode,
          "currency": "NGN",
        }),
      );

      final recipientData = jsonDecode(recipientResponse.body);

      if (!(recipientData["status"] ?? false)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    recipientData["message"] ?? "Recipient creation failed")),
          );
        }
        return;
      }

      final recipientCode = recipientData["data"]["recipient_code"];

      // Step 2️⃣: Initiate Transfer
      final transferResponse = await http.post(
        Uri.parse("https://api.paystack.co/transfer"),
        headers: {
          "Authorization": "Bearer $secretKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "source": "balance",
          "reason": "User withdrawal - userName", // 👈 dynamic reason
          "amount": amount * 100, // in kobo
          "recipient": recipientCode,
        }),
      );

      final transferData = jsonDecode(transferResponse.body);

      if (transferData["status"] == true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Withdrawal successful")),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(transferData["message"] ?? "Transfer failed")),
          );
        }
      }
    } catch (e) {
    if(context.mounted) { ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );}
    }
  }

  void _showOptionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempSelected = selectedOption;

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Withdraw With?"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text("Paystack"),
                    value: "1",
                    activeColor: Colors.black,
                    //fillColor: Colors.black,
                    groupValue: tempSelected,
                    onChanged: (value) => setState(() => tempSelected = value),
                  ),
                  RadioListTile<String>(
                    title: const Text("Monnify"),
                    value: "2",
                    activeColor: Colors.black,
                    //fillColor: Colors.black,
                    groupValue: tempSelected,
                    onChanged: (value) => setState(() => tempSelected = value),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (tempSelected != null) {
                  if (tempSelected == "1") {
                    if (isSelected == 1) {
                      await withdrawWithPaystack(
                          context: context,
                          accountNumber: accountDetails[0]["accountNumber"],
                          bankCode: accountDetails[0]["bankCode"],
                          accountName: accountDetails[0]["accountName"],
                          amount: double.tryParse(amountToWithdrawController
                                  .text
                                  .replaceAll(',', ''))! *
                              1.05);
                    } else if (isSelected == 2) {
                      await withdrawWithPaystack(
                          context: context,
                          accountNumber: accountDetails[1]["accountNumber"],
                          bankCode: accountDetails[1]["bankCode"],
                          accountName: accountDetails[1]["accountName"],
                          amount: double.tryParse(amountToWithdrawController
                                  .text
                                  .replaceAll(',', ''))! *
                              1.05);
                    }
                  } else if (tempSelected == "2") {
                    if (isSelected == 1) {
                      await withdrawWithMonnify(
                          accountNumber: accountDetails[0]["accountNumber"],
                          bankCode: accountDetails[0]["bankCode"],
                          accountName: accountDetails[0]["accountName"],
                          amountNaira: double.tryParse(
                                  amountToWithdrawController.text
                                      .replaceAll(',', ''))! *
                              1.05);
                    } else if (isSelected == 2) {
                      await withdrawWithMonnify(
                          accountNumber: accountDetails[1]["accountNumber"],
                          bankCode: accountDetails[1]["bankCode"],
                          accountName: accountDetails[1]["accountName"],
                          amountNaira: double.tryParse(
                                  amountToWithdrawController.text
                                      .replaceAll(',', ''))! *
                              1.05);
                    }
                  }
                  setState(() => selectedOption = tempSelected);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please select an option first")),
                  );
                }
              },
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );
  }

  Future<String> getAccessToken() async {
    final now = DateTime.now();
    if (_cachedToken != null &&
        _tokenExpiry != null &&
        now.isBefore(_tokenExpiry!)) {
      return _cachedToken!;
    }

    final basic = base64.encode(utf8.encode('$apiKey:$secretKey'));
    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/login'),
      headers: {
        'Authorization': 'Basic $basic',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Auth failed: ${res.statusCode} ${res.body}');
    }

    final body = jsonDecode(res.body);
    // Monnify returns token in responseBody.accessToken (docs vary, adjust if necessary)
    final token = body['responseBody']?['accessToken'] ??
        body['access_token'] ??
        body['data']?['access_token'];
    final expiresIn = body['responseBody']?['expiresIn'] ?? 3600;
    if (token == null) throw Exception('No access token in response: $body');

    _cachedToken = token;
    _tokenExpiry =
        DateTime.now().add(Duration(seconds: (expiresIn as int) - 30));
    return token;
  }

  // include previous methods & fields...
  Future<Map<String, dynamic>> withdrawWithMonnify({
    required String accountNumber,
    required String bankCode,
    required String accountName,
    required double amountNaira,
  }) async {
    final token = await getAccessToken();
    final url = Uri.parse('$baseUrl/api/v2/disbursements/single');

    final body = {
      'amount': amountNaira,
      'destinationAccountNumber': accountNumber,
      'destinationBankCode': bankCode,
      'currency': 'NGN',
      'beneficiaryName': accountName,
      'sourceAccountNumber': '1234567890',
      "reference": "WITHDRAW_${DateTime.now().millisecondsSinceEpoch}",
    };

    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    final map = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return map; // contains transfer reference & status
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Transfer failed: ${res.statusCode} ${res.body}')),
        );
      }
      return {};
      // throw Exception('Transfer failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<Map<String, dynamic>> authorizeSingleTransfer({
    required String transferReference,
    required String otp,
  }) async {
    final token = await getAccessToken();
    final url = Uri.parse('$baseUrl/api/v2/disbursements/single/validate-otp');

    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
          {'reference': transferReference, 'authorizationCode': otp}),
    );

    final map = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return map;
    throw Exception('Authorize failed: ${res.statusCode} ${res.body}');
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

          double withdrawAmount = double.tryParse(
                  amountToWithdrawController.text.replaceAll(',', ''))! *
              1.05;
          double availableBalance =
              double.tryParse(widget.balance.replaceAll(',', ''))! * 1.05;

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
          icon: const Icon(Icons.arrow_back_ios_new), // or any custom icon
          onPressed: () {
            Navigator.of(context).pop(); // Go back
          },
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
              SizedBox(
                height: 3.h,
              ),
              SizedBox(
                  width: 90.w,
                  child: Card(
                      elevation: 6, // adds shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Available Balance",
                                style: TextStyle(color: Color(0xff6b7280)),
                              ),
                              SizedBox(
                                height: 1.5.h,
                              ),
                              Text(
                                "₦${widget.balance}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 1.5.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: widget.kycCompleted
                                            ? const Color(0xff8eeab0)
                                            : Colors.red[100],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: widget.kycCompleted
                                          ? const Text(
                                              "Verified Account",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xff22c55e)),
                                            )
                                          : const Text(
                                              "Non Verified Account",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red),
                                            )),
                                  const Text("Daily Limit: ₦50,000",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold))
                                ],
                              )
                            ],
                          )))),
              SizedBox(height: 3.h),
              SizedBox(
                  width: 90.w,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Select Bank Account",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 2.h),
                        accountDetails.isNotEmpty
                            ? Container(
                                width: 90.w,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: const Color(0xffff6533))),
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      isSelected = 1;
                                    });
                                  },
                                  leading: const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Color(0xfff6b39d),
                                    child: Icon(Icons.account_balance,
                                        color: Color(0xffff6533)),
                                  ),
                                  title: Text(
                                      accountDetails[0]["bankName"] ?? "",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      "*** *** ${accountDetails[0]['accountNumber'].substring(accountDetails[0]['accountNumber'].length - 4)}"),
                                  trailing: isSelected == 1
                                      ? const CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Color(0xff22c55e),
                                          child: Icon(Icons.check,
                                              color: Colors.white, size: 12))
                                      : const SizedBox(height: 0),
                                ))
                            : const SizedBox(height: 0),
                        accountDetails.isNotEmpty
                            ? SizedBox(height: 2.h)
                            : const SizedBox(height: 0),
                        accountDetails.length > 1
                            ? Container(
                                width: 90.w,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: const Color(0xffff6533))),
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      isSelected = 2;
                                    });
                                  },
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xffc8d2f6),
                                    radius: 20,
                                    child: Icon(Icons.account_balance,
                                        color: Color(0xff2756ff)),
                                  ),
                                  title: Text(
                                      accountDetails[1]["bankName"] ?? "",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      "*** *** ${accountDetails[1]['accountNumber'].substring(accountDetails[1]['accountNumber'].length - 4)}"),
                                  trailing: isSelected == 2
                                      ? const CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Color(0xff22c55e),
                                          child: Icon(Icons.check,
                                              color: Colors.white, size: 12))
                                      : const SizedBox(height: 0),
                                ))
                            : const SizedBox(height: 0),
                        accountDetails.length > 1
                            ? SizedBox(height: 2.h)
                            : const SizedBox(height: 0),
                        const DottedOutlineButton()
                      ])),
              SizedBox(
                height: 6.h,
              ),
              SizedBox(
                  width: 90.w,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Amount to Withdraw",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2.h),
                        SizedBox(
                            width: 90.w,
                            child: Card(
                                elevation: 6, // adds shadow
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
                                          const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text("Min: ₦1,000",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12)),
                                                Text("Max: ₦50,000",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12)),
                                              ])
                                        ]))))
                      ])),
              SizedBox(height: 1.h),
              SizedBox(
                width: 90.w,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                          onTap: () {
                            amountToWithdrawController.text = "5,000";
                          },
                          child: Card(
                            elevation: 6, // adds shadow
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Colors.white,
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              child: const Text("₦5,000",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          )),
                      InkWell(
                          onTap: () {
                            amountToWithdrawController.text = "10,000";
                          },
                          child: Card(
                            elevation: 6, // adds shadow
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Colors.white,
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              child: const Text("₦10,000",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          )),
                      InkWell(
                          onTap: () {
                            amountToWithdrawController.text = "20,000";
                          },
                          child: Card(
                            elevation: 6, // adds shadow
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Colors.white,
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              child: const Text("₦20,000",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          )),
                    ]),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                  width: 85.w,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Amount",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff6b7280))),
                              SizedBox(
                                width: 25.w,
                                child: Text(
                                    "₦ ${(0.00 + (double.tryParse(amountToWithdrawController.text.replaceAll(',', '')) ?? 0.00)).toStringAsFixed(2)}"),
                              ),
                            ]),
                        SizedBox(height: 1.h),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Fee",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff6b7280))),
                              SizedBox(
                                width: 25.w,
                                child: Text(
                                    "₦ ${(0.05 * (double.tryParse(amountToWithdrawController.text.replaceAll(',', '')) ?? 0.00)).toStringAsFixed(2)}"),
                              ),
                            ]),
                        SizedBox(height: 1.5.h),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  )),
                              SizedBox(
                                width: 25.w,
                                child: Text(
                                    "₦ ${(((double.tryParse(amountToWithdrawController.text.replaceAll(',', '')) ?? 0.00) * 1.05)).toStringAsFixed(2)}"),
                              ),
                            ]),
                      ])),
              SizedBox(height: 3.h),
              SizedBox(
                  width: 90.w,
                  height: 8.h,
                  child: ElevatedButton(
                      onPressed: isSelected != 0
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                _showOptionDialog();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // rounded corners
                        ), // border
                      ),
                      child: const Text("Withdraw Now"))),
              SizedBox(height: 1.h),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WithdrawHistoryScreen()),
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
