import 'package:flutter/material.dart';
import 'package:click_workers/Mobile/authentication/forgotPassword/reset_success.dart';
import 'package:click_workers/Mobile/authentication/sign_in.dart';
import 'package:click_workers/Mobile/authentication/utils/auth.dart';

class NewPassword extends StatefulWidget {
  const NewPassword({super.key, required this.oobCode});

  final String oobCode;

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final _formKey = GlobalKey<FormState>();
  final AuthProvider _auth = AuthProvider();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscureText = true;
  bool _obscureText2 = true;

  bool isLoading = false;
  String error = '';
  bool isError = false;

  void _toggle() => setState(() => _obscureText = !_obscureText);
  void _toggle2() => setState(() => _obscureText2 = !_obscureText2);

  @override
  Widget build(BuildContext context) {
    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordController,
      obscureText: _obscureText,
      validator: (val) => val!.length < 6
          ? 'Password must contain at least 6 characters'
          : null,
      onSaved: (value) async {
        confirmPasswordController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: 'New Password',
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
      controller: confirmPasswordController,
      obscureText: _obscureText2,
      validator: (val) =>
          val != passwordController.text ? 'Not the same with password' : null,
      onSaved: (value) async {
        confirmPasswordController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: 'Confirm new Password',
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
      // appBar: AppBar(
      //   leading: IconButton(
      //       icon: const Icon(Icons.arrow_back_ios, color: const Color(0xffff6533),),
      //       onPressed: () {
      //         Navigator.pop(context);
      //       }),
      //   leadingWidth: 20,
      //   centerTitle: false,
      //   title: const Text('Back',
      //       style: TextStyle(color: const Color(0xffff6533), fontSize: 18)),
      // ),
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
              Image.asset('assets/auth/reset_password.png'),
              const SizedBox(
                height: 10,
              ),
              const Text('Reset Your Password',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(
                height: 5,
              ),
              const Text('Input your new password'),
              const SizedBox(
                height: 20,
              ),
              passwordField,
              const SizedBox(height: 10),
              confirmPasswordField,

              const SizedBox(height: 20),

              /// ERROR
              if (isError)
                Text(error, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 20),
              SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                  isError = false;
                                });

                                final result = await _auth.confirmPasswordReset(
                                  widget.oobCode,
                                  passwordController.text.trim(),
                                );

                                setState(() => isLoading = false);

                                if (result != null) {
                                  setState(() {
                                    error = result;
                                    isError = true;
                                  });
                                } else {
                                  if (context.mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const ResetSuccess()),
                                    );
                                  }
                                }
                              }
                            },
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Change Password',
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
