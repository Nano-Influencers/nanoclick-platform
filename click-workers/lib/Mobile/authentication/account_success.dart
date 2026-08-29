import 'package:flutter/material.dart';

class AccountSuccess extends StatefulWidget {
  const AccountSuccess({super.key});

  @override
  State<AccountSuccess> createState() => _AccountSuccessState();
}

class _AccountSuccessState extends State<AccountSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: const Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              CircleAvatar(
                radius: 38,
                backgroundColor: Color(0xff22c55e),
                child: Icon(Icons.check, color: Colors.white, size: 48),
              ),
              SizedBox(height: 20),
              Text(
                'Account Created Successfully',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Color(0xff797979)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'you will be redirected to your dashboard shortly',
                style: TextStyle(color: Color(0xff797979)),
                textAlign: TextAlign.center,
              ),
            ],
          )),
    );
  }
}
