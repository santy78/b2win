import 'dart:io';

import 'package:b2winai/scoreBoard/teams/teamList.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AddPlayersPages extends StatefulWidget {
  final int teamId;
  final String teamName;
  const AddPlayersPages(
      {super.key, required this.teamId, required this.teamName});
  @override
  _AddPlayersageState createState() => _AddPlayersageState();
}

class _AddPlayersageState extends State<AddPlayersPages> {
  @override
  void initState() {
    super.initState();
    //getContests(context);
  }

  String? selectedContestId;
  List<Map<String, dynamic>> contests = [];
  String? uploadedFilePath;
  File? _file;
  Future<void> getContests(BuildContext context) async {
    try {
      Map<String, dynamic> response = await ApiService.getContest(context);
      if (response['statuscode'] == 200) {
        List<dynamic> data = response['data'];

        List<Map<String, dynamic>> dataResponse =
            List<Map<String, dynamic>>.from(data);
        setState(() {
          contests = dataResponse;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> addPlayerToTeam(
      BuildContext context, int contestId, int teamId) async {
    if (_file != null) {
      try {
        final response = await ApiService.addPlayersToTeam(
            _file, contestId, teamId, context);

        if (response['statuscode'] == 200) {
          final snackBar = SnackBar(
            content: Text(response['message']),
            duration: const Duration(seconds: 2),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          Future.delayed(snackBar.duration, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => TeamsListPage()));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Player to " + widget.teamName,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 103, 178, 207),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Contest Dropdown
            Text(
              "Select Contest",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedContestId,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              hint: Text("Choose a contest"),
              items: contests.map((contest) {
                return DropdownMenuItem(
                  value: contest['contest_id'].toString(),
                  child: Text("${contest['name']}"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedContestId = value;
                });
              },
            ),
            SizedBox(height: 16),

            // Upload CSV File Field
            Text(
              "Upload CSV File",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      uploadedFilePath != null
                          ? uploadedFilePath!.split('/').last
                          : "No file selected",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Icon(
                      Icons.upload_file,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  addPlayerToTeam(context,
                      int.parse(selectedContestId.toString()), widget.teamId);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Color.fromARGB(255, 103, 178, 207),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Submit",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to pick a file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _file = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No file selected")),
      );
    }
  }

  // Function to handle form submission
  void _submitForm() {
    if (selectedContestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a contest")),
      );
      return;
    }

    if (uploadedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload a CSV file")),
      );
      return;
    }

    // Process the submission
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Form submitted successfully!")),
    );

    // Reset the form after submission
    setState(() {
      selectedContestId = null;
      uploadedFilePath = null;
    });
  }
}
