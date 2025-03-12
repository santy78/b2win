import 'dart:io';
import 'dart:typed_data';

import 'package:b2winai/scoreBoard/teams/teamList.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewTeamPage extends StatefulWidget {
  @override
  _NewTeamPageState createState() => _NewTeamPageState();
}

class _NewTeamPageState extends State<NewTeamPage> {
  String? selectedContestId;
  String teamName = "";
  String city = "";
  String phoneNumber = "";
  String teamId = "";
  List<Map<String, dynamic>> contests = [];
  List<Map<String, dynamic>> players = [];
  List<Map<String, dynamic>> selectedPlayers = [];
  bool noContestExists = false;
  File? _teamLogo;
  String teamLogoFileName = '';

  @override
  void initState() {
    super.initState();
    createNoContests();
    getContests();
    Future.delayed(Duration(seconds: 3), () {
      createNoContests();
    });

    getPlayers();
  }

  Future<void> getContests() async {
    try {
      Map<String, dynamic> response = await ApiService.getContest(context);
      if (response['statuscode'] == 200) {
        setState(() {
          contests = List<Map<String, dynamic>>.from(response['data']);
        });
      }
    } catch (e) {
      _showSnackbar("Error fetching contests: $e");
    }
  }

  Future<void> createNoContests() async {
    try {
      contests.forEach((contests) {
        if (contests['name'].toString() == 'No_Contest') {
          setState(() {
            noContestExists = true;
          });
        }
      });
      if (!noContestExists) {
        Map<String, dynamic> response =
            await ApiService.createNoContest(context);
        if (response['statuscode'] == 200) {
          setState(() {
            contests = List<Map<String, dynamic>>.from(response['data']);
            noContestExists = false;
            getContests();
            contests.map((contests) {
              if (contests['name'].toString() == 'No_Contest') {
                setState(() {
                  selectedContestId = contests['contest_id'].toString();
                });
              }
            });
          });
        }
      } else {
        print("already nocontest id exists");
      }
    } catch (e) {
      _showSnackbar("Error fetching contests: $e");
    }
  }

  Future<void> getPlayers() async {
    try {
      Map<String, dynamic> response = await ApiService.getAllPlayers(context);
      if (response['statuscode'] == 200) {
        setState(() {
          players = List<Map<String, dynamic>>.from(response['data']);
        });
      } else {
        _showSnackbar(response['message']);
      }
    } catch (e) {
      _showSnackbar("Error fetching players: $e");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> createTeam() async {
    if (selectedContestId == null ||
        teamName.isEmpty ||
        city.isEmpty ||
        phoneNumber.isEmpty) {
      _showSnackbar("Please complete all fields");
      return;
    }

    try {
      final response = await ApiService.createTeams(
          selectedContestId!, teamName, city, phoneNumber, context);
      if (response['statuscode'] == 200) {
        _showSnackbar(response['message']);
        //Assign team id to the variable teamId
        setState(() {
          teamId = "";
        });
        //call the team logo upload api
        _uploadImage(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => TeamsListPage()));
      } else {
        _showSnackbar(response['message']);
      }
    } catch (e) {
      _showSnackbar("Error creating team: $e");
    }
  }

  Future<void> _setProfilePicture(BuildContext context) async {
    try {
      if (teamLogoFileName == "") {
        return;
      }

      final Directory appDocDir = await getApplicationDocumentsDirectory();

      final String imagesDirPath = '${appDocDir.path}/images';

      final Directory imagesDir = Directory(imagesDirPath);

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final String filePath = '$imagesDirPath/$teamLogoFileName';

      final File file = File(filePath);

      if (await file.exists()) {
        setState(() {
          _teamLogo = file; // Set the profile image
        });
      } else {
        final Uint8List bytes = await ApiService.downlaodTeamLogo(context);

        final Directory appDocDir = await getApplicationDocumentsDirectory();

        final String imagesDirPath = '${appDocDir.path}/images';

        final Directory imagesDir = Directory(imagesDirPath);

        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }

        final String filePath = '$imagesDirPath/$teamLogoFileName';

        final File file = File(filePath);

        await file.writeAsBytes(bytes);

        setState(() {
          _teamLogo = file; // Set the profile image
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString('imageFilename', teamLogoFileName);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile picture: $e')),
      );
    }
  }

  Future<void> _uploadImage(context) async {
    if (_teamLogo != null) {
      File image = await compressImage(_teamLogo!);

      try {
        final response = await ApiService.uploadTeamLogo(
            selectedContestId, teamId, image, context);

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
        _teamLogo = File(pickedFile.path);
      });

      bool? confirm = await _showConfirmationDialog(context);

      if (confirm == true) {
        _uploadImage(context);
      } else {
        // If the user cancels, you can clear the selected image if needed

        setState(() {
          _teamLogo = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Team")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /*Text("Select Contest",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: selectedContestId,
              decoration: InputDecoration(border: OutlineInputBorder()),
              hint: Text("Choose a contest"),
              items: contests.map((contest) {
                if (contest['name'].toString() == 'No_Contest') {
                  return DropdownMenuItem(
                    value: contest['contest_id'].toString(),
                    child: Text('Single Match'),
                  );
                } else {
                  return DropdownMenuItem(
                    value: contest['contest_id'].toString(),
                    child: Text(contest['name']),
                  );
                }
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedContestId = value;
                });
              },
            ),
            SizedBox(height: 16), */
            Expanded(
              flex: 2, // Adjust the flex value to decrease its width
              child: Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 45, // Reduced size of the avatar
                      backgroundImage:
                          _teamLogo != null ? FileImage(_teamLogo!) : null,
                      child: _teamLogo == null
                          ? Text(
                              'T',
                              style: const TextStyle(
                                  fontSize: 30), // Adjusted font size
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => BottomSheet(
                              onClosing: () {},
                              builder: (context) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.camera),
                                    title: const Text('Take a picture'),
                                    onTap: () {
                                      _pickImage(ImageSource.camera);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo_album),
                                    title: const Text('Choose from gallery'),
                                    onTap: () {
                                      _pickImage(ImageSource.gallery);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: const CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.edit,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10), // Adjust spacing between sections

            TextField(
              decoration: InputDecoration(
                labelText: "Team Name",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  teamName = value;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: "City",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  city = value;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  phoneNumber = value;
                });
              },
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  createTeam();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: Text("Submit"),
                ),
              ),
            ),
            SizedBox(height: 200),
          ],
        ),
      ),
    );
  }
}
