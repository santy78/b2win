import 'package:b2winai/scoreBoard/teams/teamList.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class NewTeamPage extends StatefulWidget {
  @override
  _NewTeamPageState createState() => _NewTeamPageState();
}

class _NewTeamPageState extends State<NewTeamPage> {
  String? selectedContestId;
  String teamName = "";
  String city = "";
  List<Map<String, dynamic>> contests = [];
  List<Map<String, dynamic>> players = [];
  List<Map<String, dynamic>> selectedPlayers = [];

  @override
  void initState() {
    super.initState();
    createNoContests();
    getContests();
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
      Map<String, dynamic> response = await ApiService.createNoContest(context);
      if (response['statuscode'] == 200) {
        setState(() {
          contests = List<Map<String, dynamic>>.from(response['data']);
        });
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
    if (selectedContestId == null || teamName.isEmpty || city.isEmpty) {
      _showSnackbar("Please complete all fields");
      return;
    }

    try {
      final response = await ApiService.createTeams(
          selectedContestId!, teamName, city, context);
      if (response['statuscode'] == 200) {
        _showSnackbar(response['message']);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => TeamsListPage()));
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
      appBar: AppBar(title: Text("Create Team")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Contest",
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
            SizedBox(height: 16),
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
            SizedBox(height: 16),
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
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: createTeam,
                child: Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
