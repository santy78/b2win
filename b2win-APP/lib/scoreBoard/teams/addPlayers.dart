import 'package:b2winai/constant.dart';
import 'package:b2winai/scoreBoard/teams/teamList.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class AddPlayers extends StatefulWidget {
  final int teamId;

  final String teamName;
  const AddPlayers({super.key, required this.teamId, required this.teamName});
  @override
  _AddPlayersState createState() => _AddPlayersState();
}

class _AddPlayersState extends State<AddPlayers> {
  int selectedContestId = 0;
  String teamName = "";
  int? teamId;
  List<Map<String, dynamic>> contests = [];
  List<Map<String, dynamic>> players = [];
  List<Map<String, dynamic>> TeamPlayers = [];
  List<Map<String, dynamic>> selectedPlayers = [];
  List<String> phoneNumbers = [
    "9876543210",
    "9123456789",
    "8899776655",
    "9888776655",
    "7001122334"
  ];
  List<String> filteredNumbers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedContestId = ApiConstants.defaultContestId;
    teamName = widget.teamName;
    teamId = widget.teamId;
    getAllPlayers();
    getPlayerByTeams(selectedContestId, widget.teamId);
    filteredNumbers = List.from(phoneNumbers); // Initialize with all numbers
  }

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
                  Text("Add Players",
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
                    onPressed: () => Navigator.pop(context),
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
          selectedContestId, widget.teamId, selectedPlayers, context);
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
    // return Scaffold(
    //   appBar: AppBar(title: Text(teamName)),
    //   body: Padding(
    //     padding: const EdgeInsets.all(16.0),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         ElevatedButton(
    //           onPressed: _openPlayerSelectionModal,
    //           child: Text("Add Players"),
    //         ),
    //         SizedBox(height: 24),
    //         Center(
    //           child: ElevatedButton(
    //             onPressed: () {
    //               addTeamSquardPlayers();
    //             }, //createTeam,
    //             child: Text("Add"),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    return Scaffold(
      appBar: AppBar(title: Text(teamName)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  labelText: "Search Phone Number",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search)),
              onChanged: filterNumbers, // Call filter function on text change
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredNumbers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.phone),
                    title: Text(filteredNumbers[index]),
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  //addTeamSquardPlayers();
                }, //playing 11,
                child: Text("Add"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void filterNumbers(String query) {
    setState(() {
      filteredNumbers =
          phoneNumbers.where((number) => number.contains(query)).toList();
    });
  }
}
