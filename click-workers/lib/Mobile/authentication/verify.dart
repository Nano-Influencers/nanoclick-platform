import 'package:flutter/material.dart';
import 'package:click_workers/Mobile/authentication/sign_in.dart';
import 'package:click_workers/Mobile/authentication/utils/auth.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen(
      {super.key,
      required this.value,
      required this.isNumber,
      required this.fullName,
      required this.confirmationResult,
      required this.password});
  final String value;
  final String password;
  final bool isNumber;
  final dynamic confirmationResult;
  final String fullName;

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  //error icon
  bool _errorIcon = true;
  //error text
  String error = '';

  bool isError = false;
  final AuthProvider _auth = AuthProvider();

  // form key
  final _formKey = GlobalKey<FormState>();

  bool isActive = false;
  bool isLoading = false;

  //Editing Controller
  final otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xffff6533)),
            onPressed: () {
              Navigator.pop(context);
            }),
        leadingWidth: 20,
        centerTitle: false,
        title: const Text('Back',
            style: TextStyle(color: Color(0xffff6533), fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Image.asset('assets/auth/verify.png'),
              const SizedBox(
                height: 10,
              ),
              Text(widget.isNumber ? 'Enter Code' : 'Check your Mail',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(
                height: 5,
              ),
              RichText(
                  text: TextSpan(
                      text: widget.isNumber
                          ? 'A verificaton code has been sent to your phone'
                          : 'A verification link has been sent to your mail',
                      children: [
                    TextSpan(
                        text: '\n${widget.value}',
                        style: const TextStyle(fontWeight: FontWeight.bold))
                  ])),
              const SizedBox(
                height: 20,
              ),
              widget.isNumber
                  ? TextFormField(
                      autofocus: false,
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val!.length < 6 ? 'Fill out this field' : null,
                      onChanged: (value) async {
                        otpController.text = value;
                        if (otpController.text.length == 6) {
                          setState(() => _errorIcon = false);
                        } else {
                          setState(() => _errorIcon = true);
                        }
                        setState(() {
                          isActive = true;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Code',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffix: InkWell(
                            onTap: () {},
                            child: Icon(
                                _errorIcon ? Icons.error : Icons.check_circle,
                                color: _errorIcon ? Colors.red : Colors.green)),
                      ),
                    )
                  : const SizedBox(
                      height: 0,
                    ),
              const SizedBox(
                height: 5,
              ),
              !isError
                  ? const SizedBox(height: 0)
                  : error != ''
                      ? Text(error)
                      : widget.isNumber
                          ? const Text(
                              '* Wrong code, try again',
                              style: TextStyle(color: Colors.red),
                            )
                          : const Text(
                              'Invalid Email',
                              style: TextStyle(color: Colors.red),
                            ),
              const SizedBox(
                height: 5,
              ),
              Center(
                child: TextButton(
                  onPressed: () async {
                    setState(() {
                      isActive = true;
                      isLoading = true;
                    });
                    var result = await _auth.registerWithEmailAndPassword(
                        widget.value, widget.password, widget.fullName);
                    if (result.toString() != "Instance of 'UserId'") {
                      if (context.mounted) {
                        setState(() {
                          isActive = true;
                          isLoading = false;
                          isError = true;
                        });
                      }
                    } else {
                      setState(() {
                        isActive = true;
                        isLoading = false;
                      });
                      if (context.mounted) {}
                    }
                  },
                  child: RichText(
                      text: TextSpan(
                          text: widget.isNumber
                              ? "Didn't receive a code?"
                              : "Didn't get an email?",
                          children: const [
                        TextSpan(
                            text: ' Send again',
                            style: TextStyle(
                              color: Color(0xffff6533),
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
                      onPressed: isActive
                          ? null
                          : !widget.isNumber
                              ? () async {
                                  setState(() {
                                    isActive = true;
                                    isLoading = true;
                                  });
                                  await _auth.reload();
                                  if (_auth.currentUser != null) {
                                    if (_auth.currentUser!.emailVerified) {
                                      // ignore: use_build_context_synchronously
                                      Navigator.pop(
                                        // ignore: use_build_context_synchronously
                                        context,
                                      );
                                    } else {
                                      setState(() {
                                        isLoading = false;
                                        isActive = true;
                                        error = 'Email is not verified';
                                      });
                                    }
                                  }
                                }
                              : !isActive
                                  ? null
                                  : () async {
                                      setState(() {
                                        isActive = false;
                                        isLoading = true;
                                      });
                                      if (_formKey.currentState!.validate()) {
                                        dynamic result =
                                            await _auth.verifyOTPCode(
                                                widget.confirmationResult,
                                                otpController.text);
                                        if (result != null) {
                                          if (context.mounted) {
                                            setState(() {
                                              isError = true;
                                              isActive = true;
                                              isLoading = false;
                                            });
                                          }
                                        } else {
                                          setState(() {
                                            isActive = true;
                                            isLoading = false;
                                          });
                                          // ignore: use_build_context_synchronously
                                          Navigator.pop(
                                            // ignore: use_build_context_synchronously
                                            context,
                                          );
                                        }
                                      }
                                    },
                      child: widget.isNumber
                          ? !isLoading
                              ? const Text('Create Account',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))
                              : const CircularProgressIndicator(
                                  color: Colors.white)
                          : !isLoading
                              ? const Text("I've Verified",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))
                              : const CircularProgressIndicator(
                                  color: Colors.white))),
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
                              color: Color(0xffff6533),
                            ))
                      ])),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
