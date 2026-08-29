import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
//import '../widgets/dotted_border_container.dart';
import 'agreement.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupportingDocuments extends StatefulWidget {
  const SupportingDocuments({super.key});

  @override
  State<SupportingDocuments> createState() => _SupportingDocumentsState();
}

class _SupportingDocumentsState extends State<SupportingDocuments> {
  String selectedValue = "Select ID Type";
  String selectedValue1 = "Select Bank Name";
  // form key
  final _formKey = GlobalKey<FormState>();

  TextEditingController acctNameEditingController = TextEditingController();
  TextEditingController ninEditingController = TextEditingController();
  TextEditingController acctNumEditingController = TextEditingController();

  List<String> idTypes = [
    "Select ID Type",
    'National ID',
    'Driver’s License',
    'International Passport',
    'Voter’s Card',
    'Student ID',
  ];

  List<String> bankNames = [
    "Select Bank Name",
    "Access Bank",
    "Access Bank (Diamond)",
    "Citibank",
    "Ecobank Nigeria",
    "Fidelity Bank",
    "First Bank of Nigeria",
    "First City Monument Bank (FCMB)",
    "Globus Bank",
    "Guaranty Trust Bank (GTBank)",
    "Heritage Bank",
    "Keystone Bank",
    "Polaris Bank",
    "Providus Bank",
    "Stanbic IBTC Bank",
    "Standard Chartered Bank",
    "Sterling Bank",
    "SunTrust Bank",
    "Union Bank of Nigeria",
    "United Bank for Africa (UBA)",
    "Unity Bank",
    "Wema Bank",
    "Zenith Bank",
    "Titan Trust Bank",
    "Jaiz Bank",
    "Rubies MFB",
    "Kuda Bank",
    "Opay",
    "PalmPay",
    "Sparkle Microfinance Bank",
    "VFD Microfinance Bank",
    "Parallex Bank",
    "Mint Fintech Bank",
    "Carbon",
    "FairMoney Microfinance Bank",
    "Moniepoint MFB",
    "Mkobo MFB",
    "ALAT by Wema",
    "Eyowo",
    "OneFinance (OneBank)",
    "Nomba",
    "9Pay",
    "NowNow Digital Systems",
    "Chipper Cash",
    "Lidya Microfinance Bank",
    "Renmoney MFB",
    "Accion Microfinance Bank",
    "AB Microfinance Bank",
    "Page Financials",
    "Trustbond Microfinance Bank",
    "Mutual Trust Microfinance Bank"
  ];

  Future<void> updateKycProgress(double value) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception("No user logged in");
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await userRef.set(
      {
        "kycProgress": value,
      },
      SetOptions(
          merge: true), // 👈 will create doc if missing, or update if exists
    );
  }

  Future<void> createBankDetails() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      await FirebaseFirestore.instance.collection('kyc').doc(uid).set({
        "bank&NinDetails": {
          "NIN": ninEditingController.text, // String
          "bankName": selectedValue1, // int
          "accountName": acctNameEditingController.text, // DateTime
          "accountNumber": acctNumEditingController.text,
        }
      }, SetOptions(merge: true));
    } catch (e) {
     if(mounted) {ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error creating KYC document: $e"),
          duration: const Duration(seconds: 2), // how long it shows
        ),
      );}
    }
  }

  @override
  Widget build(BuildContext context) {
    final acctNameField = TextFormField(
      controller: acctNameEditingController,
      validator: (val) => val!.isEmpty ? 'Fill out this field' : null,
      decoration: InputDecoration(
        hintText: 'Enter account name',
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xff6b7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Fully rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );

    final ninField = TextFormField(
      controller: ninEditingController,
      validator: (val) => val!.length != 10 ? 'Enter a valid NIN' : null,
      decoration: InputDecoration(
        hintText: 'Enter your NIN',
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xff6b7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Fully rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );

    final acctNumField = TextFormField(
      controller: acctNumEditingController,
      validator: (val) =>
          val!.length != 10 ? 'Enter a Valid Account Number' : null,
      decoration: InputDecoration(
        hintText: 'Enter 10-digit account number',
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xff6b7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Fully rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new), // or any custom icon
            onPressed: () {
              Navigator.of(context).pop(); // Go back
            },
          ),
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Text('Kyc Verification',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          backgroundColor: Colors.white,
        ),
        backgroundColor: const Color(0xffeeeeee),
        body: SingleChildScrollView(
            child: Center(
                child: Form(
          key: _formKey,
          child: SizedBox(
              width: 90.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 2.h,
                  ),
                  // Card(
                  //   elevation: 6,
                  //   shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(16)),
                  //   color: Colors.white,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(20),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         const Text(
                  //             "Supporting Documents for Verification",
                  //             style: TextStyle(
                  //                 fontSize: 16,
                  //                 fontWeight: FontWeight.bold)),
                  //         SizedBox(
                  //           height: 2.h,
                  //         ),
                  //         const Text(
                  //             "Live Profile Picture (Selfie Verification)",
                  //             style: TextStyle(
                  //                 fontSize: 18,
                  //                 fontWeight: FontWeight.bold)),
                  //         SizedBox(
                  //           height: 2.h,
                  //         ),
                  //         Container(
                  //           width: 90.w,
                  //           padding: const EdgeInsets.all(20),
                  //           decoration: BoxDecoration(
                  //             color: const Color(0xffd1d5db),
                  //             borderRadius: BorderRadius.circular(16),
                  //           ),
                  //           child: Column(
                  //               crossAxisAlignment:
                  //                   CrossAxisAlignment.center,
                  //               children: [
                  //                 SizedBox(
                  //                   height: 2.h,
                  //                 ),
                  //                 const Icon(
                  //                     Icons.account_circle_outlined,
                  //                     size: 120,
                  //                     color: Color(0xff6b7280)),
                  //                 SizedBox(
                  //                   height: 2.h,
                  //                 ),
                  //                 SizedBox(
                  //                   width: 40.w,
                  //                   child: ElevatedButton(
                  //                       onPressed: () {},
                  //                       style: ElevatedButton.styleFrom(
                  //                         shape: RoundedRectangleBorder(
                  //                           borderRadius:
                  //                               BorderRadius.circular(8),
                  //                         ),
                  //                         padding:
                  //                             const EdgeInsets.all(15),
                  //                       ),
                  //                       child: RichText(
                  //                           text: const TextSpan(
                  //                               text: "",
                  //                               children: [
                  //                             WidgetSpan(
                  //                               alignment:
                  //                                   PlaceholderAlignment
                  //                                       .middle,
                  //                               child: Icon(
                  //                                   Icons.photo_camera,
                  //                                   size: 18,
                  //                                   color: Colors.white),
                  //                             ),
                  //                             TextSpan(
                  //                                 text: " Take a Selfie",
                  //                                 style: TextStyle(
                  //                                   color: Colors.white,
                  //                                   fontSize: 13,
                  //                                   fontWeight:
                  //                                       FontWeight.bold,
                  //                                 ))
                  //                           ]))),
                  //                 ),
                  //                 SizedBox(
                  //                   height: 2.h,
                  //                 ),
                  //                 const Text(
                  //                     "Please take a clear photo of your face",
                  //                     style: TextStyle(
                  //                         fontSize: 12,
                  //                         color: Color(0xff6b7280),
                  //                         fontWeight: FontWeight.bold)),
                  //               ]),
                  //         ),
                  //         SizedBox(height: 2.h),
                  //         const Text("Valid ID Document",
                  //             style: TextStyle(
                  //                 fontSize: 18,
                  //                 fontWeight: FontWeight.bold)),
                  //         SizedBox(height: 2.h),
                  //         Container(
                  //             width: 90.w,
                  //             padding: const EdgeInsets.all(20),
                  //             decoration: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(16),
                  //               color: const Color(0xffd1d5db),
                  //             ),
                  //             child: Column(
                  //               crossAxisAlignment:
                  //                   CrossAxisAlignment.start,
                  //               children: [
                  //                 const Text("Select ID Type",
                  //                     style: TextStyle(fontSize: 12)),
                  //                 SizedBox(height: 0.5.h),
                  //                 Container(
                  //                   height: 8.h,
                  //                   width: 90.w,
                  //                   padding:
                  //                       const EdgeInsets.only(left: 8),
                  //                   decoration: BoxDecoration(
                  //                     borderRadius:
                  //                         BorderRadius.circular(10),
                  //                     border:
                  //                         Border.all(color: Colors.grey),
                  //                     color: Colors.white,
                  //                   ),
                  //                   child: DropdownButtonFormField(
                  //                     isExpanded: true,
                  //                     decoration: const InputDecoration(
                  //                       border: InputBorder.none,
                  //                     ),
                  //                     value: selectedValue,
                  //                     icon: const Icon(
                  //                         Icons.keyboard_arrow_down),
                  //                     items: idTypes
                  //                         .map((option) =>
                  //                             DropdownMenuItem(
                  //                               value: option,
                  //                               child: Text(option,
                  //                                   style: const TextStyle(
                  //                                       fontSize: 12,
                  //                                       fontWeight:
                  //                                           FontWeight
                  //                                               .bold,
                  //                                       color: Color(
                  //                                           0xff6b7280))),
                  //                             ))
                  //                         .toList(),
                  //                     onChanged: (newValue) {
                  //                       setState(() {
                  //                         selectedValue = newValue!;
                  //                       });
                  //                     },
                  //                   ),
                  //                 ),
                  //                 SizedBox(
                  //                   height: 2.h,
                  //                 ),
                  //                 DottedBorderContainer(
                  //                     child: Padding(
                  //                   padding: const EdgeInsets.all(20),
                  //                   child: Column(children: [
                  //                     const Icon(Icons.cloud_upload,
                  //                         size: 48, color: Colors.black),
                  //                     SizedBox(height: 4.h),
                  //                     const Text(
                  //                         "Upload your ID document",
                  //                         style: TextStyle(
                  //                             fontSize: 12,
                  //                             fontWeight:
                  //                                 FontWeight.bold)),
                  //                     SizedBox(height: 0.5.h),
                  //                     const Text(
                  //                         "JPG, PNG or PDF (Max. 5MB)",
                  //                         style: TextStyle(
                  //                             fontSize: 12,
                  //                             fontWeight: FontWeight.bold,
                  //                             color: Color(0xff6b7280))),
                  //                   ]),
                  //                 )),
                  //                 SizedBox(height: 2.h),
                  //                 Center(
                  //                   child: SizedBox(
                  //                     width: 40.w,
                  //                     child: ElevatedButton(
                  //                         onPressed: () {},
                  //                         style: ElevatedButton.styleFrom(
                  //                           shape: RoundedRectangleBorder(
                  //                             borderRadius:
                  //                                 BorderRadius.circular(
                  //                                     8),
                  //                           ),
                  //                           padding:
                  //                               const EdgeInsets.fromLTRB(
                  //                                   10, 15, 10, 15),
                  //                         ),
                  //                         child: RichText(
                  //                             text: const TextSpan(
                  //                                 text: "",
                  //                                 children: [
                  //                               WidgetSpan(
                  //                                 alignment:
                  //                                     PlaceholderAlignment
                  //                                         .middle,
                  //                                 child: Icon(
                  //                                     Icons.cloud_upload,
                  //                                     size: 14,
                  //                                     color:
                  //                                         Colors.white),
                  //                               ),
                  //                               TextSpan(
                  //                                   text:
                  //                                       " Upload Document",
                  //                                   style: TextStyle(
                  //                                     color: Colors.white,
                  //                                     fontSize: 12,
                  //                                     fontWeight:
                  //                                         FontWeight.bold,
                  //                                   ))
                  //                             ]))),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ))
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 2.h),
                  Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Bank Details for Payments & NIN",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 2.h),
                                ninField,
                                SizedBox(height: 1.h),
                                const Text("Bank Name",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    )),
                                SizedBox(height: 0.5.h),
                                SizedBox(
                                  height: 8.h,
                                  width: 90.w,
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 2),
                                      ),
                                    ),
                                    value: selectedValue1,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: bankNames
                                        .map((option) => DropdownMenuItem(
                                              value: option,
                                              child: Text(option,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xff6b7280))),
                                            ))
                                        .toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedValue1 = newValue!;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                const Text("Account Name",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                SizedBox(height: 0.5.h),
                                acctNameField,
                                SizedBox(height: 1.h),
                                const Text("Account Number",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                SizedBox(height: 0.5.h),
                                acctNumField,
                              ]))),
                  SizedBox(height: 2.h),
                  SizedBox(
                      width: 90.w,
                      height: 8.h,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (selectedValue1 != "Select Bank Name") {
                                await createBankDetails();
                                await updateKycProgress(0.9);
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Agreement()),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select a Bank"),
                                    duration: Duration(
                                        seconds: 2), // how long it shows
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text("Continue"))),
                  SizedBox(height: 3.h),
                ],
              )),
        ))));
  }
}
