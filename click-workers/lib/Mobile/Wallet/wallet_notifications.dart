import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletNotifs extends StatefulWidget {
  const WalletNotifs(
      {super.key, required this.isSelected, required this.mainCategories});

  final String isSelected;
  final List<String> mainCategories;
  @override
  State<WalletNotifs> createState() => _WalletNotifsState();
}

class _WalletNotifsState extends State<WalletNotifs> {
  late String isSelected;
  String selectedValue = " ";
  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;
  bool isChecked4 = false;
  bool isChecked5 = false;
  bool isChecked6 = false;
  bool isChecked7 = false;
  bool isChecked8 = false;
  bool clicked = false;
  TextEditingController controller = TextEditingController();
  DateTime? fromDate;
  DateTime? toDate;

  //main categories
  List<String> mainCategories = ["All"];
  //List<String> categories = ["All"];
  List<String> tasks = [
    "One Off Single Action",
    "One off Grouped Action",
  ];
  late TextEditingController dobEditingController1 = TextEditingController();
  late TextEditingController dobEditingController2 = TextEditingController();

  final List<String> _chips = [];
  // ignore: prefer_final_fields
  List<String> _filteredChips = ["All"];
  void _addChip(String chip, void Function(VoidCallback) localSetState) {
    localSetState(() {
      if (controller.text.trim().isEmpty && !_chips.contains(chip)) {
        _chips
          ..clear() // remove any existing chip
          ..add(chip);
        clicked = false;
        //controller.clear();
        // _filteredChips.clear();
      }
    });
  }

  void _removeChip(String chip, void Function(VoidCallback) localSetState) {
    localSetState(() {
      _chips.remove(chip);
    });
  }

  Future<void> _selectDate1(
      BuildContext context, void Function(VoidCallback) localSetState) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepOrange, // header background
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // OK & Cancel button color
              ),
            ),
          ),
          child: child!,
        );
      },
      initialDate: DateTime(2025, 9),
      firstDate: DateTime(2025, 1),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate =
          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      localSetState(() {
        dobEditingController1.text = formattedDate;
        fromDate = pickedDate;
        // resets toDate if it's before new fromDate
        if (toDate != null && toDate!.isBefore(fromDate!)) {
          toDate = null;
        }
      });
    }
  }

  Future<void> _selectDate2(
      BuildContext context, void Function(VoidCallback) localSetState) async {
    if (fromDate == null) {
      // enforces selecting fromDate first
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select 'From' date first")),
      );
      return;
    }
    DateTime? pickedDate = await showDatePicker(
      context: context,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepOrange, // header background
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // OK & Cancel button color
              ),
            ),
          ),
          child: child!,
        );
      },
      initialDate: toDate ?? fromDate!,
      firstDate: fromDate!,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate =
          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      localSetState(() {
        dobEditingController2.text = formattedDate;
        toDate = pickedDate;
      });
    }
  }

  void _onChanged(String value, void Function(VoidCallback) localSetState) {
    localSetState(() {
      _filteredChips = _filteredChips
          .where((city) =>
              city.toLowerCase().contains(value.toLowerCase()) &&
              !_chips.contains(city))
          .toList();
    });
  }

  Stream<QuerySnapshot> filter({
    List<String>? mainCategories,
    String? subCategory,
    DateTime? from,
    DateTime? to,
  }) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    Query query = FirebaseFirestore.instance
        .collection('wallets')
        .doc(userId)
        .collection('transactions');

    // Filters by multiple main categories
    if (mainCategories != null && mainCategories.isNotEmpty) {
      query = query.where('category', whereIn: mainCategories);
    }

    // Filters by sub category
    if (subCategory != null && subCategory.isNotEmpty) {
      query = query.where('subCategory', isEqualTo: subCategory);
    }

    // Filters by date range
    if (from != null && to != null) {
      query = query.where('date', isGreaterThanOrEqualTo: from);
      query = query.where('date', isLessThanOrEqualTo: to);
    }

    return query.snapshots();
  }

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
    mainCategories = List<String>.from(widget.mainCategories);
  }

  @override
  void dispose() {
    dobEditingController1.dispose();
    dobEditingController2.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //filter drawer
    void showTopDrawer(BuildContext context) {
      showGeneralDialog(
        barrierDismissible: true,
        barrierLabel: "TopDrawer",
        barrierColor: Colors.black.withOpacity(0.3),
        transitionDuration: const Duration(milliseconds: 300),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return const SizedBox.shrink(); // required, but we override it below
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return Transform.translate(
            offset: Offset(0, -200 + anim1.value * 200), // slide down
            child: Align(
              alignment: Alignment.topCenter,
              child: Material(
                elevation: 8,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: StatefulBuilder(builder: (context, localSetState) {
                  return Container(
                    width: double.infinity,
                    height: clicked ? 97.h : 80.h, // custo
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        )),
                    child: Column(
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          SizedBox(
                            width: 95.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Main Category",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        isSelected = "Filtered";
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Done",
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.black,
                                            decorationColor: Colors.black)))
                              ],
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Checkbox(
                                            value: isChecked1,
                                            activeColor: Colors.black,
                                            onChanged: (value) {
                                              localSetState(() {
                                                isChecked1 = !isChecked1;
                                                _filteredChips = [
                                                  "All",
                                                  "One Off Single Action",
                                                  "One off Grouped Action",
                                                  "Repeating Grouped Action",
                                                  "Repeating Single Action",
                                                  "Trend Push",
                                                  "Unpaid Tasks",
                                                ];
                                              });
                                              if (isChecked1 == true) {
                                                isChecked2 = true;
                                                isChecked3 = true;
                                                isChecked4 = true;
                                                isChecked5 = true;
                                                isChecked6 = true;
                                                isChecked7 = true;
                                                isChecked8 = true;
                                              } else {
                                                isChecked2 = false;
                                                isChecked3 = false;
                                                isChecked4 = false;
                                                isChecked5 = false;
                                                isChecked6 = false;
                                                isChecked7 = false;
                                                isChecked8 = false;
                                              }
                                            },
                                          ),
                                          SizedBox(width: 0.5.w),
                                          const Text("All",
                                              style: TextStyle(
                                                fontSize: 10,
                                              ))
                                        ]),
                                        SizedBox(height: 3.h),
                                        Row(children: [
                                          Checkbox(
                                            value: isChecked5,
                                            activeColor: Colors.black,
                                            onChanged: (value) {
                                              localSetState(() {
                                                isChecked5 = !isChecked5;
                                                isChecked1 = false;
                                                _filteredChips = ["All"];
                                              });
                                              if (isChecked5 == true) {
                                                mainCategories
                                                    .add("Daily\nCheck-in");
                                              } else {
                                                mainCategories
                                                    .remove("Daily\nCheck-in");
                                              }
                                            },
                                          ),
                                          SizedBox(width: 0.5.w),
                                          const Text("Daily\nCheck-in",
                                              style: TextStyle(
                                                fontSize: 9,
                                              ))
                                        ]),
                                      ]),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Checkbox(
                                            value: isChecked2,
                                            activeColor: Colors.black,
                                            onChanged: (value) {
                                              localSetState(() {
                                                isChecked1 = false;
                                                isChecked2 = !isChecked2;
                                              });
                                              if (isChecked2 == false) {
                                                mainCategories.remove("Tasks");
                                                localSetState(() {
                                                  _filteredChips = ["All"];
                                                });
                                              } else {
                                                mainCategories.add("Tasks");
                                                // optional: re-add children if checked again
                                                localSetState(() {
                                                  _filteredChips = [
                                                    "All",
                                                    "One Off Single Action",
                                                    "One off Grouped Action",
                                                    "Repeating Grouped Action",
                                                    "Repeating Single Action",
                                                    "Trend Push",
                                                    "Unpaid Tasks",
                                                  ];
                                                });
                                              }
                                            },
                                          ),
                                          SizedBox(width: 0.5.w),
                                          const Text("Tasks",
                                              style: TextStyle(
                                                fontSize: 10,
                                              ))
                                        ]),
                                        SizedBox(height: 3.h),
                                        Row(children: [
                                          Checkbox(
                                            value: isChecked6,
                                            activeColor: Colors.black,
                                            onChanged: (value) {
                                              localSetState(() {
                                                _filteredChips = ["All"];
                                                isChecked6 = !isChecked6;
                                                isChecked1 = false;
                                              });
                                              if (isChecked6 == true) {
                                                mainCategories.add("Streaks");
                                              } else {
                                                mainCategories
                                                    .remove("Streaks");
                                              }
                                            },
                                          ),
                                          SizedBox(width: 0.5.w),
                                          const Text("Streaks",
                                              style: TextStyle(
                                                fontSize: 10,
                                              ))
                                        ]),
                                      ]),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Checkbox(
                                            value: isChecked3,
                                            activeColor: Colors.black,
                                            onChanged: (value) {
                                              localSetState(() {
                                                _filteredChips = ["All"];
                                                isChecked3 = !isChecked3;
                                                isChecked1 = false;
                                              });
                                              if (isChecked3 == true) {
                                                mainCategories
                                                    .add("Spin To Win");
                                              } else {
                                                mainCategories
                                                    .remove("Spin To Win");
                                              }
                                            },
                                          ),
                                          SizedBox(width: 0.5.w),
                                          const Text("Spin To Win",
                                              style: TextStyle(
                                                fontSize: 10,
                                              ))
                                        ]),
                                        SizedBox(height: 3.h),
                                        Row(children: [
                                          Checkbox(
                                            value: isChecked7,
                                            activeColor: Colors.black,
                                            onChanged: (value) {
                                              localSetState(() {
                                                isChecked7 = !isChecked7;
                                                _filteredChips = ["All"];
                                              });
                                              if (isChecked7 == true) {
                                                mainCategories.add("Referral");
                                              } else {
                                                mainCategories
                                                    .remove("Referral");
                                              }
                                            },
                                          ),
                                          SizedBox(width: 0.5.w),
                                          const Text("Referral\nEarnings",
                                              style: TextStyle(
                                                fontSize: 10,
                                              ))
                                        ]),
                                      ]),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Checkbox(
                                            value: isChecked4,
                                            activeColor: Colors.black,
                                            onChanged: (value) {
                                              localSetState(() {
                                                isChecked4 = !isChecked4;
                                                isChecked1 = false;
                                                _filteredChips = ["All"];
                                              });
                                              if (isChecked4 == true) {
                                                mainCategories
                                                    .add("Treasure Hunt");
                                              } else {
                                                mainCategories
                                                    .remove("Treasure Hunt");
                                              }
                                            },
                                          ),
                                          SizedBox(width: 0.5.w),
                                          const Text("Treasure\nHunt",
                                              style: TextStyle(
                                                fontSize: 10,
                                              ))
                                        ]),
                                        SizedBox(height: 3.h),
                                        Row(children: [
                                          Checkbox(
                                            value: isChecked8,
                                            activeColor: Colors.black,
                                            onChanged: (value) {
                                              localSetState(() {
                                                isChecked8 = !isChecked8;
                                                isChecked1 = false;
                                                _filteredChips = ["All"];
                                              });
                                              if (isChecked8 == true) {
                                                mainCategories
                                                    .add("New Referrals");
                                              } else {
                                                mainCategories
                                                    .remove("New Referrals");
                                              }
                                            },
                                          ),
                                          SizedBox(width: 0.5.w),
                                          const Text("New\nReferrals",
                                              style: TextStyle(
                                                fontSize: 10,
                                              ))
                                        ]),
                                      ])
                                ]),
                          ),
                          SizedBox(height: 1.h),
                          const Divider(color: Colors.grey, thickness: 2),
                          SizedBox(height: 1.h),
                          SizedBox(
                            width: 95.w,
                            child: const Text("Sub-Category",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(height: 2.h),
                          SizedBox(
                              width: 95.w,
                              child: Column(children: [
                                Container(
                                  width: 90.w,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      ..._chips.map(
                                        (chip) => InputChip(
                                          label: Text(chip),
                                          onDeleted: () =>
                                              _removeChip(chip, localSetState),
                                        ),
                                      ),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth:
                                              120, // limit textfield width to prevent line wrap
                                        ),
                                        child: TextFormField(
                                          controller: controller,
                                          readOnly: true,
                                          onChanged: (val) {
                                            _onChanged(val, localSetState);
                                          },
                                          validator: (val) => _chips.isEmpty
                                              ? 'Fill out this field'
                                              : null,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            localSetState(() {
                                              clicked = !clicked;
                                            });
                                          },
                                          icon: clicked
                                              ? const Icon(
                                                  Icons.keyboard_arrow_up)
                                              : const Icon(
                                                  Icons.keyboard_arrow_down)),
                                    ],
                                  ),
                                ),
                                if (clicked || controller.text != "")
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints:
                                        const BoxConstraints(maxHeight: 150),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _filteredChips.length,
                                      itemBuilder: (context, index) {
                                        final chip = _filteredChips[index];
                                        return ListTile(
                                          title: Text(chip),
                                          onTap: () =>
                                              _addChip(chip, localSetState),
                                        );
                                      },
                                    ),
                                  ),
                              ])),
                          SizedBox(height: 2.h),
                          const Divider(color: Colors.grey, thickness: 2),
                          SizedBox(height: 1.h),
                          SizedBox(
                            width: 95.w,
                            child: const Text("Sub Sub-Category",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(height: 2.h),
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Radio(
                                        value: "1",
                                        activeColor: Colors.black,
                                        groupValue: selectedValue,
                                        onChanged: (value) {
                                          localSetState(() {
                                            selectedValue = value!;
                                          });
                                        },
                                      ),
                                      SizedBox(width: 1.w),
                                      const Text("All Time",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold))
                                    ]),
                                    Row(children: [
                                      Radio(
                                        value: "2",
                                        activeColor: Colors.black,
                                        groupValue: selectedValue,
                                        onChanged: (value) {
                                          localSetState(() {
                                            selectedValue = value!;
                                          });
                                        },
                                      ),
                                      SizedBox(width: 1.w),
                                      const Text("From: ",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold)),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: selectedValue != "2"
                                              ? null
                                              : () => _selectDate1(
                                                  context, localSetState),
                                          child: AbsorbPointer(
                                            child: TextFormField(
                                              controller: dobEditingController1,
                                              validator: (val) => val!.isEmpty
                                                  ? 'Fill out this field'
                                                  : null,
                                              readOnly: true, // prevent manua
                                              decoration: InputDecoration(
                                                suffix: const Icon(
                                                    Icons.calendar_today,
                                                    size: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 1.w),
                                      const Text("To: ",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(width: 1.w),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: selectedValue != "2"
                                              ? null
                                              : () => _selectDate2(
                                                  context, localSetState),
                                          child: AbsorbPointer(
                                            child: TextFormField(
                                              controller: dobEditingController2,
                                              validator: (val) => val!.isEmpty
                                                  ? 'Fill out this field'
                                                  : null,
                                              readOnly: true, // prevent manua
                                              decoration: InputDecoration(
                                                suffix: const Icon(
                                                    Icons.calendar_today,
                                                    size: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ]))
                        ]),
                  );
                }),
              ),
            ),
          );
        },
      );
    }

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
          child: Text('Wallet Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.white,
        actions: [
          InkWell(
              onTap: () {
                showTopDrawer(context);
              },
              child: Image.asset("assets/icons/filter_funnel.png")),
          SizedBox(width: 3.w)
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
            color: const Color(0xffeeeeee),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 27.w,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSelected = "All";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSelected == "All" ? Colors.black : Colors.white,
                        foregroundColor: isSelected == "All"
                            ? const Color(0xffff6533)
                            : Colors.black),
                    child: const Text("All", style: TextStyle(fontSize: 12)),
                  ),
                ),
                SizedBox(
                  width: 27.w,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSelected = "Earnings";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected == "Earnings"
                            ? Colors.black
                            : Colors.white,
                        foregroundColor: isSelected == "Earnings"
                            ? const Color(0xffff6533)
                            : Colors.black),
                    child:
                        const Text("Earnings", style: TextStyle(fontSize: 12)),
                  ),
                ),
                SizedBox(
                  width: 27.w,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSelected = "Points";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected == "Points"
                            ? Colors.black
                            : Colors.white,
                        foregroundColor: isSelected == "Points"
                            ? const Color(0xffff6533)
                            : Colors.black),
                    child: const Text("Points", style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
          isSelected == "Filtered"
              ? StreamBuilder<QuerySnapshot>(
                  stream: filter(
                    mainCategories: mainCategories,
                    subCategory: _chips.isNotEmpty ? _chips[0] : "All",
                    from: fromDate,
                    to: toDate,
                  ),
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
                      //debugPrint('Error: ${snapshot.error}');
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    // Success
                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return const Center(child: Text('No notifications yet.'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;

                        final icon = data['type'] == "tasks"
                            ? Icons.checklist
                            : data['mainCategory'] == "Treasure Hunt"
                                ? Icons.task_alt
                                : data['type'] == "earnings"
                                    ? Icons.attach_money
                                    : Icons.person_add;
                        final color = data['color'] ?? 'grey';
                        final title = data['title'] ?? 'Untitled';
                        final message = data['message'] ?? 'No Message';
                        final subCategory = data['subCategory'] ?? '';
                        final action = data['action'] ?? '';
                        Timestamp time = data['date'] ?? Timestamp.now();
                        DateTime dateTime = time.toDate();
                        final difference = DateTime.now().difference(dateTime);
                        String timeAgo;
                        if (difference.inMinutes < 60) {
                          timeAgo = '${difference.inMinutes} minutes ago';
                        } else if (difference.inHours < 24) {
                          timeAgo = '${difference.inHours} hours ago';
                        } else {
                          timeAgo = '${difference.inDays} days ago';
                        }
                        return Container(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Material(
                            elevation: 6,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
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
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xffeeeeee),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(icon,
                                        color: Color(color), size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  // Text Section
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "$message ($subCategory)",
                                          style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 13),
                                        ),
                                        if (action != "")
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              action,
                                              style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Timestamp
                                  Text(
                                    timeAgo,
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  })
              : isSelected == "Earnings"
                  ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('wallets')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('notifications')
                          .where('type', isEqualTo: 'earnings')
                          .snapshots(),
                      builder: (context, snapshot) {
                        //  Loading state
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                            color: Colors.black,
                          ));
                        }

                        //  Error state
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        // Success
                        final docs = snapshot.data?.docs ?? [];

                        if (docs.isEmpty) {
                          return const Center(
                              child: Text('No notifications yet. '));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final icon = data['type'] == "tasks"
                                ? Icons.checklist
                                : data['mainCategory'] == "Treasure Hunt"
                                    ? Icons.task_alt
                                    : data['type'] == "earnings"
                                        ? Icons.attach_money
                                        : Icons.person_add;
                            final color = data['color'] ?? 'grey';
                            final title = data['title'] ?? 'Untitled';
                            final message = data['message'] ?? 'No Message';
                            final subCategory = data['subCategory'] ?? '';
                            final action = data['action'] ?? '';
                            Timestamp time = data['date'] ?? Timestamp.now();
                            DateTime dateTime = time.toDate();
                            final difference =
                                DateTime.now().difference(dateTime);
                            String timeAgo;
                            if (difference.inMinutes < 60) {
                              timeAgo = '${difference.inMinutes} minutes ago';
                            } else if (difference.inHours < 24) {
                              timeAgo = '${difference.inHours} hours ago';
                            } else {
                              timeAgo = '${difference.inDays} days ago';
                            }
                            return Container(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Material(
                                elevation: 6,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
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
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Icon
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xffeeeeee),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(icon,
                                            color: Color(color), size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      // Text Section
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "$message ($subCategory)",
                                              style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 13),
                                            ),
                                            if (action != "")
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  action,
                                                  style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Timestamp
                                      Text(
                                        timeAgo,
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      })
                  : isSelected == "Points"
                      ? StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('wallets')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('notifications')
                              .where('type', isEqualTo: 'points')
                              .snapshots(),
                          builder: (context, snapshot) {
                            //  Loading state
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                color: Colors.black,
                              ));
                            }

                            //  Error state
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            // Success
                            final docs = snapshot.data?.docs ?? [];

                            if (docs.isEmpty) {
                              return const Center(
                                  child: Text('No notifications yet. '));
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final data =
                                    docs[index].data() as Map<String, dynamic>;
                                final icon = data['type'] == "tasks"
                                    ? Icons.checklist
                                    : data['mainCategory'] == "Treasure Hunt"
                                        ? Icons.task_alt
                                        : data['type'] == "earnings"
                                            ? Icons.attach_money
                                            : Icons.person_add;
                                final color = data['color'] ?? 'grey';
                                final title = data['title'] ?? 'Untitled';
                                final message = data['message'] ?? 'No Message';
                                final action = data['action'] ?? '';
                                final subCategory = data['subCategory'] ?? '';
                                Timestamp time =
                                    data['date'] ?? Timestamp.now();
                                DateTime dateTime = time.toDate();
                                final difference =
                                    DateTime.now().difference(dateTime);
                                String timeAgo;
                                if (difference.inMinutes < 60) {
                                  timeAgo =
                                      '${difference.inMinutes} minutes ago';
                                } else if (difference.inHours < 24) {
                                  timeAgo = '${difference.inHours} hours ago';
                                } else {
                                  timeAgo = '${difference.inDays} days ago';
                                }
                                return Container(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Material(
                                    elevation: 6,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 4,
                                            color:
                                                Colors.black.withOpacity(0.05),
                                          )
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Icon
                                          Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xffeeeeee),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(icon,
                                                color: Color(color), size: 24),
                                          ),
                                          const SizedBox(width: 12),
                                          // Text Section
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  title,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "$message ($subCategory)",
                                                  style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 13),
                                                ),
                                                if (action != "")
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0),
                                                    child: Text(
                                                      action,
                                                      style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          // Timestamp
                                          Text(
                                            timeAgo,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          })
                      : StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('wallets')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('notifications')
                              .snapshots(),
                          builder: (context, snapshot) {
                            //  Loading state
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                color: Colors.black,
                              ));
                            }

                            //  Error state
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            // Success
                            final docs = snapshot.data?.docs ?? [];

                            if (docs.isEmpty) {
                              return const Center(
                                  child: Text('No notifications yet. '));
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final data =
                                    docs[index].data() as Map<String, dynamic>;
                                final icon = data['type'] == "tasks"
                                    ? Icons.checklist
                                    : data['mainCategory'] == "Treasure Hunt"
                                        ? Icons.task_alt
                                        : data['type'] == "earnings"
                                            ? Icons.attach_money
                                            : Icons.person_add;
                                final color = data['color'] ?? 'grey';
                                final title = data['title'] ?? 'Untitled';
                                final message = data['message'] ?? 'No Message';
                                final action = data['action'] ?? '';
                                final subCategory = data['subCategory'] ?? '';
                                Timestamp time =
                                    data['date'] ?? Timestamp.now();
                                DateTime dateTime = time.toDate();
                                final difference =
                                    DateTime.now().difference(dateTime);
                                String timeAgo;
                                if (difference.inMinutes < 60) {
                                  timeAgo =
                                      '${difference.inMinutes} minutes ago';
                                } else if (difference.inHours < 24) {
                                  timeAgo = '${difference.inHours} hours ago';
                                } else {
                                  timeAgo = '${difference.inDays} days ago';
                                }
                                return Container(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Material(
                                    elevation: 6,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 4,
                                            color:
                                                Colors.black.withOpacity(0.05),
                                          )
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Icon
                                          Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xffeeeeee),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(icon,
                                                color: Color(color), size: 24),
                                          ),
                                          const SizedBox(width: 12),
                                          // Text Section
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  title,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "$message ($subCategory)",
                                                  style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 13),
                                                ),
                                                if (action != "")
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0),
                                                    child: Text(
                                                      action,
                                                      style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          // Timestamp
                                          Text(
                                            timeAgo,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
        ]),
      ),
    );
  }
}
