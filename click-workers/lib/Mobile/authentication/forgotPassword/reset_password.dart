import 'package:flutter/material.dart';
import 'package:click_workers/Mobile/authentication/forgotPassword/new_password.dart';
import 'package:click_workers/Mobile/authentication/sign_in.dart';


class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key, required this.oobCode});
  final String oobCode;

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController codeController = TextEditingController();
  bool isNull = true;
  bool isError = false;
  final bool _errorIcon = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xff092e57)),
            onPressed: () {
              Navigator.pop(context);
            }),
        leadingWidth: 20,
        centerTitle: false,
        title: const Text('Back',
            style: TextStyle(color: Color(0xff092e57), fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Image.asset('assets/authentication/verify.png'),
            const SizedBox(
              height: 10,
            ),
            const Text('Enter Code',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(
              height: 5,
            ),
            RichText(
                text: TextSpan(
                    text: 'A verification number has been sent to:',
                    children: [
                  TextSpan(
                      text: '\n${widget.oobCode}',
                      style: const TextStyle(fontWeight: FontWeight.bold))
                ])),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: codeController,
              onSaved: (val) {
                setState(() => isNull = false);
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Code',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffix: InkWell(
                    onTap: () {},
                    child: Icon(_errorIcon ? Icons.error : Icons.check_circle,
                        color: _errorIcon ? Colors.red : Colors.green)),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            !isError
                ? const SizedBox(height: 0)
                : const Text(
                    '* No account for this credential',
                    style: TextStyle(color: Colors.red),
                  ),
            const SizedBox(
              height: 5,
            ),
            Center(
              child: TextButton(
                onPressed: () {},
                child: RichText(
                    text: const TextSpan(
                        text: "Didn't receive a code?",
                        children: [
                      TextSpan(
                          text: ' Send again',
                          style: TextStyle(
                            color: Color(0xff092e57),
                          ))
                    ])),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: isNull
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>  NewPassword(oobCode: codeController.text)),
                            );
                          },
                    child: const Text('Verify',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)))),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignIn()),
                  );
                },
                child: RichText(
                    text: const TextSpan(
                        text: "Already have an account?",
                        children: [
                      TextSpan(
                          text: ' Sign In',
                          style: TextStyle(
                            color: Color(0xff092e57),
                          ))
                    ])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
