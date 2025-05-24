import 'package:b2winai/scoreBoard/scoreBoardView/modal/runAfterOut.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/scoreBoardView.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class ChooseNewBatsman extends StatefulWidget {
  final int overNumber;
  final int ballNumber;
  final int strikerid;
  final int nonStrikerId;
  final int contestId;
  final int matchId;
  final int? team1Id;
  final int? team2Id;
  final String? team1Name;
  final String? team2Name;
  final int? bowlerId;
  final int inningsId;
  final int lastBallId;
  final String? bowlerIdName, batsman1Name, batsman2Name;

  const ChooseNewBatsman({
    Key? key,
    required this.overNumber,
    required this.ballNumber,
    required this.strikerid,
    required this.nonStrikerId,
    required this.contestId,
    required this.matchId,
    this.team1Id,
    this.team2Id,
    this.team1Name,
    this.team2Name,
    this.bowlerId,
    this.bowlerIdName,
    this.batsman1Name,
    this.batsman2Name,
    required this.inningsId,
    required this.lastBallId,
  }) : super(key: key);

  @override
  _ChooseNewBatsmanModalState createState() => _ChooseNewBatsmanModalState();
}

class _ChooseNewBatsmanModalState extends State<ChooseNewBatsman> {
  bool isLoading = false;
  int? selectedPlayerId;
  String? selectedNewBatsmanName;
  int? wicketTaketId;

  List<dynamic> battingPlayerList = [];
  bool _hasLoadedPlayers = false;

  @override
  void initState() {
    super.initState();
    getMatchBattingPlayers(widget.contestId, widget.matchId, widget.team1Id!);
  }

  Future<void> getMatchBattingPlayers(
      int contestId, int matchId, int teamId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getMatchPlayers(context, matchId, teamId);
      if (response['statuscode'] == 200) {
        List<dynamic> dataResponse = response['data'];

        // Deduplicate based on player_id
        final seen = <int>{};
        final uniquePlayers = dataResponse.where((player) {
          final id = player['player_id'];
          return id != widget.strikerid &&
              id != widget.nonStrikerId &&
              seen.add(id); // ensure unique
        }).toList();

        setState(() {
          battingPlayerList = uniquePlayers;
        });
        print('API players: ${dataResponse.map((e) => e['player_name'])}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching players: $e')),
      );
    }
  }

  Future<void> setNewBatsman(
      BuildContext context, int inningsId, int batsmanId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.setNewBatsman(context, inningsId, batsmanId);
      if (response['statuscode'] == 200) {
        if (response['data'] != null) {
          Map<String, dynamic> data = response['data'];

          setState(() {
            //what to do..
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching extras: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Choose New Batsman",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              child: _buildPlayerSelection(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              //call setNewBatsman
                              setNewBatsman(
                                  context, widget.inningsId, selectedPlayerId!);
                              //Navigator.of(context, rootNavigator: true).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScoreBoardPage(
                                    contestId: widget.contestId,
                                    matchId: widget.matchId!,
                                    team1Id: widget.team1Id!,
                                    team2Id: widget.team1Id!,
                                    team1Name: widget.team1Name!,
                                    team2Name: widget.team2Name!,
                                    batsMan1: selectedPlayerId!,
                                    batsMan2: widget.nonStrikerId,
                                    bowlerId: widget.bowlerId!,
                                    bowlerIdName: widget.bowlerIdName!,
                                    batsman1Name: selectedNewBatsmanName!,
                                    batsman2Name: widget.batsman2Name!,
                                    inningsId: widget.inningsId,
                                    lastBallId: widget.lastBallId,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Next",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
              ),
            )));
  }

  /// Builds a grid of player selection cards
  Widget _buildPlayerSelection() {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: battingPlayerList.map((player) {
        return _buildPlayerCard(player);
      }).toList(),
    );
  }

  /// Builds a selectable player card
  Widget _buildPlayerCard(Map<String, dynamic> player) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlayerId = player['player_id'];
          selectedNewBatsmanName = player['player_name'];
        });
      },
      child: Container(
        width: 100, // Fixed width for uniform layout
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selectedPlayerId == player['player_id']
              ? Colors.blue.shade100
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selectedPlayerId == player['player_id']
                ? Colors.blue
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: Text(
                player['player_name'][0].toUpperCase(),
                style: TextStyle(
                  color: selectedPlayerId == player['player_id']
                      ? Colors.blue
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              player['player_name'],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selectedPlayerId == player['player_id']
                    ? Colors.blue
                    : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
