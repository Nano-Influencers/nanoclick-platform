import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Upgrade extends StatefulWidget {
  const Upgrade({super.key});

  @override
  State<Upgrade> createState() => _UpgradeState();
}

class _UpgradeState extends State<Upgrade> {
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
          child: Text('Upgrade to Pro Plan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xffeeeeee),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: SizedBox(
            width: 90.w,
            child: Card(
              elevation: 6, // adds shadow
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 95.w,
                        padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Pro Plan",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                Container(
                                    padding: const EdgeInsets.all(8),
                                    width: 20.w,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Center(
                                      child: Text("Premium",
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xffff6533),
                                              fontWeight: FontWeight.bold)),
                                    ))
                              ],
                            ),
                            SizedBox(height: 2.h),
                            RichText(
                                text: const TextSpan(
                                    text: "₦1,000",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    children: [
                                  TextSpan(
                                    text: "/month",
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  )
                                ])),
                            SizedBox(height: 1.h),
                            const Text(
                                "Unlock all Premium features and benefits",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ],
                        )),
                    SizedBox(height: 3.h),
                    const ListTile(
                        dense: true,
                        leading: Icon(Icons.check, color: Color(0xff22c55e)),
                        title: Text("Unlimited withdrawal Limit",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        subtitle: Text("No limits on withdrawal amounts",
                            style: TextStyle(
                                color: Color(0xff6b7280), fontSize: 10))),
                    const ListTile(
                        dense: true,
                        leading: Icon(Icons.check, color: Color(0xff22c55e)),
                        title: Text("Higher Points Per Task",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        subtitle: Text(
                            "Earn more points for each completed task",
                            style: TextStyle(
                                color: Color(0xff6b7280), fontSize: 10))),
                    const ListTile(
                        dense: true,
                        leading: Icon(Icons.check, color: Color(0xff22c55e)),
                        title: Text("10% referral commission",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        subtitle: Text("Higher Commission on referral earnings",
                            style: TextStyle(
                                color: Color(0xff6b7280), fontSize: 10))),
                    const ListTile(
                        dense: true,
                        leading: Icon(Icons.check, color: Color(0xff22c55e)),
                        title: Text("1 daily free spin",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        subtitle: Text("Get one free spin every day",
                            style: TextStyle(
                                color: Color(0xff6b7280), fontSize: 10))),
                    const ListTile(
                        dense: true,
                        leading: Icon(Icons.check, color: Color(0xff22c55e)),
                        title: Text("Pro badge display",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        subtitle: Text(
                            "Get a display badge that shows that you have been verified",
                            style: TextStyle(
                                color: Color(0xff6b7280), fontSize: 10))),
                    SizedBox(
                      height: 3.h,
                    ),
                    SizedBox(
                        width: 95.w,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(20),
                            ),
                            onPressed: () {},
                            child: const Text("Upgrade to Pro Now"))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
