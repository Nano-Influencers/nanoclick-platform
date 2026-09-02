import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/Mobile/authentication/utils/auth.dart';

Future<void> showDeleteDialog(BuildContext context) async {
  final TextEditingController textController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String error = "";

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Account',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 100.w,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Are you sure you want to delete your Account?\n'
                    'This action cannot be undone. All your data, including profile information, history, and settings will be permanently deleted',
                    style: TextStyle(fontSize: 12, color: Color(0xff6b7280)),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: textController,
                    validator: (value) {
                      if (value?.toLowerCase() != 'delete') {
                        return 'Please type "delete" to confirm';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Type the word delete',
                      hintStyle: const TextStyle(
                        color: Colors.redAccent, // 👈 Your custom color here
                        fontSize: 12,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  error != ""
                      ? Text(
                          error,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.redAccent),
                        )
                      : const SizedBox(height: 0),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6533),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final auth = AuthProvider();
                          final errorMessage = await auth.deleteAccount();
                          if (errorMessage != null) {
                            setState(() => error = errorMessage);
                          } else if (context.mounted) {
                            // deleteAccount() already signs out; popping
                            // back to root lets the auth-state stream show
                            // the landing/sign-in screen. (The previous
                            // Navigator.pushReplacementNamed('/login') here
                            // was already broken pre-Firebase-removal too —
                            // this app has no named routes registered
                            // anywhere for '/login' to resolve to.)
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          }
                        }
                      },
                      child: const Text('Proceed'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6b7280), // dark gray
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    },
  );
}
