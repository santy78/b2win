import 'package:b2winai/constant.dart';
import 'package:b2winai/scoreBoard/teams/playerForm.dart';
import 'package:b2winai/scoreBoard/teams/teamList.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddPlayers extends StatefulWidget {
  final int teamId;

  final String teamName;
  const AddPlayers({super.key, required this.teamId, required this.teamName});
  @override
  _AddPlayersState createState() => _AddPlayersState();
}

class Player {
  final String name;
  final String position;
  final String phone;

  Player({required this.name, required this.position, required this.phone});

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['fullname'],
      position: json['player_role'],
      phone: json['phone'],
    );
  }
}

class _AddPlayersState extends State<AddPlayers> {
  int selectedContestId = 0;
  String teamName = "";
  int teamId = 0;
  // List<Map<String, dynamic>> contests = [];
  // List<Map<String, dynamic>> players = [];
  // List<Map<String, dynamic>> TeamPlayers = [];
  // List<Map<String, dynamic>> searchedPlayers = [];
  List<String> teamPlayers = [];
  List<String> searchedPlayer = [];
  String searchedNumber = "";

  final TextEditingController searchController = TextEditingController();
  List<Player> players = [];
  Player? selectedPlayer;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedContestId = 0;
    teamName = widget.teamName;
    teamId = widget.teamId;
    // getAllPlayers();
    // getPlayerByTeams(selectedContestId, widget.teamId);
    //getPlayerByPhone();
    fetchPlayers();
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

  // Future<void> getPlayerByTeams(int contestId, int teamId) async {
  //   try {
  //     Map<String, dynamic> response =
  //         await ApiService.getPlayersByTeamby(context, contestId, teamId);
  //     if (response['statuscode'] == 200) {
  //       setState(() {
  //         phoneNumbers = List<String>.from(response['data']);
  //       });
  //     }
  //   } catch (e) {
  //     _showSnackbar("Error fetching players: $e");
  //   }
  // }

  Future<void> fetchPlayers() async {
    setState(() => isLoading = true);

    try {
      Map<String, dynamic> response =
          await ApiService.getPlayerByPhone(searchedNumber, context);

      if (response['statuscode'] == 200) {
        List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(response['data']);

        setState(() {
          players = data
              .map((item) => Player.fromJson(item as Map<String, dynamic>))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showSnackbar(
            "Error fetching players: ${response?['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackbar("Error fetching players: $e");
    }
  }

  // Future<void> getPlayerByPhone() async {
  //   try {
  //     Map<String, dynamic> response =
  //         await ApiService.getPlayerByPhone(searchedNumber, context);
  //     if (response['statuscode'] == 200) {
  //       setState(() {
  //         teamPlayers = List<String>.from(response['data']);
  //       });
  //       print(response['message']);
  //     }
  //   } catch (e) {
  //     _showSnackbar("Error fetching players: $e");
  //   }
  // }

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
  //                 Text("Add Players",
  //                     style:
  //                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //                 Expanded(
  //                   child: ListView.builder(
  //                     itemCount: players.length,
  //                     itemBuilder: (context, index) {
  //                       Map<String, dynamic> player = players[index];

  //                       // Check if the player is already selected
  //                       bool isSelected = searchedPlayers
  //                           .any((p) => p['playerId'] == player['id']);

  //                       return CheckboxListTile(
  //                         title: Text(player['fullname']),
  //                         value: isSelected,
  //                         onChanged: (bool? value) {
  //                           setModalState(() {
  //                             if (value == true) {
  //                               // Add player with the required structure
  //                               searchedPlayers.add({
  //                                 "name": player['fullname'],
  //                                 "position": player['player_role'],
  //                                 "playerId": player['id'],
  //                                 "flag": "I"
  //                               });
  //                             } else {
  //                               // Remove player based on ID
  //                               searchedPlayers.removeWhere(
  //                                   (p) => p['playerId'] == player['id']);
  //                             }
  //                           });
  //                         },
  //                       );
  //                     },
  //                   ),
  //                 ),
  //                 ElevatedButton(
  //                   onPressed: () => Navigator.pop(context),
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
          widget.teamId, searchedPlayer, context);
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

  // @override
  // Widget build(BuildContext context) {
  //   // return Scaffold(
  //   //   appBar: AppBar(title: Text(teamName)),
  //   //   body: Padding(
  //   //     padding: const EdgeInsets.all(16.0),
  //   //     child: Column(
  //   //       crossAxisAlignment: CrossAxisAlignment.start,
  //   //       children: [
  //   //         ElevatedButton(
  //   //           onPressed: _openPlayerSelectionModal,
  //   //           child: Text("Add Players"),
  //   //         ),
  //   //         SizedBox(height: 24),
  //   //         Center(
  //   //           child: ElevatedButton(
  //   //             onPressed: () {
  //   //               addTeamSquardPlayers();
  //   //             }, //createTeam,
  //   //             child: Text("Add"),
  //   //           ),
  //   //         ),
  //   //       ],
  //   //     ),
  //   //   ),
  //   // );
  //   return Scaffold(
  //     appBar: AppBar(title: Text(teamName)),
  //     body: Padding(
  //       padding: EdgeInsets.all(16.0),
  //       child: Column(
  //         children: [
  //           TextField(
  //             controller: searchController,
  //             keyboardType: TextInputType.phone,
  //             decoration: InputDecoration(
  //               labelText: "Search Phone Number",
  //               border: OutlineInputBorder(),
  //               prefixIcon: Icon(Icons.search),
  //             ),
  //             onChanged: filterNumbers, // Call filter function on text change
  //           ),
  //           SizedBox(height: 20),
  //           Expanded(
  //             child: searchedPlayer.isEmpty
  //                 ? Center(
  //                     child: Text("No results found")) // Show only when empty
  //                 : ListView.builder(
  //                     itemCount: searchedPlayer.length,
  //                     itemBuilder: (context, index) {
  //                       return ListTile(
  //                         leading: CircleAvatar(
  //                           child: Text(
  //                             "Player Name",
  //                             //searchedPlayer[].toUpperCase(),
  //                             style: TextStyle(fontWeight: FontWeight.bold),
  //                           ),
  //                         ),
  //                         title: Text(
  //                           "player name",
  //                           style: TextStyle(fontWeight: FontWeight.bold),
  //                         ),
  //                         subtitle: Text("Ph number"),
  //                       );
  //                     },
  //                   ),
  //           ),
  //           Center(
  //             child: ElevatedButton(
  //               onPressed: () {
  //                 //addTeamSquardPlayers();
  //               }, //playing 11,
  //               child: Text("Add"),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void onSearchChanged(String value) {
    setState(() {
      selectedPlayer = players.firstWhere((player) => player.phone == value,
          orElse: () => Player(name: '', position: '', phone: ''));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: searchController,
              decoration:
                  const InputDecoration(labelText: 'Search Phone Number'),
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 16),
            if (selectedPlayer != null && selectedPlayer!.name.isNotEmpty)
              Card(
                child: ListTile(
                  title: Text(selectedPlayer!.name),
                  subtitle: Text(selectedPlayer!.position),
                ),
              )
            else if (searchController.text.isNotEmpty &&
                selectedPlayer!.name.isEmpty)
              PlayerForm(phoneNumber: searchController.text, teamId: teamId),
            const SizedBox(height: 16),
            Center(
              child: Visibility(
                visible: (selectedPlayer != null &&
                    selectedPlayer!.name
                        .isNotEmpty), // Button is shown only if list is not empty
                child: ElevatedButton(
                  onPressed: () {
                    addTeamSquardPlayers();
                  }, //add player to team
                  child: const Text("Add"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void filterNumbers(String query) {
    if (query.isEmpty) {
      setState(() {
        searchedPlayer.clear(); // Keep list empty if no input
      });
    } else {
      setState(() {
        searchedPlayer =
            teamPlayers.where((number) => number.contains(query)).toList();
      });
    }
  }
}
