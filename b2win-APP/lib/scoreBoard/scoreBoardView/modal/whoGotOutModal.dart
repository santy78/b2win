import 'package:b2winai/scoreBoard/scoreBoardView/scoreBoardView.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class WhoGotOutModal extends StatefulWidget {
  final List<Map<String, dynamic>> players;
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

  final String bowlerIdName;
  const WhoGotOutModal({
    Key? key,
    required this.players,
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
  }) : super(key: key);

  @override
  _WhoGotOutModalState createState() => _WhoGotOutModalState();
}

class _WhoGotOutModalState extends State<WhoGotOutModal> {
  String? selectedPlayer; // To store the selected player's name
  bool isLoading = false;

  Future<void> updateScore(
      contestId,
      matchId,
      teamId,
      bowlerId,
      String runType,
      int overNumber,
      int ballNumber,
      int strikerId,
      int nonStrikerId,
      int extraRun,
      String outType) async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      final response = await ApiService.updateScore(
          contestId,
          matchId,
          teamId,
          bowlerId,
          runType,
          overNumber,
          ballNumber,
          strikerId,
          nonStrikerId,
          extraRun,
          outType);
      if (response['statuscode'] == 200) {
        /* Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ScoreBoardPage()),
        );*/
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send code: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            const Text(
              "Who got out",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Player List as Buttons
            GridView.builder(
              shrinkWrap: true,
              itemCount: widget.players.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.5, // Adjust to match button proportions
              ),
              itemBuilder: (context, index) {
                final player = widget.players[index];
                final isSelected = selectedPlayer == player;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPlayer =
                          player['player_name']; // Update selected player
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            child: Text(
                              player['player_name'].toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.blue : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            player['player_name'],
                            style: TextStyle(
                              color: isSelected ? Colors.blue : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Next Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedPlayer == null
                    ? null // Disable button if no player is selected
                    : () {
                        Navigator.pop(context);
                        updateScore(
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
                            widget.outType);
                      },
                // widget.onPlayerSelected(selectedPlayer!);

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedPlayer == null ? Colors.grey : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Next"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
