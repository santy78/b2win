import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class AddContestPage extends StatefulWidget {
  @override
  _AddContestPageState createState() => _AddContestPageState();
}

class _AddContestPageState extends State<AddContestPage> {
  String name = "";
  String title = "";
  String game_type = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> createContest(
      String name, String title, String game_type) async {
    if (name.isEmpty || title.isEmpty || game_type.isEmpty) {
      _showSnackbar("Please complete all fields");
      return;
    }

    try {
      final response =
          await ApiService.createTeams(name!, title, game_type, context);
      if (response['statuscode'] == 200) {
        _showSnackbar(response['message']);
        //Navigator.push(
        //  context, MaterialPageRoute(builder: (context) => ContestListPage()));
      } else {
        _showSnackbar(response['message']);
      }
    } catch (e) {
      _showSnackbar("Error creating team: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Contest",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 103, 178, 207),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Contest Name
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Contest Name",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            //Title
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  title = value;
                });
              },
            ),
            //Game Type
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Game Type",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  game_type = value;
                });
              },
            ),
            //Start time
            //End Time
            //Info
            // Submit Button
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20), // Adjust height for top margin
                  ElevatedButton(
                    onPressed: () {
                      createContest(name, title, game_type);
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: Color.fromARGB(255, 103, 178, 207),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Submit",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
