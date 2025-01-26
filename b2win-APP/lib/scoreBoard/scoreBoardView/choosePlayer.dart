import 'package:b2winai/scoreBoard/scoreBoardView/scoreBoardView.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class ChoosePlayersPage extends StatefulWidget {
  final int contestId;
  final int matchId;
  final int tossWinnerTeamId;
  final String tossWinnerTeamName;
  final int tossLossTeamId;
  final String tossLossTeamName;
  final String tossWinnerChoice;

  const ChoosePlayersPage({
    Key? key,
    required this.contestId,
    required this.matchId,
    required this.tossWinnerTeamId,
    required this.tossWinnerChoice,
    required this.tossWinnerTeamName,
    required this.tossLossTeamId,
    required this.tossLossTeamName,
  }) : super(key: key);

  @override
  State<ChoosePlayersPage> createState() => _ChoosePlayersPageState();
}

class _ChoosePlayersPageState extends State<ChoosePlayersPage> {
  int? selectedBatsman1Id;
  int? selectedBatsman2Id;
  int? selectedBowlerId;
  String? selectedBatsman1Name;
  String? selectedBatsman2Name;
  String? selectedBowlerName;

  List<dynamic> battingPlayerList = [];
  List<dynamic> ballingPlayerList = [];

  @override
  void initState() {
    super.initState();
    getMatchBattingPlayers(
      context,
      widget.contestId,
      widget.matchId,
      widget.tossWinnerTeamId,
    );
    getMatchBallingPlayers(
      context,
      widget.contestId,
      widget.matchId,
      widget.tossLossTeamId,
    );
  }

  Future<void> getMatchBattingPlayers(
      BuildContext context, int contestId, int matchId, int teamId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getMatchPlayers(context, contestId, matchId, teamId);
      if (response['statuscode'] == 200) {
        Map<String, dynamic> data = response['data'];

        List<dynamic> dataResponse = data['playing_xi'];
        setState(() {
          battingPlayerList = dataResponse;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> getMatchBallingPlayers(
      BuildContext context, int contestId, int matchId, int teamId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getMatchPlayers(context, contestId, matchId, teamId);
      if (response['statuscode'] == 200) {
        Map<String, dynamic> data = response['data'];

        List<dynamic> dataResponse = data['playing_xi'];
        setState(() {
          ballingPlayerList = dataResponse;
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
        title: const Text('Choose Players'),
      ),
      body: battingPlayerList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Choose Opening Batsmen',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: battingPlayerList.length,
                              itemBuilder: (context, index) {
                                final player = battingPlayerList[index];
                                return _buildPlayerCard(
                                  name: player['player_name'],
                                  initials: player['player_name'][0],
                                  subtitle: player['player_match_role'],
                                  selected: selectedBatsman1Id ==
                                          player['player_id'] ||
                                      selectedBatsman2Id == player['player_id'],
                                  onTap: () => _selectBatsman(
                                    player['player_id'],
                                    player['player_name'],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Choose Bowler for Over 1',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: ballingPlayerList.length,
                              itemBuilder: (context, index) {
                                final player = ballingPlayerList[index];
                                return _buildPlayerCard(
                                  name: player['player_name'],
                                  initials: player['player_name'][0],
                                  subtitle: player['player_match_role'],
                                  selected:
                                      selectedBowlerId == player['player_id'],
                                  onTap: () => setState(() {
                                    selectedBowlerId = player['player_id'];
                                    selectedBowlerName = player['player_name'];
                                  }),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
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
                                          team1Id: widget.tossWinnerTeamId,
                                          team2Id: widget.tossLossTeamId,
                                          team1Name: widget.tossWinnerTeamName,
                                          team2Name: widget.tossLossTeamName,
                                          batsMan1: selectedBatsman1Id!,
                                          batsMan2: selectedBatsman2Id!,
                                          bowlerId: selectedBowlerId!,
                                          bowlerIdName: selectedBowlerName!,
                                          batsman1Name: selectedBatsman1Name!,
                                          batsman2Name: selectedBatsman2Name!,
                                        )));
                          }
                        : null,
                    child: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _selectBatsman(int batsmanId, String batsmanName) {
    setState(() {
      if (selectedBatsman1Id == batsmanId) {
        selectedBatsman1Id = null;
        selectedBatsman1Name = null;
      } else if (selectedBatsman2Id == batsmanId) {
        selectedBatsman2Id = null;
        selectedBatsman2Name = null;
      } else if (selectedBatsman1Id == null) {
        selectedBatsman1Id = batsmanId;
        selectedBatsman1Name = batsmanName;
      } else if (selectedBatsman2Id == null) {
        selectedBatsman2Id = batsmanId;
        selectedBatsman2Name = batsmanName;
      }
    });
  }

  Widget _buildPlayerCard({
    required String name,
    required String initials,
    String? subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(
              color: selected ? Colors.blue : Colors.grey, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
          color: selected ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: selected ? Colors.blue : Colors.grey[300],
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                color: selected ? Colors.blue : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.blue : Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
