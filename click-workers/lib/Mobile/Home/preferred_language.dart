import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PreferredLanguage extends StatefulWidget {
  const PreferredLanguage({super.key});

  @override
  State<PreferredLanguage> createState() => _PreferredLanguageState();
}

class _PreferredLanguageState extends State<PreferredLanguage> {
  final TextEditingController searchController = TextEditingController();

  List<String> allLanguages = [
    'English (UK)',
    'Español',
    'Français',
    'Deutsch',
    'Português',
    'Italiano',
  ];

  String? selectedLanguage = "English (UK)";
  String query = '';

  @override
  Widget build(BuildContext context) {
    List<String> filteredLanguages = allLanguages
        .where((lang) => lang.toLowerCase().contains(query.toLowerCase()))
        .toList();

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
          child: Text('Preferred Language',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              if (selectedLanguage != "English (UK)") {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Language not added yet!')),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Language changed')),
                  );
                }
              }
            },
            child: const Text(
              'Apply',
              style: TextStyle(color: Color(0xffff6533), fontSize: 12),
            ),
          )
        ],
      ),
      backgroundColor: const Color(0xffeeeeee),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: 90.w,
          child: Card(
            elevation: 6, // adds shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: searchController,
                    onChanged: (val) => setState(() => query = val),
                    decoration: InputDecoration(
                      hintText: 'Search Languages',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Popular Languages',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredLanguages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        String lang = filteredLanguages[index];
                        bool isSelected = lang == selectedLanguage;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedLanguage = lang;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.grey.shade300
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(lang),
                                if (isSelected)
                                  const Icon(Icons.check, color: Colors.green),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
