import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // form key
  final _formKey = GlobalKey<FormState>();
  String phoneNumber = "";
  String birthday = "2000-01-01";

  String uid = FirebaseAuth.instance.currentUser!.uid;

  //validates email adress
  bool isValidEmail(String email) {
    // Regex for email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  //Editing Controllers
  final fullNameEditingController = TextEditingController(
      text: FirebaseAuth.instance.currentUser!.displayName);
  final userNameEditingController = TextEditingController(
      text:
          "@${FirebaseAuth.instance.currentUser!.displayName!.replaceAll(' ', '').toLowerCase()}");
  late TextEditingController dobEditingController =
      TextEditingController(text: birthday);
  late TextEditingController phoneNumberEditingController =
      TextEditingController(text: phoneNumber);
  final emailEditingController =
      TextEditingController(text: FirebaseAuth.instance.currentUser!.email);

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepOrange, // header background
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // OK & Cancel button color
              ),
            ),
          ),
          child: child!,
        );
      },
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate =
          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      setState(() {
        dobEditingController.text = formattedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSelectedFields();
  }

  @override
  void dispose() {
    dobEditingController.dispose();
    fullNameEditingController.dispose();
    userNameEditingController.dispose();
    phoneNumberEditingController.dispose();
    emailEditingController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> getFields(String userId) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId); // Only return 'name' and 'email'

      final snapshot = await docRef.get();

      if (snapshot.exists) {
        return snapshot.data(); // Only contains the selected fields
      } else {
        debugPrint("No document found for user: $userId");
        return null;
      }
    } catch (e) {
      debugPrint("Error getting selected fields: $e");
      return null;
    }
  }

  //update firestore values
  Future<void> updateUser(
      String userId, Map<String, dynamic> updatedData) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(updatedData); // Only updates the given fields
    } catch (e) {
      debugPrint("Error updating user: $e");
    }
  }

  //fetch fields
  void fetchSelectedFields() async {
    final data = await getFields(uid);
    if (data != null) {
      setState(() {
        phoneNumber = data['phoneNumber'];
        birthday = data['birthday'];
        dobEditingController = TextEditingController(text: birthday);
        phoneNumberEditingController = TextEditingController(text: phoneNumber);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullNameField = TextFormField(
      readOnly: true,
      autofocus: false,
      controller: fullNameEditingController,
      keyboardType: TextInputType.name,
      validator: (val) => val!.isEmpty ? 'Fill out this field' : null,
      onSaved: (value) async {
        fullNameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    final emailField = TextFormField(
      readOnly: true,
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

    final dobField = GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: dobEditingController,
          validator: (val) => val!.isEmpty ? 'Fill out this field' : null,
          readOnly: true, // prevent manua
          decoration: InputDecoration(
            suffix: const Icon(Icons.calendar_today, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );

    final phoneNumberField = TextFormField(
      autofocus: false,
      controller: phoneNumberEditingController,
      keyboardType: TextInputType.number,
      validator: (val) => val!.isEmpty ? 'Fill out this field' : null,
      onSaved: (value) async {
        phoneNumberEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: 'Enter your Phone Number',
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    final userNameField = TextFormField(
      readOnly: true,
      autofocus: false,
      controller: userNameEditingController,
      keyboardType: TextInputType.name,
      validator: (val) => val!.isEmpty ? 'Fill out this field' : null,
      onSaved: (value) async {
        userNameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
          child: Text('Edit Profile',
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
                        "Full Name",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      fullNameField,
                      SizedBox(height: 3.h),
                      const Text(
                        "Username",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      userNameField,
                      SizedBox(height: 3.h),
                      const Text(
                        "Email",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      emailField,
                      SizedBox(height: 3.h),
                      const Text(
                        "Phone Number",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      phoneNumberField,
                      SizedBox(height: 3.h),
                      const Text(
                        "Date of Birth",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      dobField,
                      SizedBox(height: 3.h),
                      SizedBox(
                        width: 80.w,
                        child: ElevatedButton(
                            onPressed: () async {
                              await updateUser(uid, {
                                'phoneNumber':
                                    phoneNumberEditingController.text,
                                'birthday': dobEditingController.text,
                              });
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
