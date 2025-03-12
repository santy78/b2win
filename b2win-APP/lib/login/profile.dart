import 'dart:io';
import 'dart:typed_data';

import 'package:b2winai/service/AuthService.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  String profilePictureFileName = '';
  @override
  void initState() {
    super.initState();
  }

  Future<void> _setProfilePicture(BuildContext context) async {
    try {
      if (profilePictureFileName == "") {
        return;
      }
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String imagesDirPath = '${appDocDir.path}/images';
      final Directory imagesDir = Directory(imagesDirPath);
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      final String filePath = '$imagesDirPath/$profilePictureFileName';
      final File file = File(filePath);
      if (await file.exists()) {
        setState(() {
          _profileImage = file; // Set the profile image
        });
      } else {
        final Uint8List bytes =
            await ApiService.profilePictureDownloadFile(context);
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String imagesDirPath = '${appDocDir.path}/images';
        final Directory imagesDir = Directory(imagesDirPath);
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }
        final String filePath = '$imagesDirPath/$profilePictureFileName';
        final File file = File(filePath);
        await file.writeAsBytes(bytes);
        setState(() {
          _profileImage = file; // Set the profile image
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('imageFilename', profilePictureFileName);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile picture: $e')),
      );
    }
  }

  Future<void> _uploadImage(context) async {
    if (_profileImage != null) {
      File image = await compressImage(_profileImage!);
      try {
        final response = await ApiService.updateProfilePicture(image, context);

        if (response['statuscode'] == 200) {
          if (response['data']['image_filename'] != "") {
            SharedPreferences prefs = await SharedPreferences.getInstance();

            await prefs.setString(
                'imageFilename', response['data']['image_filename']);
          }

          final snackBar = SnackBar(
            content: Text(response['message']),
            duration: const Duration(seconds: 2),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          Future.delayed(snackBar.duration, () {
            //Navigator.pushNamed(context, RouterConstant.dashboard);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'])),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $e")),
        );
      }
    }
  }

  Future<bool?> _showConfirmationDialog(context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Upload'),
          content: Text('Do you want to upload this image?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<File> compressImage(File imageFile) async {
    final bytes = imageFile.readAsBytesSync();
    final decodedImage = img.decodeImage(bytes);

    // Resize the image to reduce file size (e.g., reducing to 50% size)
    final resizedImage =
        img.copyResize(decodedImage!, width: decodedImage.width ~/ 2);

    final compressedFile = File(imageFile.path)
      ..writeAsBytesSync(
          img.encodeJpg(resizedImage, quality: 85)); // Adjust the quality

    return compressedFile;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      bool? confirm = await _showConfirmationDialog(context);

      if (confirm == true) {
        _uploadImage(context);
      } else {
        // If the user cancels, you can clear the selected image if needed
        setState(() {
          _profileImage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              color: Colors.grey.shade200,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade400,
                    child: Text(
                      "K",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    "keshab hazra",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            SizedBox(height: 20),

            // Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Settings",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text("Notifications"),
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {
                          // Handle switch toggle
                        },
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    ListTile(
                      leading: Icon(Icons.support_agent),
                      title: Text("Contact support"),
                      onTap: () {
                        // Handle contact support action
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    ListTile(
                      leading: Icon(Icons.privacy_tip),
                      title: Text("Privacy policy"),
                      onTap: () {
                        // Handle privacy policy action
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text("Logout"),
                      onTap: () {
                        AuthService.logout(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Profile tab is active
        onTap: (index) {
          // Handle bottom navigation
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_cricket),
            label: "My Cricket",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Stats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
