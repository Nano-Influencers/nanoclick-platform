import 'package:flutter/material.dart';
import 'package:click_workers/Mobile/authentication/sign_in.dart';
import 'package:click_workers/Mobile/authentication/utils/auth.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({
    super.key,
  });

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailEditingController = TextEditingController();
  bool isNull = true;
  bool isLoading = false;
  bool isNumber = false;
  bool isError = false;
  String error = '';

  final AuthProvider _auth = AuthProvider();

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

  @override
  Widget build(BuildContext context) {
    //emailField
    final emailField = TextFormField(
      autofocus: false,
      controller: emailEditingController,
      validator: (val) {
        if (val!.isNotEmpty) {
          if (isNumber) {
            if (val.length != 11) {
              return 'Please enter a valid phone number';
            } else {
              return null;
            }
          } else {
            if (!isValidEmail(val)) {
              return 'Please enter a valid email';
            } else {
              return null;
            }
          }
        } else {
          return 'Fill out this field';
        }
      },
      onSaved: (value) {
        setState(() => isNull = false);
        if (isValidEmail(value!)) {
          setState(() {
            isNumber = false;
            isNull = false;
          });
        } else {
          setState(() => isNumber = true);
        }
        emailEditingController.text = value;
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
              const Text('Forgot your password?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(
                height: 5,
              ),
              const Text('Enter the email associated with your account'),
              const SizedBox(
                height: 20,
              ),
              emailField,
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
              const Text(
                  'Enter the Email you used to register. You will receive a link to reset your password.',
                  style: TextStyle(color: Color(0xff64748B), fontSize: 10)),
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
                      onPressed: () async {
                        setState(() {
                          isNull = true;
                          isLoading = true;
                        });
                        if (_formKey.currentState!.validate()) {
                          var result = await _auth
                              .forgotPassword(emailEditingController.text);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Reset link sent. Open it and return to the app after changing password.",
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              error = result;
                            });
                          } else {
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                        }
                      },
                      child: const Text('Send Link',
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
