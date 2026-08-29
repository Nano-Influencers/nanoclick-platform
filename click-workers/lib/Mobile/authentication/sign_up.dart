//import 'package:firebase_auth/firebase_auth.dart' as fire;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:click_workers/Mobile/authentication/utils/auth.dart';
import 'package:click_workers/Mobile/authentication/utils/google_sign_in.dart';
import 'package:click_workers/Mobile/authentication/utils/facebook_sign_in.dart';
import 'package:click_workers/Mobile/authentication/verify.dart';
import 'package:click_workers/Mobile/authentication/sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
// Initially password is obscure
  bool _obscureText = true;

//confirmation result is dynamic
  dynamic confirmationResult = '';

//_obscureText2 for confirm password
  bool _obscureText2 = true;

  // form key
  final _formKey = GlobalKey<FormState>();

  final AuthProvider _auth = AuthProvider();

  //Editing Controllers
  final fullNameEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final confirmPasswordEditingController = TextEditingController();
  final emailEditingController = TextEditingController();

  //validates email adress
  bool isValidEmail(String email) {
    // Regex for email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // _toggle2 for confirm password
  void _toggle2() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }

  bool privacyChecked = false;
  bool termsChecked = false;
  bool isNumber = false;
  bool isActive = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final fullNameField = TextFormField(
      autofocus: false,
      controller: fullNameEditingController,
      keyboardType: TextInputType.name,
      validator: (val) => val!.isEmpty ? 'Fill out this field' : null,
      onSaved: (value) async {
        fullNameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: 'Enter your Full Name',
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    final emailField = TextFormField(
      autofocus: false,
      controller: emailEditingController,
      validator: (val) {
        if (val!.isNotEmpty) {
          if (!isValidEmail(val)) {
            return 'Please enter a valid email';
          } else {
            return null;
          }
        } else {
          return 'Fill out this field';
        }
      },
      onSaved: (value) async {
        emailEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: 'Email',
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordEditingController,
      obscureText: _obscureText,
      validator: (val) => val!.length < 6
          ? 'Password must contain at least 6 characters'
          : null,
      onSaved: (value) async {
        passwordEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: 'Create a Password',
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffix: InkWell(
          onTap: _toggle,
          child: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
        ),
      ),
    );

    final confirmPasswordField = TextFormField(
      autofocus: false,
      controller: confirmPasswordEditingController,
      obscureText: _obscureText2,
      validator: (val) => val != passwordEditingController.text
          ? 'Not the same with password'
          : null,
      onSaved: (value) async {
        confirmPasswordEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: 'Confirm your Password',
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffix: InkWell(
          onTap: _toggle2,
          child: Icon(
            _obscureText2 ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
        ),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Center(
                    child: Column(
                  children: [
                    Image.asset('assets/auth/logo.png'),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text('Sign Up',
                        style: TextStyle(
                            fontSize: 26,
                            color: Color(0xffff6533),
                            fontWeight: FontWeight.bold)),
                    const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 20)),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          foregroundColor: Colors.black,
                          backgroundColor: const Color(0xffe6e6e6),
                          fixedSize: const Size.fromHeight(52),
                          side: const BorderSide(color: Color(0xffe6e6e6))),
                      child: const Center(
                        child: SizedBox(
                          width: 130,
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.facebook, color: Colors.blue),
                              SizedBox(
                                width: 10,
                              ),
                              Text('Facebook', style: TextStyle(fontSize: 18))
                            ],
                          ),
                        ),
                      ),
                      onPressed: () async {
                        await SignInWithFacebook.signInWithFacebook();
                        await _auth.createUserInFirestore(
                            fullNameEditingController.text,
                            passwordEditingController.text);
                        await _auth.createUserWallet();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 14)),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          fixedSize: const Size.fromHeight(52),
                          foregroundColor: Colors.black,
                          backgroundColor: const Color(0xffe6e6e6),
                          side: const BorderSide(color: Color(0xffe6e6e6))),
                      child: Center(
                        child: SizedBox(
                          width: 130,
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/googlelogo.png', height: 28),
                              const SizedBox(width: 10),
                              const Text(
                                'Google',
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          ),
                        ),
                      ),
                      onPressed: () async {
                        await SignInWithGoogle.signInWithGoogle();
                        await _auth.createUserInFirestore(
                            fullNameEditingController.text,
                            passwordEditingController.text);
                        await _auth.createUserWallet();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                )),
                const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                const Row(children: <Widget>[
                  Expanded(child: Divider()),
                  Text("  or  "),
                  Expanded(child: Divider()),
                ]),
                const SizedBox(height: 20),
                const Text('Full Name'),
                const SizedBox(height: 5),
                fullNameField,
                const SizedBox(
                  height: 10,
                ),
                const Text('Email'),
                const SizedBox(height: 5),
                emailField,
                const SizedBox(
                  height: 10,
                ),
                const Text('Password'),
                const SizedBox(height: 5),
                passwordField,
                const SizedBox(
                  height: 10,
                ),
                const Text('Confirm Password'),
                const SizedBox(height: 5),
                confirmPasswordField,
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                        activeColor: const Color(0xffff6533),
                        onChanged: (val) {
                          setState(() => privacyChecked = val!);
                          if (privacyChecked && termsChecked) {
                            setState(() => isActive = true);
                          } else {
                            setState(() => isActive = false);
                          }
                        },
                        value: privacyChecked),
                    const SizedBox(width: 10),
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: " Read privacy policy here",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  openLink(
                                      'https://docs.google.com/document/d/1_NepunQdFUiS3kJkadvvkhHv0oATsBOrvIWu4Wsg3Zw/preview');
                                },
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xfffe6929),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                        activeColor: const Color(0xffff6533),
                        onChanged: (val) {
                          setState(() => termsChecked = val!);
                          if (termsChecked && privacyChecked) {
                            setState(() => isActive = true);
                          } else {
                            setState(() => isActive = false);
                          }
                        },
                        value: termsChecked),
                    const SizedBox(width: 10),
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          text: 'Terms of Service',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: " Read terms of service here",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  openLink(
                                      'https://docs.google.com/document/d/1bdNWsB2GuHBHnRFQwhKGLKQUOdzee7-BEEXrCWkedMU/preview');
                                },
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xfffe6929),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: !isActive
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    isLoading = true;
                                    isActive = false;
                                  });
                                  var result =
                                      await _auth.registerWithEmailAndPassword(
                                          emailEditingController.text,
                                          passwordEditingController.text,
                                          fullNameEditingController.text);
                                  await _auth.createUserInFirestore(
                                      fullNameEditingController.text,
                                      passwordEditingController.text);
                                  await _auth.createUserWallet();
                                  if (result.toString() !=
                                      "Instance of 'UserId'") {
                                    if (context.mounted) {
                                      debugPrint(result.toString());
                                      setState(() {
                                        isActive = true;
                                        isLoading = false;
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      isActive = true;
                                      isLoading = false;
                                    });
                                    if (context.mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => VerifyScreen(
                                                  value: emailEditingController
                                                      .text,
                                                  isNumber: isNumber,
                                                  confirmationResult:
                                                      confirmationResult,
                                                  password:
                                                      passwordEditingController
                                                          .text,
                                                  fullName:
                                                      fullNameEditingController
                                                          .text,
                                                )),
                                      );
                                    }
                                  }
                                }
                              },
                        child: !isLoading
                            ? const Text('Continue',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))
                            : const CircularProgressIndicator(
                                color: Colors.white))),
                const SizedBox(
                  height: 20,
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
                            text: 'Already have an account?',
                            children: [
                          TextSpan(
                              text: ' Log In',
                              style: TextStyle(
                                color: Color(0xffff6533),
                              ))
                        ])),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch$url';
    }
  }
}
