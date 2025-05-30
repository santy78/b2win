import 'package:b2winai/constant.dart';
import 'package:b2winai/scoreBoard/matches/createMatchPage.dart';
import 'package:b2winai/scoreBoard/players/createPlayer.dart';
import 'package:b2winai/scoreBoard/teams/addPlayers.dart';
import 'package:b2winai/scoreBoard/teams/createTeam.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data_provider.dart';

class AddPlayersPage extends StatefulWidget {
  final int teamId;
  final String teamName;
  final bool isFromCreateMatchPage;
  final bool isTeamA;

  const AddPlayersPage(
      {super.key,
      required this.teamId,
      required this.teamName,
      required this.isFromCreateMatchPage,
      required this.isTeamA});
  @override
  _AddPlayersPageState createState() => _AddPlayersPageState();
}

class _AddPlayersPageState extends State<AddPlayersPage> {
  String teamName = "";
  int? teamId;
  bool isFromCreateMatchPage = false;
  List<Map<String, dynamic>> contests = [];
  List<Map<String, dynamic>> players = [];
  List<Map<String, dynamic>> teamPlayers = [];
  List<Map<String, dynamic>> selectedPlayers = [];
  bool isChecked = false;
  Set<int> noOfSelectedPlayers = {}; // Store selected player indices
  bool isFabEnabled = false;

  @override
  void initState() {
    super.initState();
    teamName = widget.teamName;
    teamId = widget.teamId;
    isFromCreateMatchPage = widget.isFromCreateMatchPage;
    //getAllPlayers();
    getPlayerByTeams(widget.teamId);
  }

  // Future<void> getAllPlayers() async {
  //   try {
  //     Map<String, dynamic> response = await ApiService.getAllPlayers(context);
  //     if (response['statuscode'] == 200) {
  //       setState(() {
  //         players = List<Map<String, dynamic>>.from(response['data']);
  //       });
  //     }
  //   } catch (e) {
  //     _showSnackbar("Error fetching players: $e");
  //   }
  // }

  Future<void> getPlayerByTeams(int teamId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getPlayersByTeamby(context, teamId);
      if (response['statuscode'] == 200) {
        setState(() {
          teamPlayers = List<Map<String, dynamic>>.from(response['data']);
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

  // void _openPlayerSelectionModal() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setModalState) {
  //           return Container(
  //             padding: EdgeInsets.all(16),
  //             height: 400,
  //             child: Column(
  //               children: [
  //                 Text("Select Players",
  //                     style:
  //                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //                 Expanded(
  //                   child: ListView.builder(
  //                     itemCount: players.length,
  //                     itemBuilder: (context, index) {
  //                       Map<String, dynamic> player = players[index];

  //                       // Check if the player is already selected
  //                       bool isSelected = selectedPlayers
  //                           .any((p) => p['playerId'] == player['id']);

  //                       return CheckboxListTile(
  //                         title: Text(player['fullname']),
  //                         value: isSelected,
  //                         onChanged: (bool? value) {
  //                           setModalState(() {
  //                             if (value == true) {
  //                               // Add player with the required structure
  //                               selectedPlayers.add({
  //                                 "name": player['fullname'],
  //                                 "position": player['player_role'],
  //                                 "playerId": player['id'],
  //                                 "flag": "I"
  //                               });
  //                             } else {
  //                               // Remove player based on ID
  //                               selectedPlayers.removeWhere(
  //                                   (p) => p['playerId'] == player['id']);
  //                             }
  //                           });
  //                         },
  //                       );
  //                     },
  //                   ),
  //                 ),
  //                 ElevatedButton(
  //                   onPressed: () {
  //                     addTeamSquardPlayers();
  //                   },
  //                   child: Text("Done"),
  //                 )
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Future<void> addTeamSquardPlayers() async {
    try {
      final response = await ApiService.addTeamSquardPlayer(
          widget.teamId, selectedPlayers, context);
      if (response['statuscode'] == 200) {
        _showSnackbar(response['message']);
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => AddPlayersPage(
        //               teamId: widget.teamId,
        //               teamName: widget.teamName,

        //               isFromCreateMatchPage: false,
        //             )));
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
        //backgroundColor: Color.fromARGB(255, 103, 178, 207),
        title: Text(
          "Players",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.tune), // Filter Icon
          //   onPressed: () {
          //     // Handle filter action
          //   },
          // ),
          IconButton(
            icon: Icon(Icons.add), // Add Icon
            onPressed:
                //_openPlayerSelectionModal,
                navigateToAddPlayers,
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: teamPlayers.length,
        itemBuilder: (context, index) {
          final player = teamPlayers[index];
          bool isSelected = noOfSelectedPlayers.contains(index);
          IconData icon;

          // **Nested if-else for icon selection**
          if (isFromCreateMatchPage) {
            if (isSelected) {
              icon = Icons.check_box;
            } else {
              icon = Icons.check_box_outline_blank;
            }
          } else {
            icon = Icons.more_vert;
          }
          return ListTile(
            leading: CircleAvatar(
              child: Text(
                player["player_name"].substring(0, 1).toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              player["player_name"],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            //subtitle: Text('5 Players'), //Text("${team["players"]} Players"),
            trailing: IconButton(
              icon: Icon(icon),
              onPressed: () {
                if (isFromCreateMatchPage) {
                  toggleSelection(index, player);
                } else {
                  _showTeamOptions(context, player);
                }
              },
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider(thickness: 1, color: Colors.grey.shade300);
        },
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10), // Adjust space below FAB
        child: isFromCreateMatchPage
            ? FloatingActionButton(
                onPressed: isFabEnabled
                    ? () => onSaveButtonClicked()
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) =>
                    //             NewTeamPage(isEditMode: false, teamId: 0)));
                    : null,
                child: Icon(Icons.save_rounded,
                    size: 30,
                    color: isFabEnabled ? Colors.white : Colors.black54),
                backgroundColor:
                    isFabEnabled ? Colors.lightBlueAccent : Colors.grey,
                shape: CircleBorder(),
              )
            : null,
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Bottom-right

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

  void toggleSelection(int index, Map<String, dynamic> player) {
    setState(() {
      if (noOfSelectedPlayers.contains(index)) {
        // Remove player from selected lists
        noOfSelectedPlayers.remove(index);
        selectedPlayers
            .removeWhere((p) => p["player_id"] == player["player_id"]);
      } else if (noOfSelectedPlayers.length < 11) {
        // Add player to selected lists
        noOfSelectedPlayers.add(index);
        selectedPlayers.add({
          "team_squad_id": player['team_squad_id'],
          "player_id": player['player_id'],
          "player_name": player['player_name'],
          "player_match_role":
              player['team_role'] == null ? "" : player['team_role'],
        });
      }

      // Enable save button when 11 players are selected
      isFabEnabled = noOfSelectedPlayers.length == 11;
      // if (isFabEnabled) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("11 players selected!")),
      //   );
      // }
    });
  }

  void onSaveButtonClicked() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Playing 11 selected for Team $teamName")),
    );

    if (widget.isTeamA) {
      Provider.of<DataProvider>(context, listen: false).updateValue(teamName);
      Provider.of<DataProvider>(context, listen: false)
          .updateList(selectedPlayers);
      Future.delayed(Duration(seconds: 3), () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MatchCreatePage(
                    teamAName: teamName,
                    teamBName: "Team B",
                    teamAList: selectedPlayers,
                    teamBList: [],
                  )),
        );
      });
    } else {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MatchCreatePage(
                    teamAName: "Team A",
                    teamBName: teamName,
                    teamAList: [],
                    teamBList: selectedPlayers,
                  )),
        );
      });
    }
  }

  void navigateToAddPlayers() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AddPlayers(teamId: widget.teamId, teamName: widget.teamName)));
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
                "${team["player_name"]}",
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
                              )));
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.orange),
                title: Text("Edit Player"),
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
