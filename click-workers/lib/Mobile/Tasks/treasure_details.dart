import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TreasureDetails extends StatefulWidget {
  const TreasureDetails(
      {super.key,
      required this.status,
      required this.details,
      required this.name,
      required this.imageUrl});

  final String status;
  final String name;
  final String imageUrl;
  final Map details;

  @override
  State<TreasureDetails> createState() => _TreasureDetailsState();
}

class _TreasureDetailsState extends State<TreasureDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeeeeee),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 4.h,
              ),
              Container(
                width: 90.w,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xff092e57),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text("Check out the Details of what you Found",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: 90.w,
                child: Container(
                  width: 90.w,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 100.w,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "Status: ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // label color
                                ),
                              ),
                              TextSpan(
                                text: widget.status,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: widget.status == "NOT FOUND YET"
                                        ? Colors.green
                                        : Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                            height: 200,
                            child: Image.network(widget.imageUrl,
                                scale: 2.0, fit: BoxFit.cover)),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                  padding: const EdgeInsets.all(15),
                  width: 90.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black87,
                        spreadRadius: 2,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                            child: Text(
                          "Details of the Item",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        )),
                        SizedBox(
                          height: 2.h,
                        ),
                        Builder(
                          builder: (context) {
                            final details = widget.details;
                            final name = widget.name;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (name.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xfffe6929)),
                                    ),
                                  ),
                                if (details.isEmpty)
                                  const Text("No details available")
                                else
                                  ...details.entries.map((entry) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      child: Row(
                                        children: [
                                          Text(
                                            "${entry.key}: ",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              entry.value.toString(),
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            );
                          },
                        )
                      ])),
              SizedBox(height: 4.h),
              ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    fixedSize: Size(40.w, 4.h), // width, height
                    backgroundColor: const Color(0xffa64221),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // round corners
                    ),
                  ),
                  child: const Text("Continue Tasks",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
