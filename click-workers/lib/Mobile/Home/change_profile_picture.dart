import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../authentication/utils/profile_photo_state.dart';

class ChangeDP extends StatefulWidget {
  const ChangeDP({super.key});

  @override
  State<ChangeDP> createState() => _ChangeDPState();
}

class _ChangeDPState extends State<ChangeDP> {
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  // cloudinary credentials
  final String cloudName = "dihpawfyc";
  final String uploadPreset = "click-uploads";

  //  Upload image to Firebase Storage and update Auth + Firestore
  Future<void> _uploadAndUpdate(Uint8List imageBytes) async {
    try {
      setState(() => isUploading = true);

      final uid = FirebaseAuth.instance.currentUser!.uid;

      // // Fixed path ensures old photo gets overwritten
      // final storageRef = FirebaseStorage.instance.ref().child('profile_photos/$uid.jpg');

      // // Upload (overwrite old file if exists)
      // await storageRef.putData(
      //   imageBytes,
      //   SettableMetadata(contentType: 'image/jpeg'), // ensures proper type
      // );

      // //  Get download URL
      // final photoUrl = await storageRef.getDownloadURL();

      // Prepare multipart request
      final uri =
          Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'profile_photo.jpg',
        ));

      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final result = json.decode(resBody);

      if (response.statusCode == 200) {
        final photoUrl = result['secure_url'];

        // Update Firebase Auth photoURL
        await FirebaseAuth.instance.currentUser!.updatePhotoURL(photoUrl);

        // Update Firestore dp field
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'dp': photoUrl});

        // Update local state for instant UI change
        ProfilePhotoState.photoUrl.value = photoUrl;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated!')),
          );
        }
      } else {
        throw Exception(
            "Cloudinary upload failed: ${result['error']['message']}");
      }
    } catch (e) {
      debugPrint("Error: $e");
     if(mounted) { ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );}
    } finally {
      setState(() => isUploading = false);
    }
  }

  //  Take photo from camera
  Future<void> takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      await _uploadAndUpdate(bytes);
    }
  }

  //  Choose from gallery
  Future<void> chooseFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      await _uploadAndUpdate(bytes);
    }
  }

  //remove photo
  Future<void> removePhoto() async {
    setState(() {
      isUploading = true;
    });
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Reset Firebase Auth photoURL
    await user.updatePhotoURL(null);

    // Reset Firestore dp field
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({"dp": ""});

    // Update local state for instant UI change
    ProfilePhotoState.photoUrl.value = null;

    setState(() {
      isUploading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Text('Change profile picture',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xffeeeeee),
      body: Padding(
        padding: const EdgeInsets.all(20),
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
                children: [
                  FirebaseAuth.instance.currentUser!.photoURL == null
                      ? CircleAvatar(
                          radius: 100,
                          backgroundColor: const Color(0xffeeeeee),
                          child: Center(
                              child: Text(
                                  FirebaseAuth
                                      .instance.currentUser!.displayName![0]
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 100,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold))))
                      : ValueListenableBuilder<String?>(
                          valueListenable: ProfilePhotoState.photoUrl,
                          builder: (context, photoUrl, _) {
                            return CircleAvatar(
                              radius: 100,
                              backgroundImage:
                                  photoUrl != null && photoUrl.isNotEmpty
                                      ? NetworkImage(
                                          FirebaseAuth
                                              .instance.currentUser!.photoURL
                                              .toString(),
                                        )
                                      : null,
                              child: photoUrl == null || photoUrl.isEmpty
                                  ? Center(
                                      child: Text(
                                          FirebaseAuth.instance.currentUser!
                                              .displayName![0]
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              fontSize: 100,
                                              color: Colors.black,
                                              fontWeight: FontWeight
                                                  .bold))) // placeholder icon
                                  : null,
                            );
                          }),
                  SizedBox(height: 3.h),
                  SizedBox(
                    width: 50.w,
                    child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xffd9d9d9),
                            child: Center(
                              child: IconButton(
                                  icon:
                                      Icon(Icons.zoom_out, color: Colors.black),
                                  onPressed: null),
                            ),
                          ),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xffd9d9d9),
                            child: Center(
                              child: IconButton(
                                  icon: Icon(Icons.crop, color: Colors.black),
                                  onPressed: null),
                            ),
                          ),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xffd9d9d9),
                            child: Center(
                              child: IconButton(
                                  icon:
                                      Icon(Icons.zoom_in, color: Colors.black),
                                  onPressed: null),
                            ),
                          ),
                        ]),
                  ),
                  SizedBox(height: 5.h),
                  SizedBox(
                    width: 80.w,
                    child: ElevatedButton(
                        onPressed: isUploading
                            ? null
                            : () {
                                takePhoto();
                              },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(20),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black),
                        child: RichText(
                            text: const TextSpan(text: "", children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(Icons.photo_camera,
                                size: 18, color: Colors.white),
                          ),
                          TextSpan(
                              text: " Take Photo",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ))
                        ]))),
                  ),
                  SizedBox(height: 3.h),
                  SizedBox(
                    width: 80.w,
                    child: ElevatedButton(
                        onPressed: isUploading
                            ? null
                            : () {
                                chooseFromGallery();
                              },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(20),
                            foregroundColor: Colors.black,
                            backgroundColor: const Color(0xffd1d5db)),
                        child: RichText(
                            text: const TextSpan(text: "", children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(Icons.image,
                                size: 18, color: Colors.black),
                          ),
                          TextSpan(
                              text: " Choose from Gallery",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ))
                        ]))),
                  ),
                  SizedBox(height: 3.h),
                  SizedBox(
                    width: 80.w,
                    child: ElevatedButton(
                        onPressed: isUploading
                            ? null
                            : () {
                                removePhoto();
                              },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(20),
                            foregroundColor: Colors.red,
                            backgroundColor: const Color(0xffd1d5db)),
                        child: RichText(
                            text: const TextSpan(text: "", children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child:
                                Icon(Icons.delete, size: 18, color: Colors.red),
                          ),
                          TextSpan(
                              text: " Remove Photo",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ))
                        ]))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
