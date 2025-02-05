import 'package:b2winai/scoreBoard/teams/teamList.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class AddPlayers extends StatefulWidget {
  final int contestId, teamId;

  final String teamName;
  const AddPlayers(
      {super.key,
      required this.contestId,
      required this.teamId,
      required this.teamName});
  @override
  _AddPlayersPageState createState() => _AddPlayersPageState();
}

class _AddPlayersPageState extends State<AddPlayers> {
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
          widget.contestId, widget.teamId, selectedPlayers, context);
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
      appBar: AppBar(title: Text(teamName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _openPlayerSelectionModal,
              child: Text("Add Players"),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  addTeamSquardPlayers();
                }, //createTeam,
                child: Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
