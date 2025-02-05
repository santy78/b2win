import 'package:b2winai/scoreBoard/players/createPlayer.dart';
import 'package:b2winai/scoreBoard/teams/addPlayers.dart';
import 'package:b2winai/scoreBoard/teams/createTeam.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class AddPlayersPage extends StatefulWidget {
  final int contestId, teamId;

  final String teamName;
  const AddPlayersPage(
      {super.key,
      required this.contestId,
      required this.teamId,
      required this.teamName});
  @override
  _AddPlayersPageState createState() => _AddPlayersPageState();
}

class _AddPlayersPageState extends State<AddPlayersPage> {
  int? selectedContestId;
  String teamName = "";
  int? teamId;
  List<Map<String, dynamic>> contests = [];
  List<Map<String, dynamic>> players = [];
  List<Map<String, dynamic>> TeamPlayers = [];
  List<Map<String, dynamic>> selectedPlayers = [];

  @override
  void initState() {
    super.initState();
    selectedContestId = widget.contestId;
    teamName = widget.teamName;
    teamId = widget.teamId;
    getAllPlayers();
    getPlayerByTeams(widget.contestId, widget.teamId);
  }

  int contestId = 0;
  // Sample team data

  Future<void> getAllPlayers() async {
    try {
      Map<String, dynamic> response = await ApiService.getAllPlayers(context);
      if (response['statuscode'] == 200) {
        setState(() {
          players = List<Map<String, dynamic>>.from(response['data']);
        });
      }
    } catch (e) {
      _showSnackbar("Error fetching players: $e");
    }
  }

  Future<void> getPlayerByTeams(int contestId, int teamId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getPlayersByTeamby(context, contestId, teamId);
      if (response['statuscode'] == 200) {
        setState(() {
          TeamPlayers = List<Map<String, dynamic>>.from(response['data']);
        });
      }
    } catch (e) {
      _showSnackbar("Error fetching players: $e");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _openPlayerSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              height: 400,
              child: Column(
                children: [
                  Text("Select Players",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> player = players[index];

                        // Check if the player is already selected
                        bool isSelected = selectedPlayers
                            .any((p) => p['playerId'] == player['id']);

                        return CheckboxListTile(
                          title: Text(player['fullname']),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value == true) {
                                // Add player with the required structure
                                selectedPlayers.add({
                                  "name": player['fullname'],
                                  "position": player['player_role'],
                                  "playerId": player['id'],
                                  "flag": "I"
                                });
                              } else {
                                // Remove player based on ID
                                selectedPlayers.removeWhere(
                                    (p) => p['playerId'] == player['id']);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      addTeamSquardPlayers();
                    },
                    child: Text("Done"),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> addTeamSquardPlayers() async {
    try {
      final response = await ApiService.addTeamSquardPlayer(
          widget.contestId, widget.teamId, selectedPlayers, context);
      if (response['statuscode'] == 200) {
        _showSnackbar(response['message']);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddPlayersPage(
                    contestId: widget.contestId,
                    teamId: widget.teamId,
                    teamName: widget.teamName)));
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
        backgroundColor: Color.fromARGB(255, 103, 178, 207),
        title: Text(
          "Players",
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
            onPressed: _openPlayerSelectionModal,
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: TeamPlayers.length,
        itemBuilder: (context, index) {
          final team = TeamPlayers[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(
                team["player_name"].substring(0, 1).toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              team["player_name"],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            //subtitle: Text('5 Players'), //Text("${team["players"]} Players"),
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
          // Handle bottom navigation tap
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
                          builder: (context) => AddPlayers(
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
