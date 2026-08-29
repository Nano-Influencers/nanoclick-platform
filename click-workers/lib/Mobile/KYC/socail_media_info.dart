import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SocialMediaInfo extends StatefulWidget {
  const SocialMediaInfo({super.key});

  @override
  State<SocialMediaInfo> createState() => _SocialMediaInfoState();
}

class _SocialMediaInfoState extends State<SocialMediaInfo> {
  String selectedValue1 = 'Facebook';
  String selectedValue2 = 'Less than 3 months';

  String? radioValue1;
  String? radioValue2;
  String? radioValue3;
  String? radioValue4;
  String? radioValue5;

  String? usesForBusiness;
  String businessName2 = '';
  String businessDuration2 = 'Less than 3 months';
  String businessNature2 = '';

  String? reachFollowers;
  String followerCount = '';
  String followingCount = '';

  String? hasBusinessAccount;
  String businessName3 = '';
  String businessDuration3 = 'Less than 3 months';
  String businessNature3 = '';

  String? hasBusinessAccount2;
  String businessName4 = '';
  String businessDuration4 = 'Less than 3 months';
  String businessNature4 = '';

  String? hasBusinessAccount3;
  String businessName5 = '';
  String businessDuration5 = 'Less than 3 months';
  String businessNature5 = '';

  String? singleContainerValue;
  String textField1 = '';
  String textField2 = '';
  String textField3 = '';
  String dropdownValue = 'Option 1';

  String? specificYesNo;
  String specificTextField = '';
  String specificDropdown = 'Option 1';

 final List<String> businessDurationOptions = [
  'Less than 3 months',
  '3-6 months',
  '6-12 months',
  '1-2 years',
  'More than 2 years'
];

  final List<String> socialMedials = [
    'Facebook',
    'TikTok',
    'Instagram',
    'Twitter',
    'WhatsApp'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 6,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Color(0xFF757575),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Instruction',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInstructionList(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            _infoHeaderText('Select Social Media Account'),
            const SizedBox(height: 10),
            Card(
              elevation: 6,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Social Media Account',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdownField(
                      selectedValue: selectedValue1,
                      selectedItems: socialMedials,
                      onChanged: (val) {
                        setState(() {
                          selectedValue1 = val!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            _infoHeaderText('Account Identity & Verification'),
            const SizedBox(height: 10),
            _buildAccountIdentityForm(),
         




            const SizedBox(height: 25),
            _infoHeaderText('Reach and Followers'),
            const SizedBox(height: 10),
           
          ],
        ),
      ),
    );
  }

  _infoHeaderText(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 1, color: Colors.black)),
      child: Text(text,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAccountIdentityForm() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildYesNoQuestion(
                question:
                    'Is this a personal social media account that you actively manage?',
                groupValue: radioValue1,
                onChanged: (value) {
                setState(() {
                    radioValue1 = value;
                });
                },
              ),
              const SizedBox(height: 16),
              _buildTextInputField(
                'What is the direct link to this social media account? (Your Profile URL)',
              ),
              const SizedBox(height: 16),
              _buildTextInputField(
                'What is the username of this social media account? (e.g. @clickworkers)',
              ),
              const SizedBox(height: 16),
              const Text(
                'How Old is this Social Media Account?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildDropdownField(
                selectedValue: selectedValue2,
                selectedItems: const [
                  'Less than 3 months',
                  '3-6 months',
                  '6-12 months',
                  '1-2 years',
                  'more than 2 years'
                ],
                onChanged: (value) {
                  setState(() {
                    selectedValue2 = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildYesNoQuestion(
                question: 'Do you have a description/bio on this account?',
                groupValue: radioValue2,
                onChanged: (value) {
                  setState(() {
                    radioValue2 = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildYesNoQuestion(
                question:
                    'Is the name on your social media profile your real name?',
                groupValue: radioValue3,
                onChanged: (value) {
                  setState(() {
                    radioValue3 = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildYesNoQuestion(
                question: 'Is the profile picture a real picture of you?',
                groupValue: radioValue4,
                onChanged: (value) {
                  setState(() {
                    radioValue4 = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildYesNoQuestion(
                question: 'Is this social media account verified?',
                groupValue: radioValue5,
                onChanged: (value) {
                  setState(() {
                    radioValue5 = value;
                  });
                },
              ),

              Text('Screenshot your social media profile page (Capture the name, description, etc.).')
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionList() {
    final instructions = [
      'This section of the KYC allows you to add the social media accounts you will use to perform tasks and get tasks approved.',
      'Do not use an Alt account, you are advised to use your real social account for quality.',
      'You must add at least three accounts, with WhatsApp being mandatory.',
      'After entering your details, click "Add" to save.',
      'You can update any information at any time using the "Edit" button.',
      'Please ensure all details are accurate. Tasks can only be performed using social media accounts that have added in this section.',
      'If an account is not listed, you must add it before performing the tasks tied to the Social Media account.',
      'You may also be required to update your social media and worker information within a specified timeframe when/if prompted.',
    ];

    return Column(
      children: instructions.map((instruction) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6, right: 8),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF757575),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  instruction,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF616161),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildYesNoQuestion({
    required String question,
    required String? groupValue,
    required void Function(String value) onChanged,
    bool subTitle = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        if (subTitle)
          const Text(
            'If No then you won’t be able to perform tasks for this account.',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Yes'),
                value: 'yes',
                groupValue: groupValue, // ✅ SAME VALUE
                activeColor: Colors.black,
                onChanged: (value) => onChanged(value!),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('No'),
                value: 'no',
                groupValue: groupValue, // ✅ SAME VALUE
                activeColor: Colors.black,
                onChanged: (value) => onChanged(value!),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextInputField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey, width: 2),
            ),
          ),
        ),
      ],
    );
  }

 Widget _buildDropdownField({
  required String selectedValue,
  required List<String> selectedItems,
  required Function(String?) onChanged,
}) {
  return SizedBox(
    height: 8.h,
    width: double.infinity,
    child: DropdownButtonFormField<String>(
      value: selectedItems.contains(selectedValue) ? selectedValue : null,
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey, width: 2),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down),
      items: selectedItems.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: onChanged,
    ),
  );
}



  
}
