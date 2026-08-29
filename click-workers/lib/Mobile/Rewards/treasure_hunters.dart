import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:responsive_sizer/responsive_sizer.dart';

class TreasureHunters extends StatefulWidget {
  const TreasureHunters({super.key});

  @override
  State<TreasureHunters> createState() => _TreasureHuntersState();
}

class _TreasureHuntersState extends State<TreasureHunters> {
  DateTime? fromDate;
  DateTime? toDate;
  //get random color
  Color getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255, // fully opaque
      random.nextInt(256), // red   0–255
      random.nextInt(256), // green 0–255
      random.nextInt(256), // blue  0–255
    );
  }

  late TextEditingController dobEditingController1 = TextEditingController();
  late TextEditingController dobEditingController2 = TextEditingController();

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
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
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
                  height: 340, // custo
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      )),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Filter",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            TextButton(
                                onPressed: () {
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                                child: const Text("Done",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black))),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        const Text("Most Valuable Asset Hunted",
                            style: TextStyle(
                                fontSize: 12, color: Color(0xff6b7280))),
                        SizedBox(height: 0.5.h),
                        SizedBox(
                          width: double.infinity,
                          child: DropdownButtonFormField(
                            items: [
                              'All',
                            ]
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            value: 'All',
                            onChanged: (val) {},
                            decoration: const InputDecoration(
                                border: OutlineInputBorder()),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(children: [
                          const Text("Time",
                              style: TextStyle(
                                color: Color(0xff6b7280),
                                fontSize: 12,
                              )),
                          SizedBox(width: 52.w),
                          const Text("Hint Lead",
                              style: TextStyle(
                                  color: Color(0xff6b7280), fontSize: 12))
                        ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 30.w,
                                child: DropdownButtonFormField(
                                  items: [
                                    'All',
                                    'Latest',
                                    'Earliest',
                                  ]
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text(e)))
                                      .toList(),
                                  value: 'All',
                                  onChanged: (val) {},
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              SizedBox(
                                width: 32.w,
                                child: DropdownButtonFormField(
                                  items: [
                                    'All',
                                    'Earnings',
                                    'RCPs',
                                  ]
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text(e)))
                                      .toList(),
                                  value: 'All',
                                  onChanged: (val) {},
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder()),
                                ),
                              ),
                            ]),
                        SizedBox(height: 2.h),
                        const Text("Date",
                            style: TextStyle(
                                fontSize: 12, color: Color(0xff6b7280))),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    _selectDate1(context, localSetState),
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: dobEditingController1,
                                    validator: (val) => val!.isEmpty
                                        ? 'Fill out this field'
                                        : null,
                                    readOnly: true, // prevent manua
                                    decoration: InputDecoration(
                                      hintText: "From",
                                      suffix: const Icon(Icons.calendar_today,
                                          size: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    _selectDate2(context, localSetState),
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: dobEditingController2,
                                    validator: (val) => val!.isEmpty
                                        ? 'Fill out this field'
                                        : null,
                                    readOnly: true, // prevent manua
                                    decoration: InputDecoration(
                                      hintText: "To",
                                      suffix: const Icon(Icons.calendar_today,
                                          size: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  //users hunt history
  Stream<Map<String, dynamic>> huntHistoryStream(String userId) async* {
    final firestore = FirebaseFirestore.instance;

    // Get treasures doc id (only one)
    final treasures = await firestore
        .collection("users")
        .doc(userId)
        .collection("treasures")
        .get();

    if (treasures.docs.isEmpty) {
      yield {"userDp": null, "history": []};
      return;
    }

    final treasureId = treasures.docs.first.id;

    // Listen to both user dp and approved history
    final userDocStream = firestore.collection("users").doc(userId).snapshots();
    final approvedStream = firestore
        .collection("users")
        .doc(userId)
        .collection("treasures")
        .doc(treasureId)
        .collection("treasureHistory")
        .doc("approved")
        .snapshots();

    await for (final userSnap in userDocStream) {
      final userDp = userSnap.data()?['dp'];

      await for (final approvedSnap in approvedStream) {
        if (!approvedSnap.exists) {
          yield {"userDp": userDp, "history": []};
          continue;
        }

        final data = approvedSnap.data()!;
        final details = List.from(data['details'] ?? []);
        final hintLeadUsed = List.from(data['hintLeadUsed'] ?? []);
        final dates = List.from(data['date'] ?? []);

        final history = List.generate(details.length, (i) {
          return {
            "details": details[i],
            "hintLeadUsed": hintLeadUsed.length > i ? hintLeadUsed[i] : null,
            "date": dates.length > i ? dates[i] : null,
          };
        });

        yield {
          "userDp": userDp,
          "history": history,
        };
      }
    }
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
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Text('Treasure Hunters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          actions: [
            InkWell(
                onTap: () {
                  showTopDrawer(context);
                },
                child: Image.asset("assets/icons/filter_funnel.png"))
          ],
          backgroundColor: Colors.white,
        ),
        backgroundColor: const Color(0xffeeeeee),
        body: SingleChildScrollView(
          child: Column(children: [
            SizedBox(height: 2.h),
            SizedBox(
              width: 90.w,
              child: const Text("You: ",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xfffe6929))),
            ),
            SizedBox(
              width: 90.w,
              child: StreamBuilder<Map<String, dynamic>>(
                stream:
                    huntHistoryStream(FirebaseAuth.instance.currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text("No history available"));
                  }

                  final data = snapshot.data!;
                  final userDp = data["userDp"];
                  final history =
                      List<Map<String, dynamic>>.from(data["history"]);

                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return Container(
                            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                            width: 90.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                                //crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Center(
                                    child: CircleAvatar(
                                        radius: 25,
                                        backgroundColor: getRandomColor(),
                                        child: CircleAvatar(
                                            radius: 22,
                                            backgroundImage: NetworkImage(
                                              userDp,
                                            ))),
                                  ),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            FirebaseAuth.instance.currentUser!
                                                .displayName!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            )),
                                        RichText(
                                          text: TextSpan(
                                              text: "Hunted Down: ",
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                              children: [
                                                TextSpan(
                                                  text: item["details"]["Name"],
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                )
                                              ]),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                              text: "Hint Lead Used: ",
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xfffe6929)),
                                              children: [
                                                TextSpan(
                                                  text: item["hintLeadUsed"],
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Color(0xfffe6929)),
                                                )
                                              ]),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                              text:
                                                  "Items Hunted Down so Far: ",
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      history.length.toString(),
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                )
                                              ]),
                                        ),
                                      ]),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        TextButton(
                                            onPressed: () {},
                                            child: const Text("See Details",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xff007a3f),
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationColor:
                                                        Color(0xff007a3f)))),
                                        SizedBox(height: 2.h),
                                        Text(item["date"],
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 8))
                                      ])
                                ]));
                      });
                },
              ),
            ),
            SizedBox(height: 2.h),
            const Divider(thickness: 2.0, color: Colors.white),
            SizedBox(height: 2.h),
            SizedBox(
                width: 90.w,
                child: const Text(
                  "All Hunters",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xfffe6929)),
                )),
            SizedBox(height: 1.h),
            SizedBox(
              width: 90.w,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('hunters')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No hunters found"));
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final timestamp = data['date'];
                      String formattedDate = '';
                      if (timestamp != null) {
                        final date = timestamp.toDate();
                        formattedDate = DateFormat("d MMM. yyyy").format(date);
                      }
                      return Container(
                          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                          width: 90.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Center(
                                  child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: getRandomColor(),
                                      child: CircleAvatar(
                                          radius: 22,
                                          backgroundImage: NetworkImage(
                                            data["dp"],
                                          ))),
                                ),
                                SizedBox(width: 1.w),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(data["name"],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          )),
                                      RichText(
                                        text: TextSpan(
                                            text: "Hunted Down: ",
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold),
                                            children: [
                                              TextSpan(
                                                text: data["item"],
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              )
                                            ]),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                            text: "Hint Lead Used: ",
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xfffe6929)),
                                            children: [
                                              TextSpan(
                                                text: data["hintLead"],
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Color(0xfffe6929)),
                                              )
                                            ]),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                            text: "Items Hunted Down so Far: ",
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold),
                                            children: [
                                              TextSpan(
                                                text: data["huntedDown"],
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              )
                                            ]),
                                      ),
                                    ]),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(height: 2.h),
                                      Text(formattedDate,
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 8))
                                    ])
                              ]));
                    },
                  );
                },
              ),
            )
          ]),
        ));
  }
}
