import 'package:b2winai/login/profile.dart';
import 'package:b2winai/scoreBoard/players/createPlayer.dart';
import 'package:b2winai/scoreBoard/players/uploadAllPlayers.dart';
import 'package:b2winai/scoreBoard/teams/addPlayers.dart';
import 'package:b2winai/scoreBoard/teams/addPlayersPage.dart';
import 'package:b2winai/scoreBoard/teams/createTeam.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class TeamsListPage extends StatefulWidget {
  @override
  _TeamListPageState createState() => _TeamListPageState();
}

class _TeamListPageState extends State<TeamsListPage> {
  @override
  void initState() {
    super.initState();
    contestId = 2;
    getTeams(context, 2);
  }

  int contestId = 0;
  // Sample team data
  List<Map<String, dynamic>> teams = [];
  Future<void> getTeams(BuildContext context, int contestId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getTeams(context, contestId);
      if (response['statuscode'] == 200) {
        List<dynamic> data = response['data'];

        List<Map<String, dynamic>> dataResponse =
            List<Map<String, dynamic>>.from(data);
        setState(() {
          teams = dataResponse;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 103, 178, 207),
        title: Text(
          "Teams",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune), // Filter Icon
            onPressed: () {
              // Handle filter action
            },
          ),
          IconButton(
            icon: Icon(Icons.add), // Add Icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewTeamPage()),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(
                team["name"].substring(0, 1).toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              team["name"],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('5 Players'), //Text("${team["players"]} Players"),
            trailing: IconButton(
              icon: Icon(Icons.more_vert), // Menu Icon
              onPressed: () {
                _showTeamOptions(context, team);
              },
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider(thickness: 1, color: Colors.grey.shade300);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Set this to the current tab index
        onTap: (index) {
          if (index == 0) {
            /* Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ScoreBoardPage()),
              );*/
          } else if (index == 1) {
            /*  showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => FieldingPositionModal(),
              );*/
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UploadAllPlayersPage()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          }
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
        selectedItemColor: Colors.blue, // Active icon color
        unselectedItemColor: Colors.grey, // Inactive icon color
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // Function to show modal bottom sheet
  void _showTeamOptions(BuildContext context, Map<String, dynamic> team) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Adjust height to fit content
            children: [
              Text(
                "${team["name"]}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.person_add, color: Colors.blue),
                title: Text("Add Player"),
                onTap: () {
                  Navigator.pop(context); // Close the modal
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddPlayersPage(
                                teamId: team["id"],
                                teamName: team["name"],
                                contestId: contestId,
                              )));
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.orange),
                title: Text("Edit Team"),
                onTap: () {
                  Navigator.pop(context); // Close the modal
                  _editTeam(context, team);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to handle "Add Player" action
  void _addPlayer(BuildContext context, Map<String, dynamic> team) {
    // Implement add player logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Add Player for ${team["name"]}")),
    );
  }

  // Function to handle "Edit Team" action
  void _editTeam(BuildContext context, Map<String, dynamic> team) {
    // Implement edit team logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Edit Team: ${team["name"]}")),
    );
  }
}
