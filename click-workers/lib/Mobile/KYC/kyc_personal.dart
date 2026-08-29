import 'package:click_workers/Mobile/KYC/socail_media_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'account_verification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/cupertino.dart';

class KycPersonal extends StatefulWidget {
  const KycPersonal({super.key});

  @override
  State<KycPersonal> createState() => _KycPersonalState();
}

class _KycPersonalState extends State<KycPersonal> {
  TextEditingController fullNameEditingController = TextEditingController();
  TextEditingController townEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController secStateEditingController = TextEditingController();
  TextEditingController whatsAppEditingController = TextEditingController();
  TextEditingController townResEditingController = TextEditingController();
  TextEditingController cityEditingController = TextEditingController();

  // form key
  final _formKey = GlobalKey<FormState>();

  bool isChecked = false;
  bool isChecked10 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;
  bool isChecked4 = false;
  bool isChecked5 = false;
  bool isChecked6 = false;
  bool isChecked7 = false;
  bool isChecked8 = false;
  bool isChecked9 = false;
  String genderVal = "0";
  String accountVal = "0";
  String selectedValue = "Select age bracket Blow 18 and 60 above";
  String selectedValue2 = "Select marital status";
  String selectedValue3 = "Enter country of origin";
  String selectedValue4 = "Enter state of origin";
  String selectedValue5 = "Enter country of residence";
  String selectedValue6 = "Enter state of residence";
  String selectedValue7 = "Select Religion";
  String selectedValue8 = "Select Ethnicity/Tribe";
  String selectedValue9 = "Select Race";
  String selectedValue10 = "Select Monthly Income Range";
  String selectedValue11 = "Select Profession";
  List languages = [];
  List hobbies = [];
  List occupation = [];

  final options = [
   
  ];


  final technicalEducation = ['Trade School', 'Skill Acquisition Centres'];
  List<String> ages = [
    "Select age bracket Blow 18 and 60 above",
    "18 - 24",
    "25 - 30",
    "31 - 40",
    "41 - 50",
    "51 - 60"
  ];

  List<String> profession = [
    "Select Profession",
    'Teacher',
    'Engineer',
    'Doctor',
    'Lawyer',
    'Accountant',
    'Nurse',
    'Software Developer',
    'Electrician',
    'Police Officer',
    'Photographer',
  ];

  List<String> income = [
    "Select Monthly Income Range",
    'Less than ₦50,000',
    '₦50,000 – ₦100,000',
    '₦100,001 – ₦250,000',
    '₦250,001 – ₦500,000',
    'Above ₦500,000',
  ];

  List<String> race = [
    "Select Race",
    'Black or African',
    'White or Caucasian',
    'Asian',
    'Hispanic or Latino',
    'Indigenous or Native',
  ];

  List<String> religion = ["Select Religion", "Christian", "Muslim"];

  List<String> tribe = [
    "Select Ethnicity/Tribe",
    "Igbo",
    "Hausa",
    "Yoruba",
    "Other",
  ];

  List<String> maritalStatus = [
    "Select marital status",
    "Single  -  (Never Married)",
    "Married - (Legally Married)",
    'Divorced - (Marriage Legally Ended)',
    "Separated - (Still Legally Married but Living Apart)",
    'Widowed - (Spouse Has Passed Away)'
  ];

  List<String> country = [
    "Enter country of origin",
    "Nigeria",
    "Ghana",
  ];

  List<String> countryResidence = [
    "Enter country of residence",
    "Nigeria",
    "Ghana",
  ];

  List<String> stateNig = [
    "Enter state of origin",
    'Abia',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara',
    'FCT - Abuja',
  ];

  List<String> stateNigR = [
    "Enter state of residence",
    'Abia',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara',
    'FCT - Abuja',
  ];

  List<String> stateGha = [
    "Enter state of origin",
    'Ahafo',
    'Ashanti',
    'Bono',
    'Bono East',
    'Central',
    'Eastern',
    'Greater Accra',
    'North East',
    'Northern',
    'Oti',
    'Savannah',
    'Upper East',
    'Upper West',
    'Volta',
    'Western',
    'Western North',
  ];

  List<String> stateGhaR = [
    "Enter state of residence",
    'Ahafo',
    'Ashanti',
    'Bono',
    'Bono East',
    'Central',
    'Eastern',
    'Greater Accra',
    'North East',
    'Northern',
    'Oti',
    'Savannah',
    'Upper East',
    'Upper West',
    'Volta',
    'Western',
    'Western North',
  ];

  Future<void> updateKycProgress(double value) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception("No user logged in");
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await userRef.set(
      {
        "kycProgress": value,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> createKycPersonal(
      List hobbies, List languages, List occupation) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      await FirebaseFirestore.instance.collection('kyc').doc(uid).set({
        "personal": {
          "fullName": fullNameEditingController.text, // String
          "gender": genderVal, // int
          "ageBracket": selectedValue, // DateTime
          "maritalStatus": selectedValue2, // String
          "countryOfOrigin": selectedValue3, // String
          "stateOfOrigin": selectedValue4, // bool
          "townOfOrigin": townEditingController.text,
          "countryOfResidence": selectedValue5,
          "stateOfResidence": selectedValue6,
          "secondaryStateOfResidence": secStateEditingController.text,
          "cityOfPrimaryResidence": cityEditingController.text,
          "townOfPrimaryResidence": townResEditingController.text,
          "religion": selectedValue7,
          "ethicityOrTribe": selectedValue8,
          "languages": languages,
          "race": selectedValue9,
          "hobbies": hobbies,
          "occupation": occupation,
          "monthlyIncomeRange": selectedValue10,
          "emailAdress": emailEditingController.text,
          "whatsAppContact": whatsAppEditingController.text,
          "profession": selectedValue11,
          "accountType": accountVal, // Firestore timestamp
        }
      }, SetOptions(merge: true));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error creating KYC document: $e"),
            duration: const Duration(seconds: 2), // how long it shows
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullNameField = TextFormField(
      controller: fullNameEditingController,
      validator: (val) => val!.isEmpty ? 'Fill out this field' : null,
      decoration: InputDecoration(
        hintText: 'Enter your full name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Fully rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );

    final emailField = TextFormField(
      controller: emailEditingController,
      validator: (val) => val!.isEmpty ? 'Fill out this field' : null,
      decoration: InputDecoration(
        hintText: 'Enter your Email Address',
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xff6b7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Fully rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );

    final whatsAppField = TextFormField(
      controller: whatsAppEditingController,
      validator: (val) => val!.isEmpty ? 'Fill out this field' : null,
      decoration: InputDecoration(
        hintText: 'Enter your WhatsApp Contact',
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xff6b7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Fully rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );

    final townOfOriginField = TextFormField(
      controller: townEditingController,
      validator: (val) => val!.isEmpty ? 'Fill out this field' : null,
      decoration: InputDecoration(
        hintText: 'Enter Town of Origin',
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xff6b7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Fully rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );

    final secStateOfResidenceField = TextFormField(
      controller: secStateEditingController,
      decoration: InputDecoration(
        hintText: 'Enter Secondary State of Residence',
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xff6b7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Fully rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );

    final cityOfResidenceField = TextFormField(
      controller: cityEditingController,
      validator: (val) => val!.isEmpty ? 'Fill out this field' : null,
      decoration: InputDecoration(
        hintText: 'Enter City of Primary Residence',
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xff6b7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Fully rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );

    final townOfResidenceField = TextFormField(
      controller: townResEditingController,
      validator: (val) => val!.isEmpty ? 'Fill out this field' : null,
      decoration: InputDecoration(
        hintText: 'Enter Town of Primary Residence',
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xff6b7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Fully rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          child: Text('Kyc Verification',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xffeeeeee),
      body: SingleChildScrollView(
          child: Center(
              child: Form(
        key: _formKey,
        child: SizedBox(
            width: 90.w,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 2.h,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          width: 30.w,
                          decoration: BoxDecoration(
                              color: const Color(0xffff6533),
                              borderRadius: BorderRadius.circular(20)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(Icons.account_circle, color: Colors.white),
                              Text("Worker Info",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12))
                            ],
                          ),
                        ),
                        SizedBox(width: 2.w),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>const SocialMediaInfo(),)),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            width: 30.w,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: const Color(0xffd1d5db)),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Icon(Icons.chat,
                                    color: Color(0xff6b7280), size: 22),
                                Text("Social Media",
                                    style: TextStyle(
                                        color: Color(0xff6b7280), fontSize: 12))
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: const EdgeInsets.all(5),
                          width: 30.w,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: const Color(0xffd1d5db)),
                              borderRadius: BorderRadius.circular(20)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(Icons.chat,
                                  color: Color(0xff6b7280), size: 22),
                              Text("SM Check",
                                  style: TextStyle(
                                      color: Color(0xff6b7280), fontSize: 12))
                            ],
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: const EdgeInsets.all(5),
                          width: 30.w,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: const Color(0xffd1d5db)),
                              borderRadius: BorderRadius.circular(20)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(Icons.chat,
                                  color: Color(0xff6b7280), size: 22),
                              Text("Verify Docs",
                                  style: TextStyle(
                                      color: Color(0xff6b7280), fontSize: 12))
                            ],
                          ),
                        ),
                      ],
                    )),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(width: 1, color: Colors.black)),
                    child: Text("Personal Information",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xff545454),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text("Update",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 90.w,
                child: Card(
                    elevation: 6, // adds shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Full Name",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 0.5.h),
                            fullNameField,
                            SizedBox(height: 2.h),
                            const Text("Gender",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 2.h),
                            Row(children: [
                              Radio(
                                  value: "Male",
                                  groupValue: genderVal,
                                  activeColor: Colors.black,
                                  onChanged: (val) {
                                    setState(() {
                                      genderVal = "Male";
                                    });
                                  }),
                              SizedBox(
                                width: 1.w,
                              ),
                              const Text("Male",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(width: 5.w),
                              Radio(
                                  value: "Female",
                                  activeColor: Colors.black,
                                  groupValue: genderVal,
                                  onChanged: (val) {
                                    setState(() {
                                      genderVal = "Female";
                                    });
                                  }),
                              SizedBox(
                                width: 1.w,
                              ),
                              const Text("Female",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ]),
                            SizedBox(height: 2.h),
                            const Text("Age Bracket",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 0.5.h),
                            SizedBox(
                              height: 8.h,
                              width: 90.w,
                              child: DropdownButtonFormField(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 2),
                                  ),
                                ),
                                value: selectedValue,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: ages
                                    .map((option) => DropdownMenuItem(
                                          value: option,
                                          child: Text(option,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff6b7280))),
                                        ))
                                    .toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedValue = newValue!;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 2.h),
                            const Text("Marital Status",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            SizedBox(height: 0.5.h),
                            SizedBox(
                              height: 8.h,
                              width: 90.w,
                              child: DropdownButtonFormField(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 2),
                                  ),
                                ),
                                value: selectedValue2,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: maritalStatus
                                    .map((option) => DropdownMenuItem(
                                          value: option,
                                          child: Text(option,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff6b7280))),
                                        ))
                                    .toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedValue2 = newValue!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ))),
              ),
              const SizedBox(height: 30),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(width: 1, color: Colors.black)),
                child: Text("Contact Information",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 90.w,
                child: Card(
                    elevation: 6, // adds shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Phone",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 0.5.h),
                            fullNameField,
                            SizedBox(height: 2.h),
                            const Text("Email Address",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 0.5.h),
                            fullNameField,
                            SizedBox(height: 2.h),
                            const Text("Alternative Phone",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 0.5.h),
                            fullNameField,
                            SizedBox(height: 2.h),
                            const Text("Alternative Email",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 0.5.h),
                            fullNameField,
                            SizedBox(height: 2.h),
                          ],
                        ))),
              ),

              const SizedBox(height: 30),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(width: 1, color: Colors.black)),
                child: Text("Location Information",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                  width: 90.w,
                  child: Card(
                      elevation: 6, // adds shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Country of Origin",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                SizedBox(height: 0.5.h),
                                SizedBox(
                                  height: 8.h,
                                  width: 90.w,
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 2),
                                      ),
                                    ),
                                    value: selectedValue3,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: country
                                        .map((option) => DropdownMenuItem(
                                              value: option,
                                              child: Text(option,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xff6b7280))),
                                            ))
                                        .toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedValue3 = newValue!;
                                        selectedValue4 =
                                            "Enter state of origin";
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                const Text("State of Origin",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                SizedBox(height: 0.5.h),
                                SizedBox(
                                  height: 8.h,
                                  width: 90.w,
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 2),
                                      ),
                                    ),
                                    value: selectedValue4,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: selectedValue3 == "Nigeria"
                                        ? stateNig
                                            .map((option) => DropdownMenuItem(
                                                  value: option,
                                                  child: Text(option,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                              0xff6b7280))),
                                                ))
                                            .toList()
                                        : selectedValue3 == "Ghana"
                                            ? stateGha
                                                .map((option) =>
                                                    DropdownMenuItem(
                                                      value: option,
                                                      child: Text(option,
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color(
                                                                  0xff6b7280))),
                                                    ))
                                                .toList()
                                            : [
                                                const DropdownMenuItem(
                                                    value:
                                                        "Enter state of origin",
                                                    child: Text(
                                                        "Enter state of origin",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Color(
                                                                0xff6b7280))))
                                              ],
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedValue4 = newValue!;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                const Text(
                                    "Local Government of Origin or MMDAs",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                SizedBox(height: 0.5.h),
                                townOfOriginField,
                                SizedBox(
                                  height: 2.h,
                                ),
                                const Text("Home Town",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                SizedBox(height: 0.5.h),
                                SizedBox(
                                  height: 8.h,
                                  width: 90.w,
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 2),
                                      ),
                                    ),
                                    value: selectedValue5,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: countryResidence
                                        .map((option) => DropdownMenuItem(
                                              value: option,
                                              child: Text(option,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xff6b7280))),
                                            ))
                                        .toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedValue5 = newValue!;
                                        selectedValue6 =
                                            "Enter state of residence";
                                      });
                                    },
                                  ),
                                ),
                              ])))),
              const SizedBox(height: 10),
              SizedBox(
                  width: 90.w,
                  child: Card(
                      elevation: 6, // adds shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Country of Secondary Residence",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                SizedBox(height: 0.5.h),
                                SizedBox(
                                  height: 8.h,
                                  width: 90.w,
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 2),
                                      ),
                                    ),
                                    value: selectedValue3,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: country
                                        .map((option) => DropdownMenuItem(
                                              value: option,
                                              child: Text(option,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xff6b7280))),
                                            ))
                                        .toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedValue3 = newValue!;
                                        selectedValue4 =
                                            "Enter state of origin";
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                const Text("State of Secondary Residence",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                SizedBox(height: 0.5.h),
                                SizedBox(
                                  height: 8.h,
                                  width: 90.w,
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 2),
                                      ),
                                    ),
                                    value: selectedValue4,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: selectedValue3 == "Nigeria"
                                        ? stateNig
                                            .map((option) => DropdownMenuItem(
                                                  value: option,
                                                  child: Text(option,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                              0xff6b7280))),
                                                ))
                                            .toList()
                                        : selectedValue3 == "Ghana"
                                            ? stateGha
                                                .map((option) =>
                                                    DropdownMenuItem(
                                                      value: option,
                                                      child: Text(option,
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color(
                                                                  0xff6b7280))),
                                                    ))
                                                .toList()
                                            : [
                                                const DropdownMenuItem(
                                                    value:
                                                        "Enter state of origin",
                                                    child: Text(
                                                        "Enter state of origin",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Color(
                                                                0xff6b7280))))
                                              ],
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedValue4 = newValue!;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                const Text(
                                    "LGA of Secondary Residence or MMDAs",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                SizedBox(height: 0.5.h),
                                townOfOriginField,
                                SizedBox(
                                  height: 2.h,
                                ),
                                const Text("City/Town of Secondary Residence",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                SizedBox(height: 0.5.h),
                                SizedBox(
                                  height: 8.h,
                                  width: 90.w,
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 2),
                                      ),
                                    ),
                                    value: selectedValue5,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: countryResidence
                                        .map((option) => DropdownMenuItem(
                                              value: option,
                                              child: Text(option,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xff6b7280))),
                                            ))
                                        .toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedValue5 = newValue!;
                                        selectedValue6 =
                                            "Enter state of residence";
                                      });
                                    },
                                  ),
                                ),
                                const Text(
                                    "Area/District/Estate of Secondary Residence",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                SizedBox(height: 0.5.h),
                                townOfOriginField,
                                SizedBox(
                                  height: 2.h,
                                ),
                                const Text("Street Name",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                SizedBox(height: 0.5.h),
                                townOfOriginField,
                              ])))),

              // SizedBox(
              //     width: 90.w,
              //     child: Card(
              //         elevation: 6, // adds shadow
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(16),
              //         ),
              //         color: Colors.white,
              //         child: Padding(
              //             padding: const EdgeInsets.all(20),
              //             child: Column(
              //                 mainAxisSize: MainAxisSize.min,
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   SizedBox(
              //                     height: 2.h,
              //                   ),
              //                   const Text("State of Residence",
              //                       style: TextStyle(
              //                           fontWeight: FontWeight.bold,
              //                           fontSize: 12)),
              //                   SizedBox(height: 0.5.h),
              //                   SizedBox(
              //                     height: 8.h,
              //                     width: 90.w,
              //                     child: DropdownButtonFormField(
              //                       isExpanded: true,
              //                       decoration: InputDecoration(
              //                         border: OutlineInputBorder(
              //                           borderRadius: BorderRadius.circular(10),
              //                         ),
              //                         enabledBorder: OutlineInputBorder(
              //                           borderRadius: BorderRadius.circular(10),
              //                           borderSide: const BorderSide(
              //                               color: Colors.grey),
              //                         ),
              //                         focusedBorder: OutlineInputBorder(
              //                           borderRadius: BorderRadius.circular(10),
              //                           borderSide: const BorderSide(
              //                               color: Colors.grey, width: 2),
              //                         ),
              //                       ),
              //                       value: selectedValue6,
              //                       icon: const Icon(Icons.keyboard_arrow_down),
              //                       items: selectedValue5 == "Nigeria"
              //                           ? stateNigR
              //                               .map((option) => DropdownMenuItem(
              //                                     value: option,
              //                                     child: Text(option,
              //                                         style: const TextStyle(
              //                                             fontSize: 12,
              //                                             fontWeight:
              //                                                 FontWeight.bold,
              //                                             color: Color(
              //                                                 0xff6b7280))),
              //                                   ))
              //                               .toList()
              //                           : selectedValue5 == "Ghana"
              //                               ? stateGhaR
              //                                   .map((option) =>
              //                                       DropdownMenuItem(
              //                                         value: option,
              //                                         child: Text(option,
              //                                             style: const TextStyle(
              //                                                 fontSize: 12,
              //                                                 fontWeight:
              //                                                     FontWeight
              //                                                         .bold,
              //                                                 color: Color(
              //                                                     0xff6b7280))),
              //                                       ))
              //                                   .toList()
              //                               : [
              //                                   const DropdownMenuItem(
              //                                       value:
              //                                           "Enter state of residence",
              //                                       child: Text(
              //                                           "Enter state of residence",
              //                                           style: TextStyle(
              //                                               fontSize: 12,
              //                                               color: Color(
              //                                                   0xff6b7280))))
              //                                 ],
              //                       onChanged: (newValue) {
              //                         setState(() {
              //                           selectedValue6 = newValue!;
              //                         });
              //                       },
              //                     ),
              //                   ),
              //                   SizedBox(height: 2.h),
              //                   const Text(
              //                       "Secondary State of Residence (if applicable)",
              //                       style: TextStyle(
              //                           fontWeight: FontWeight.bold,
              //                           fontSize: 12)),
              //                   SizedBox(height: 0.5.h),
              //                   secStateOfResidenceField,
              //                   SizedBox(
              //                     height: 2.h,
              //                   ),
              //                   SizedBox(height: 2.h),
              //                   const Text("City of Primary Residence",
              //                       style: TextStyle(
              //                           fontWeight: FontWeight.bold,
              //                           fontSize: 12)),
              //                   SizedBox(height: 0.5.h),
              //                   cityOfResidenceField,
              //                   SizedBox(
              //                     height: 2.h,
              //                   ),
              //                   SizedBox(height: 2.h),
              //                   const Text("Town of Primary Residence",
              //                       style: TextStyle(
              //                           fontWeight: FontWeight.bold,
              //                           fontSize: 12)),
              //                   SizedBox(height: 0.5.h),
              //                   townOfResidenceField,
              //                   SizedBox(
              //                     height: 2.h,
              //                   ),
              //                 ])))),
              const SizedBox(height: 30),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(width: 1, color: Colors.black)),
                child: Text("Demographics",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                  width: 90.w,
                  child: Card(
                      elevation: 6, // adds shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Religion",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  )),
                              SizedBox(height: 0.5.h),
                              SizedBox(
                                height: 8.h,
                                width: 90.w,
                                child: DropdownButtonFormField(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 2),
                                    ),
                                  ),
                                  value: selectedValue7,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  items: religion
                                      .map((option) => DropdownMenuItem(
                                            value: option,
                                            child: Text(option,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xff6b7280))),
                                          ))
                                      .toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedValue7 = newValue!;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 2.h),
                              const Text("Ethnicity/Tribe",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  )),
                              SizedBox(height: 0.5.h),
                              SizedBox(
                                height: 8.h,
                                width: 90.w,
                                child: DropdownButtonFormField(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 2),
                                    ),
                                  ),
                                  value: selectedValue8,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  items: tribe
                                      .map((option) => DropdownMenuItem(
                                            value: option,
                                            child: Text(option,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xff6b7280))),
                                          ))
                                      .toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedValue8 = newValue!;
                                    });
                                  },
                                ),
                              ),
                              // SizedBox(height: 4.h),
                              // const Text("Languages (Select all that apply)",
                              //     style: TextStyle(
                              //         fontSize: 12,
                              //         fontWeight: FontWeight.bold)),
                              // SizedBox(height: 1.h),
                              // Row(children: [
                              //   Checkbox(
                              //     activeColor: Colors.black,
                              //     value: isChecked,
                              //     onChanged: (bool? newValue) {
                              //       setState(() {
                              //         isChecked = newValue!;
                              //         if (isChecked == true) {
                              //           languages.add("English");
                              //         } else {
                              //           languages.remove("English");
                              //         }
                              //       });
                              //     },
                              //   ),
                              //   SizedBox(width: 2.w),
                              //   const Text("English",
                              //       style:
                              //           TextStyle(fontWeight: FontWeight.bold))
                              // ]),
                              // Row(children: [
                              //   Checkbox(
                              //     activeColor: Colors.black,
                              //     value: isChecked2,
                              //     onChanged: (bool? newValue) {
                              //       setState(() {
                              //         isChecked2 = newValue!;
                              //         if (isChecked2 == true) {
                              //           languages.add("French");
                              //         } else {
                              //           languages.remove("French");
                              //         }
                              //       });
                              //     },
                              //   ),
                              //   SizedBox(width: 2.w),
                              //   const Text("French",
                              //       style:
                              //           TextStyle(fontWeight: FontWeight.bold))
                              // ]),
                              // Row(children: [
                              //   Checkbox(
                              //     activeColor: Colors.black,
                              //     value: isChecked3,
                              //     onChanged: (bool? newValue) {
                              //       setState(() {
                              //         isChecked3 = newValue!;
                              //         if (isChecked3 == true) {
                              //           languages.add("Yoruba");
                              //         } else {
                              //           languages.remove("Yoruba");
                              //         }
                              //       });
                              //     },
                              //   ),
                              //   SizedBox(width: 2.w),
                              //   const Text("Yoruba",
                              //       style:
                              //           TextStyle(fontWeight: FontWeight.bold))
                              // ]),
                              // Row(children: [
                              //   Checkbox(
                              //     activeColor: Colors.black,
                              //     value: isChecked4,
                              //     onChanged: (bool? newValue) {
                              //       setState(() {
                              //         isChecked4 = newValue!;
                              //         if (isChecked4 == true) {
                              //           languages.add("Igbo");
                              //         } else {
                              //           languages.remove("Igbo");
                              //         }
                              //       });
                              //     },
                              //   ),
                              //   SizedBox(width: 2.w),
                              //   const Text("Igbo",
                              //       style:
                              //           TextStyle(fontWeight: FontWeight.bold))
                              // ]),
                              // Row(children: [
                              //   Checkbox(
                              //     activeColor: Colors.black,
                              //     value: isChecked5,
                              //     onChanged: (bool? newValue) {
                              //       setState(() {
                              //         isChecked5 = newValue!;
                              //         if (isChecked5 == true) {
                              //           languages.add("Hausa");
                              //         } else {
                              //           languages.remove("Hausa");
                              //         }
                              //       });
                              //     },
                              //   ),
                              //   SizedBox(width: 2.w),
                              //   const Text("Hausa",
                              //       style:
                              //           TextStyle(fontWeight: FontWeight.bold))
                              // ]),
                              SizedBox(height: 2.h),
                              const Text("Race",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  )),
                              SizedBox(height: 0.5.h),
                              SizedBox(
                                height: 8.h,
                                width: 90.w,
                                child: DropdownButtonFormField(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 2),
                                    ),
                                  ),
                                  value: selectedValue9,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  items: race
                                      .map((option) => DropdownMenuItem(
                                            value: option,
                                            child: Text(option,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xff6b7280))),
                                          ))
                                      .toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedValue9 = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          )))),

              const SizedBox(height: 30),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(width: 1, color: Colors.black)),
                child: Text("Interest/Hobbies",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                  width: 90.w,
                  child: Card(
                      elevation: 6, // adds shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Interest/Hobbies",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp)),
                              Text(
                                  "(Select a Min of 5 and a Max of 10 Interest/Hobbies)",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                      color: const Color(0xfffe6929))),
                              SizedBox(height: 0.5.h),
                              TextFormField(
                                maxLines: 5,
                                controller: townEditingController,
                                validator: (val) =>
                                    val!.isEmpty ? 'Fill out this field' : null,
                                decoration: InputDecoration(
                                  hintStyle: const TextStyle(
                                      fontSize: 12, color: Color(0xff6b7280)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Fully rounded corners
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                ),
                              )
                            ],
                          )))),
              const SizedBox(height: 30),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(width: 1, color: Colors.black)),
                child: Text("Skills you Possess",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                  width: 90.w,
                  child: Card(
                      elevation: 6, // adds shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Skills",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp)),
                              Text("(Select a Min of 3 and a Max of 10 Skills)",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                      color: const Color(0xfffe6929))),
                              SizedBox(height: 0.5.h),
                              TextFormField(
                                maxLines: 5,
                                controller: townEditingController,
                                validator: (val) =>
                                    val!.isEmpty ? 'Fill out this field' : null,
                                decoration: InputDecoration(
                                  hintStyle: const TextStyle(
                                      fontSize: 12, color: Color(0xff6b7280)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Fully rounded corners
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                ),
                              )
                            ],
                          )))),
              const SizedBox(height: 30),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(width: 1, color: Colors.black)),
                child: Text("Occupation/Economic Details",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                  width: 90.w,
                  child: Card(
                      elevation: 6, // adds shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Occupation",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 3.h),
                                const Text(
                                    "Select the occupation that best suit you",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xfffe6929),
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 1.h),
                                const EmploymentForm(),
                                const Text("Monthly Income",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    )),
                                SizedBox(height: 0.5.h),
                                SizedBox(
                                  height: 8.h,
                                  width: 90.w,
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 2),
                                      ),
                                    ),
                                    value: selectedValue10,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: income
                                        .map((option) => DropdownMenuItem(
                                              value: option,
                                              child: Text(option,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xff6b7280))),
                                            ))
                                        .toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedValue10 = newValue!;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                const Text("Primary Source of Income",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                SizedBox(height: 0.5.h),
                                emailField,
                                SizedBox(
                                  height: 2.h,
                                ),
                                SizedBox(height: 2.h),
                                const Text("Secondary Source of Income",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                SizedBox(height: 0.5.h),
                                whatsAppField,
                                SizedBox(
                                  height: 2.h,
                                ),
                              ])))),
              SizedBox(height: 2.h),
              SizedBox(
                  width: 90.w,
                  child: Card(
                      elevation: 6, // adds shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Additional Information",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 3.h),
                                const Text(
                                    "Interests/Hobbies (Select all that apply)",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 1.h),
                                Row(children: [
                                  Checkbox(
                                    activeColor: Colors.black,
                                    value: isChecked6,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        isChecked6 = newValue!;
                                        if (isChecked6 == true) {
                                          hobbies.add("Cooking");
                                        } else {
                                          hobbies.remove("Cooking");
                                        }
                                      });
                                    },
                                  ),
                                  SizedBox(width: 2.w),
                                  const Text("Cooking",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))
                                ]),
                                Row(children: [
                                  Checkbox(
                                    activeColor: Colors.black,
                                    value: isChecked7,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        isChecked7 = newValue!;
                                        if (isChecked7 == true) {
                                          hobbies.add("Reading");
                                        } else {
                                          hobbies.remove("Reading");
                                        }
                                      });
                                    },
                                  ),
                                  SizedBox(width: 2.w),
                                  const Text("Reading",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))
                                ]),
                                Row(children: [
                                  Checkbox(
                                    activeColor: Colors.black,
                                    value: isChecked8,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        isChecked8 = newValue!;
                                        if (isChecked8 == true) {
                                          hobbies.add("Sports");
                                        } else {
                                          hobbies.remove("Sports");
                                        }
                                      });
                                    },
                                  ),
                                  SizedBox(width: 2.w),
                                  const Text("Sports",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))
                                ]),
                                Row(children: [
                                  Checkbox(
                                    activeColor: Colors.black,
                                    value: isChecked9,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        isChecked9 = newValue!;
                                        if (isChecked9 == true) {
                                          hobbies.add("Music");
                                        } else {
                                          hobbies.remove("Music");
                                        }
                                      });
                                    },
                                  ),
                                  SizedBox(width: 2.w),
                                  const Text("Music",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))
                                ]),
                                Row(children: [
                                  Checkbox(
                                    activeColor: Colors.black,
                                    value: isChecked10,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        isChecked10 = newValue!;
                                        if (isChecked10 == true) {
                                          hobbies.add("Traveling");
                                        } else {
                                          hobbies.remove("Traveling");
                                        }
                                      });
                                    },
                                  ),
                                  SizedBox(width: 2.w),
                                  const Text("Traveling",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))
                                ]),
                                SizedBox(height: 2.h),
                                const Text("Monthly Income Range",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    )),
                                SizedBox(height: 0.5.h),
                                SizedBox(
                                  height: 8.h,
                                  width: 90.w,
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 2),
                                      ),
                                    ),
                                    value: selectedValue10,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: income
                                        .map((option) => DropdownMenuItem(
                                              value: option,
                                              child: Text(option,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xff6b7280))),
                                            ))
                                        .toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedValue10 = newValue!;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                const Text("Email Address",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                SizedBox(height: 0.5.h),
                                emailField,
                                SizedBox(
                                  height: 2.h,
                                ),
                                SizedBox(height: 2.h),
                                const Text("WhatsApp Contact",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                SizedBox(height: 0.5.h),
                                whatsAppField,
                                SizedBox(
                                  height: 2.h,
                                ),
                                SizedBox(height: 2.h),
                                const Text("Profession",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    )),
                                SizedBox(height: 0.5.h),
                                SizedBox(
                                  height: 8.h,
                                  width: 90.w,
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 2),
                                      ),
                                    ),
                                    value: selectedValue11,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: profession
                                        .map((option) => DropdownMenuItem(
                                              value: option,
                                              child: Text(option,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xff6b7280))),
                                            ))
                                        .toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedValue11 = newValue!;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                const Text(
                                    "Type of Social Media Account You Mainly Use",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 2.h),
                                Row(children: [
                                  Radio(
                                      value: "Business",
                                      groupValue: accountVal,
                                      activeColor: Colors.black,
                                      onChanged: (val) {
                                        setState(() {
                                          accountVal = "Business";
                                        });
                                      }),
                                  SizedBox(
                                    width: 1.w,
                                  ),
                                  const Text("Business",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(width: 7.w),
                                  Radio(
                                      value: "Personal",
                                      activeColor: Colors.black,
                                      groupValue: accountVal,
                                      onChanged: (val) {
                                        setState(() {
                                          accountVal = "Personal";
                                        });
                                      }),
                                  SizedBox(
                                    width: 1.w,
                                  ),
                                  const Text("Personal",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ]),
                              ])))),

           


              SizedBox(height: 2.h),
                SizedBox(
                  width: 90.w,
                  height: 8.h,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xfffe6929),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: ()  {
                     
                      },
                      child: const Text("Save"))),

                      SizedBox(height: 1.h,),
              SizedBox(
                  width: 90.w,
                  height: 8.h,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (genderVal != "0") {
                            if (selectedValue != "Select age bracket" &&
                                selectedValue2 != "Select marital status" &&
                                selectedValue3 != "Enter country of origin" &&
                                selectedValue4 != "Enter state of origin" &&
                                selectedValue5 !=
                                    "Enter country of residence" &&
                                selectedValue6 != "Enter state of residence" &&
                                selectedValue7 != "Select Religion" &&
                                selectedValue8 != "Select Ethnicity/Tribe" &&
                                selectedValue9 != "Select Race" &&
                                selectedValue10 !=
                                    "Select Monthly Income Range" &&
                                selectedValue11 != "Select Profession") {
                              if (isChecked ||
                                  isChecked2 ||
                                  isChecked3 ||
                                  isChecked4 ||
                                  isChecked5) {
                                if (isChecked6 ||
                                    isChecked7 ||
                                    isChecked8 ||
                                    isChecked9 ||
                                    isChecked10) {
                                  if (accountVal != "0") {
                                    await createKycPersonal(
                                        hobbies, languages, occupation);
                                    await updateKycProgress(0.3);
                                    if (context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SMAccountVerification()),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Please select an Account type"),
                                        duration: Duration(
                                            seconds: 2), // how long it shows
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please select a Hobby"),
                                      duration: Duration(
                                          seconds: 2), // how long it shows
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select a Language"),
                                    duration: Duration(
                                        seconds: 2), // how long it shows
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Please add all neccessary information"),
                                  duration:
                                      Duration(seconds: 2), // how long it shows
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select Gender"),
                                duration:
                                    Duration(seconds: 2), // how long it shows
                              ),
                            );
                          }
                        }
                      },
                      child: const Text("Continue"))),
              SizedBox(height: 3.h),
            ])),
      ))),
    );
  }
}

class EmploymentForm extends StatefulWidget {
  const EmploymentForm({super.key});

  @override
  State<EmploymentForm> createState() => _EmploymentFormState();
}

class _EmploymentFormState extends State<EmploymentForm> {
  String? employmentStatus;
  String? studentStatus;
  String? highSchoolStatus;
  String? vocationalStatus;
  String? employedStatus;

  final options = [
    "Student",
    "Employed",
    "Self-Employed/Entrepreneur",
    "Unemployed/Seeking Opportunities",
    "Retired (Aged based Retirement)",
  ];

  final employed = ['Online', 'Onsite', 'Hybrid'];

  final students = [
    "Tertiary Institution Student",
    "High School",
    "Vocational/Technical Education",
  ];

  Widget inputField(String hint) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: options.map((option) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Radio<String>(
                    value: option,
                    groupValue: employmentStatus,
                    activeColor: Colors.black,
                    onChanged: (val) {
                      setState(() {
                        employmentStatus = val!;
                        studentStatus = null; // reset
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              /// 🔥 STUDENT SECTION
              if (option == "Student" && employmentStatus == "Student")
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: students.map((student) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Radio<String>(
                                value: student,
                                groupValue: studentStatus,
                                activeColor: Colors.black,
                                onChanged: (val) {
                                  setState(() {
                                    studentStatus = val!;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  student,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),

                          /// 🔥 TERTIARY
                          if (student == "Tertiary Institution Student" &&
                              studentStatus == "Tertiary Institution Student")
                            _section([
                              _label("School Attended"),
                              inputField("Enter school"),
                              _label("City/Town"),
                              inputField("Enter city"),
                              _label("Department"),
                              inputField("Enter department"),
                            ]),

                          /// 🔥 HIGH SCHOOL
                          if (student == "High School" &&
                              studentStatus == "High School")
                            _section([
                              _label("School Name"),
                              inputField("Enter school"),
                              _label("City/Town"),
                              inputField("Enter city"),

                              /// CLASS RADIO
                              Row(
                                children: [
                                  Radio<String>(
                                    value: "JSS",
                                    groupValue: highSchoolStatus,
                                    activeColor: Colors.black,
                                    onChanged: (val) {
                                      setState(() {
                                        highSchoolStatus = val!;
                                      });
                                    },
                                  ),
                                  const Text("JSS"),
                                  Radio<String>(
                                    value: "SSS",
                                    groupValue: highSchoolStatus,
                                    activeColor: Colors.black,
                                    onChanged: (val) {
                                      setState(() {
                                        highSchoolStatus = val!;
                                      });
                                    },
                                  ),
                                  const Text("SSS"),
                                ],
                              ),

                              _label("Class"),
                              inputField("Enter class"),
                            ]),

                          /// 🔥 VOCATIONAL
                          if (student == "Vocational/Technical Education" &&
                              studentStatus == "Vocational/Technical Education")
                            _section([
                              Row(
                                children: [
                                  Radio<String>(
                                    value: "Trade School",
                                    groupValue: vocationalStatus,
                                    activeColor: Colors.black,
                                    onChanged: (val) {
                                      setState(() {
                                        vocationalStatus = val!;
                                      });
                                    },
                                  ),
                                  const Text("Trade School"),
                                ],
                              ),
                              if (student == "Vocational/Technical Education" &&
                                  studentStatus ==
                                      "Vocational/Technical Education" &&
                                  vocationalStatus == "Trade School")
                                _section([
                                  _label("Name of Trade School"),
                                  inputField("Name of Trade School"),
                                  _label("City/Town Trade School is Located"),
                                  inputField(
                                      "City/Town Trade School is Located"),
                                  _label("What are you Currently Learning"),
                                  inputField("What are you Currently Learning"),
                                ]),
                              Row(
                                children: [
                                  Radio<String>(
                                    value: "Skill Acquisition Centres",
                                    groupValue: vocationalStatus,
                                    activeColor: Colors.black,
                                    onChanged: (val) {
                                      setState(() {
                                        vocationalStatus = val!;
                                      });
                                    },
                                  ),
                                  const Text("Skill Acquisition Centres"),
                                ],
                              ),
                                     if (student == "Vocational/Technical Education" &&
                                  studentStatus ==
                                      "Vocational/Technical Education" &&
                                  vocationalStatus == "Skill Acquisition Centres")
                                _section([
                                  _label("Name of Skill Acquisition Centres"),
                                  inputField("Name of Trade School"),
                                  _label("City/Town Skill Acquisition Centres is Located"),
                                  inputField(
                                      "City/Town Skill Acquisition Centres is Located"),
                                  _label("What are you Currently Learning"),
                                  inputField("What are you Currently Learning"),
                                ]),
                            ]),
                        ],
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 10),

              if (option == "Employed" && employmentStatus == "Employed")
                Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: _section([
                      _label(
                          "Select the Industry that best describes where you are Working  (Max of 3)"),
                      inputField(" "),
                      _label(
                          "Location (Select the City/Town that your workplace is located)"),
                      inputField(" "),
                      _label(
                          "Brief of what the place where you are Employed Does?"),
                      inputField(" "),
                      _label("How you Work?"),
                      Expanded(
                        child: Row(
                            children: employed
                                .map(
                                  (employ) => Row(
                                    children: [
                                      Radio<String>(
                                        value: employ,
                                        groupValue: employedStatus,
                                        activeColor: Colors.black,
                                        onChanged: (val) {
                                          setState(() {
                                            employedStatus = val!;
                                          });
                                        },
                                      ),
                                      Text(employ),
                                    ],
                                  ),
                                )
                                .toList()),
                      )
                    ])),

              const SizedBox(height: 10),

              if (option == "Self-Employed/Entrepreneur" &&
                  employmentStatus == "Self-Employed/Entrepreneur")
                Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: _section([
                      _label(
                          "Select the Industry that best describes your Business  (Max of 3)"),
                      inputField(" "),
                      _label(
                          "Location (Select the City/Town that your Business is located)"),
                      inputField(" "),
                      _label(
                          "Brief of what your Business/Freelance does or is all about?"),
                      inputField(" "),
                      _label("How you Work?"),
                      Expanded(
                        child: Row(
                            children: employed
                                .map(
                                  (employ) => Row(
                                    children: [
                                      Radio<String>(
                                        value: employ,
                                        groupValue: employedStatus,
                                        activeColor: Colors.black,
                                        onChanged: (val) {
                                          setState(() {
                                            employedStatus = val!;
                                          });
                                        },
                                      ),
                                      Text(employ),
                                    ],
                                  ),
                                )
                                .toList()),
                      )
                    ])),

              const SizedBox(height: 10),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// 🔥 CLEAN SECTION WRAPPER
  Widget _section(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: e,
                ))
            .toList(),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
