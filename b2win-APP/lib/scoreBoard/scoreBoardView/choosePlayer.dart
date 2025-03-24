import 'package:b2winai/scoreBoard/scoreBoardView/scoreBoardView.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class ChoosePlayersPage extends StatefulWidget {
  final int contestId;
  final int matchId;
  final int team1Id;
  final int team2Id;
  final String team1Name;
  final String team2Name;

  const ChoosePlayersPage({
    Key? key,
    required this.contestId,
    required this.matchId,
    required this.team1Id,
    required this.team2Id,
    required this.team1Name,
    required this.team2Name,
  }) : super(key: key);

  @override
  State<ChoosePlayersPage> createState() => _ChoosePlayersPageState();
}

class _ChoosePlayersPageState extends State<ChoosePlayersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? selectedBatsman1Id, selectedBatsman2Id, selectedBowlerId;
  String? selectedBatsman1Name, selectedBatsman2Name, selectedBowlerName;
  List<dynamic> battingPlayerList = [];
  List<dynamic> ballingPlayerList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getMatchBattingPlayers(widget.contestId, widget.matchId, widget.team1Id);
    getMatchBallingPlayers(widget.contestId, widget.matchId, widget.team2Id);
  }

  Future<void> getMatchBattingPlayers(
      int contestId, int matchId, int teamId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getMatchPlayers(context, contestId, matchId, teamId);
      if (response['statuscode'] == 200) {
        setState(() {
          battingPlayerList = response['data']['playing_xi'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> getMatchBallingPlayers(
      int contestId, int matchId, int teamId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getMatchPlayers(context, contestId, matchId, teamId);
      if (response['statuscode'] == 200) {
        setState(() {
          ballingPlayerList = response['data']['playing_xi'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2, // Two Tabs
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Choose Players'),
            bottom: TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.purple,
              controller: _tabController,
              tabs: const [
                Tab(text: 'Batting'),
                Tab(text: 'Bowling'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildBattingSelection(),
              _buildBowlingSelection(),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: (selectedBatsman1Id != null &&
                      selectedBatsman2Id != null &&
                      selectedBowlerId != null)
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScoreBoardPage(
                            contestId: widget.contestId,
                            matchId: widget.matchId,
                            team1Id: widget.team1Id,
                            team2Id: widget.team2Id,
                            team1Name: widget.team1Name,
                            team2Name: widget.team2Name,
                            batsMan1: selectedBatsman1Id!,
                            batsMan2: selectedBatsman2Id!,
                            bowlerId: selectedBowlerId!,
                            bowlerIdName: selectedBowlerName!,
                            batsman1Name: selectedBatsman1Name!,
                            batsman2Name: selectedBatsman2Name!,
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text('Next'),
            ),
          ),
        ));
  }

  // Widget _buildBattingSelection() {
  //   return ListView.builder(
  //     padding: const EdgeInsets.all(16),
  //     itemCount: battingPlayerList.length,
  //     itemBuilder: (context, index) {
  //       final player = battingPlayerList[index];
  //       return _buildPlayerTile(
  //         name: player['player_name'],
  //         selected: selectedBatsman1Id == player['player_id'] ||
  //             selectedBatsman2Id == player['player_id'],
  //         onTap: () =>
  //             _selectBatsman(player['player_id'], player['player_name']),
  //       );
  //     },
  //   );
  // }

  Widget _buildBattingSelection() {
    // Use a Set to remove duplicates based on player_id
    final uniquePlayers = {
      for (var player in battingPlayerList) player['player_id']: player
    }.values.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: uniquePlayers.length,
      itemBuilder: (context, index) {
        final player = uniquePlayers[index];
        return _buildPlayerTile(
          name: player['player_name'],
          selected: selectedBatsman1Id == player['player_id'] ||
              selectedBatsman2Id == player['player_id'],
          onTap: () =>
              _selectBatsman(player['player_id'], player['player_name']),
        );
      },
    );
  }

  // Widget _buildBowlingSelection() {
  //   return ListView.builder(
  //     padding: const EdgeInsets.all(16),
  //     itemCount: ballingPlayerList.length,
  //     itemBuilder: (context, index) {
  //       final player = ballingPlayerList[index];
  //       return _buildPlayerTile(
  //         name: player['player_name'],
  //         selected: selectedBowlerId == player['player_id'],
  //         onTap: () => setState(() {
  //           selectedBowlerId = player['player_id'];
  //           selectedBowlerName = player['player_name'];
  //         }),
  //       );
  //     },
  //   );
  // }

  Widget _buildBowlingSelection() {
    // Remove duplicates based on player_id
    final uniquePlayers = {
      for (var player in ballingPlayerList) player['player_id']: player
    }.values.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: uniquePlayers.length,
      itemBuilder: (context, index) {
        final player = uniquePlayers[index];
        return _buildPlayerTile(
          name: player['player_name'],
          selected: selectedBowlerId == player['player_id'],
          onTap: () => setState(() {
            selectedBowlerId = player['player_id'];
            selectedBowlerName = player['player_name'];
          }),
        );
      },
    );
  }

  void _selectBatsman(int batsmanId, String batsmanName) {
    setState(() {
      if (selectedBatsman1Id == null) {
        selectedBatsman1Id = batsmanId;
        selectedBatsman1Name = batsmanName;
      } else if (selectedBatsman2Id == null &&
          selectedBatsman1Id != batsmanId) {
        selectedBatsman2Id = batsmanId;
        selectedBatsman2Name = batsmanName;
      } else if (selectedBatsman1Id == batsmanId) {
        selectedBatsman1Id = null;
        selectedBatsman1Name = null;
      } else if (selectedBatsman2Id == batsmanId) {
        selectedBatsman2Id = null;
        selectedBatsman2Name = null;
      }
    });
  }

  Widget _buildPlayerTile(
      {required String name,
      required bool selected,
      required VoidCallback onTap}) {
    return ListTile(
      title: Text(name),
      tileColor: selected ? Colors.blue.withOpacity(0.2) : null,
      trailing: selected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: onTap,
    );
  }
}
