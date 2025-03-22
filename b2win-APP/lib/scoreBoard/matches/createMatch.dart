import 'dart:io';

import 'package:b2winai/scoreBoard/matches/matchList.dart';
import 'package:b2winai/scoreBoard/teams/teamList.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class NewMatchPage extends StatefulWidget {
  @override
  _NewMatchPageState createState() => _NewMatchPageState();
}

class _NewMatchPageState extends State<NewMatchPage> {
  @override
  void initState() {
    super.initState();
    getContests(context);
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

  Future<void> createMatchByFile(String contestId, BuildContext context) async {
    if (_file != null) {
      try {
        final response =
            await ApiService.createMatchByFile(contestId, _file, context);

        if (response['statuscode'] == 200) {
          final snackBar = SnackBar(
            content: Text(response['message']),
            duration: const Duration(seconds: 2),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          Future.delayed(snackBar.duration, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MatchListPage()));
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
          "Create Match",
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
            ElevatedButton.icon(
              onPressed: _pickFile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                textStyle: const TextStyle(
                  fontSize: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              icon: const Icon(Icons.file_upload),
              label: Text('Upload Document'),
            ),
            SizedBox(height: 8),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  createMatchByFile(selectedContestId.toString(), context);
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
