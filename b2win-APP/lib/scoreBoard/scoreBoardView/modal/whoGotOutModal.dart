import 'package:b2winai/scoreBoard/scoreBoardView/modal/choseFielder.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/scoreBoardView.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class WhoGotOutModal extends StatefulWidget {
  //final List<Map<String, dynamic>> players;
  //final Function(String) onPlayerSelected;
  final String outType;
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

  final String bowlerIdName, batsman1Name, batsman2Name;

  const WhoGotOutModal({
    Key? key,
    //required this.players,
    //required this.onPlayerSelected,
    required this.outType,
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
  }) : super(key: key);

  @override
  _WhoGotOutModalState createState() => _WhoGotOutModalState();
}

class _WhoGotOutModalState extends State<WhoGotOutModal> {
  Map<String, dynamic>? strikerPlayer;
  Map<String, dynamic>? nonStrikerPlayer;
  bool isLoading = false;
  int? selectedPlayerId;
  int? wicketTaketId;
  @override
  void initState() {
    super.initState();
    fetchPlayerDetails();
  }

  Future<void> fetchPlayerDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final strikerResponse =
          await ApiService.getPlayerInfo(context, widget.strikerid);
      final nonStrikerResponse =
          await ApiService.getPlayerInfo(context, widget.nonStrikerId);

      setState(() {
        strikerPlayer = strikerResponse['data'];
        nonStrikerPlayer = nonStrikerResponse['data'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load players: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateScore() async {
    try {
      //autoFlipBatsman(selectedRun);

      final response = await ApiService.updateScore(
          widget.contestId,
          widget.matchId,
          widget.team1Id,
          widget.bowlerId,
          'OUT',
          widget.overNumber,
          widget.ballNumber,
          widget.strikerid,
          widget.nonStrikerId,
          0,
          widget.outType,
          selectedPlayerId!,
          wicketTaketId!);

      if (response['statuscode'] == 200) {
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
              batsMan1: widget.strikerid,
              batsMan2: widget.nonStrikerId,
              bowlerId: widget.bowlerId,
              bowlerIdName: widget.bowlerIdName,
              batsman1Name: widget.batsman1Name,
              batsman2Name: widget.batsman2Name,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send score: $e')),
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
                    "Who got out",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (strikerPlayer != null)
                        Expanded(child: _buildPlayerCard(strikerPlayer!)),
                      const SizedBox(width: 10),
                      if (nonStrikerPlayer != null)
                        Expanded(child: _buildPlayerCard(nonStrikerPlayer!)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.outType == 'runOut' ||
                          widget.outType == 'obstructingField') {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          builder: (context) {
                            return ChooseFilder(
                              overNumber: widget.overNumber,
                              ballNumber: widget.ballNumber,
                              strikerid: widget.strikerid,
                              nonStrikerId: widget.nonStrikerId,
                              team1Id: widget.team1Id,
                              team2Id: widget.team2Id,
                              team1Name: widget.team1Name,
                              team2Name: widget.team2Name,
                              bowlerId: widget.bowlerId,
                              bowlerIdName: widget.bowlerIdName,
                              contestId: widget.contestId,
                              matchId: widget.matchId,
                              batsman1Name: widget.batsman1Name,
                              batsman2Name: widget.batsman2Name,
                              outType: widget.outType,
                              OutPlayerId: selectedPlayerId!,
                            );
                          },
                        );
                      } else {
                        updateScore();
                      }
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

  Widget _buildPlayerCard(Map<String, dynamic> player) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlayerId = player['id'];
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selectedPlayerId == player['id']
              ? Colors.blue.shade100
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selectedPlayerId == player['id']
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
                player['fullname'][0].toUpperCase(),
                style: TextStyle(
                  color: selectedPlayerId == player['id']
                      ? Colors.blue
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              player['fullname'],
              style: TextStyle(
                color: selectedPlayerId == player['id']
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
