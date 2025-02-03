import 'package:b2winai/scoreBoard/scoreBoardView/modal/runBeforeOut.dart';
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
  final int team1Id;
  final int team2Id;
  final String team1Name;
  final String team2Name;
  final int bowlerId;
  final int inningsId;
  final String bowlerIdName, batsman1Name, batsman2Name;

  const ChooseNewBatsman({
    Key? key,
    required this.overNumber,
    required this.ballNumber,
    required this.strikerid,
    required this.nonStrikerId,
    required this.contestId,
    required this.matchId,
    required this.team1Id,
    required this.team2Id,
    required this.team1Name,
    required this.team2Name,
    required this.bowlerId,
    required this.bowlerIdName,
    required this.batsman1Name,
    required this.batsman2Name,
    required this.inningsId,
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

  @override
  void initState() {
    super.initState();
    getMatchBallingPlayers(widget.contestId, widget.matchId, widget.team1Id);
  }

  Future<void> getMatchBallingPlayers(
      int contestId, int matchId, int teamId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getMatchPlayers(context, contestId, matchId, teamId);
      if (response['statuscode'] == 200) {
        List<dynamic> dataResponse = response['data']['playing_xi'];
        setState(() {
          battingPlayerList = dataResponse;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching players: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Choose New Batsman",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildPlayerSelection(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScoreBoardPage(
                            contestId: widget.contestId,
                            team1Id: widget.team1Id,
                            matchId: widget.matchId,
                            team2Id: widget.team1Id,
                            team1Name: widget.team1Name,
                            team2Name: widget.team2Name,
                            batsMan1: selectedPlayerId!,
                            batsMan2: widget.nonStrikerId,
                            bowlerId: widget.bowlerId,
                            bowlerIdName: widget.bowlerIdName,
                            batsman1Name: selectedNewBatsmanName!,
                            batsman2Name: widget.batsman2Name,
                            inningsId: widget.inningsId,
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
    );
  }

  /// Builds a grid of player selection cards
  Widget _buildPlayerSelection() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
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
