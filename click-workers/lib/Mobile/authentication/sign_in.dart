import 'package:flutter/material.dart';
import 'package:click_workers/Mobile/authentication/utils/user.dart' as userid;
import 'package:firebase_auth/firebase_auth.dart' as fire;
import 'package:click_workers/Mobile/authentication/utils/google_sign_in.dart';
import 'package:click_workers/Mobile/authentication/utils/facebook_sign_in.dart';
import 'package:click_workers/Mobile/authentication/sign_up.dart';
import 'package:click_workers/Mobile/authentication/forgotPassword/forgot_password.dart';
import 'package:click_workers/Mobile/authentication/utils/auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthProvider _auth = AuthProvider();
  bool isActive = false;
  String error = '';
  bool isError = false;
  bool _obscureText = true;
  bool isLoading = false;
  bool checkboxValue = false;
  final TextEditingController passwordEditingController =
      TextEditingController();
  final TextEditingController emailEditingController = TextEditingController();

  //  Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  //confirmation result is dynamic
  dynamic confirmationResult = '';

  //validates email adress
  bool isValidEmail(String email) {
    // Regex for email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // form key
  final _formKey = GlobalKey<FormState>();

  bool isNumber = false;

  //snackBar widget
  void showSnackBar(context) {
    const snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      width: 300,
      backgroundColor: Colors.white,
      content: Text('Reset link sent, check your email',
          style: TextStyle(color: Colors.black)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //reset password
  Future resetPassword() async {
    try {
      await fire.FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailEditingController.text.trim());
    } on fire.FirebaseAuthException catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    //emailField
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
        hintText: 'Password',
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
                    const Text('Log In',
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
                            emailEditingController.text,
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
                            emailEditingController.text,
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
                const Text('Email'),
                const SizedBox(height: 5),
                emailField,
                const SizedBox(
                  height: 20,
                ),
                const Text('Password'),
                const SizedBox(height: 5),
                passwordField,
                const SizedBox(
                  height: 5,
                ),
                !isError
                    ? const SizedBox(height: 0)
                    : Text(
                        '* $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Transform.scale(
                        scale: 0.8,
                        child: Checkbox(
                            activeColor: const Color(0xffff6533),
                            onChanged: (val) {
                              setState(() {
                                checkboxValue = val!;
                              });
                            },
                            value: checkboxValue),
                      ),
                      const SizedBox(width: 5),
                      const Text('Keep me signed in',
                          style: TextStyle(fontSize: 12)),
                    ]),
                    TextButton(
                      child: const Text('Forgot Password',
                          style: TextStyle(
                            color: Color(0xffff6533),
                            fontSize: 12,
                          )),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ForgotPassword()),
                        );
                      },
                    )
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
                        onPressed:() async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    isLoading = true;
                                    // isActive = false;
                                  });
                                  var result =
                                      await _auth.signInWithEmailAndPassword(
                                          emailEditingController.text,
                                          passwordEditingController.text);
                                  if (result is! userid.UserId?) {
                                    if (context.mounted) {
                                      setState(() {
                                        error = result.toString();
                                        // isActive = true;
                                        isLoading = false;
                                        isError = true;
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      // isActive = true;
                                      isLoading = false;
                                    });
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  }
                                }
                              },
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Continue',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)))),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUp()),
                      );
                    },
                    child: RichText(
                        text: const TextSpan(
                            text: "Don't have an account?",
                            children: [
                          TextSpan(
                              text: ' Sign Up',
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
}
