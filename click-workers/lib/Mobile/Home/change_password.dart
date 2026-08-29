import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/Mobile/authentication/utils/auth.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final AuthProvider _auth = AuthProvider();
  // form key
  final _formKey = GlobalKey<FormState>();
  // Initially password is obscure
  bool _obscureText = true;

//_obscureText2 for confirm password
  bool _obscureText2 = true;

//_obscureText3 for confirm password
  bool _obscureText3 = true;

  final TextEditingController currentPasswordEditingController =
      TextEditingController();
  final TextEditingController newPasswordEditingController =
      TextEditingController();
  final TextEditingController confirmPasswordEditingController =
      TextEditingController();

  @override
  void dispose() {
    currentPasswordEditingController.dispose();
    newPasswordEditingController.dispose();
    confirmPasswordEditingController.dispose();
    super.dispose();
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

  // _toggle3 for new password
  void _toggle3() {
    setState(() {
      _obscureText3 = !_obscureText3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPasswordField = TextFormField(
      autofocus: false,
      controller: currentPasswordEditingController,
      obscureText: _obscureText3,
      validator: (val) => val!.length < 6
          ? 'Password must contain at least 6 characters'
          : null,
      onSaved: (value) async {
        currentPasswordEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: 'Enter your current password',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffix: InkWell(
          onTap: _toggle3,
          child: Icon(
            _obscureText3 ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
        ),
      ),
    );

    final newPasswordField = TextFormField(
      autofocus: false,
      controller: newPasswordEditingController,
      obscureText: _obscureText,
      validator: (val) => val!.length < 6
          ? 'Password must contain at least 6 characters'
          : null,
      onSaved: (value) async {
        newPasswordEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: 'Create new password',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
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
      validator: (val) => val != newPasswordEditingController.text
          ? 'Not the same with password'
          : null,
      onSaved: (value) async {
        confirmPasswordEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: 'Confirm your new password',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new), // or any custom icon
          onPressed: () {
            Navigator.of(context).pop(); // Go back
          },
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Change Password',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xffeeeeee),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Form(
            key: _formKey,
            child: SizedBox(
              width: 90.w,
              child: Card(
                elevation: 6, // adds shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Current Password",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      currentPasswordField,
                      SizedBox(height: 4.h),
                      const Text(
                        "New Password",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      newPasswordField,
                      SizedBox(height: 4.h),
                      const Text(
                        "Confirm New Password",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      confirmPasswordField,
                      SizedBox(height: 4.h),
                      SizedBox(
                        width: 80.w,
                        child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                var result = _auth.attemptPasswordChange(
                                    currentPassword:
                                        currentPasswordEditingController.text,
                                    newPassword:
                                        newPasswordEditingController.text);
                                if (result.toString() != "") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(20),
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.black),
                            child: const Text("Save Changes",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
