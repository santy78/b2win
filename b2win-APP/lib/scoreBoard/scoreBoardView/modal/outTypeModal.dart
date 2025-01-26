import 'package:b2winai/scoreBoard/scoreBoardView/modal/whoGotOutModal.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/scoreBoardView.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class OutTypesModal extends StatefulWidget {
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
  OutTypesModal({
    super.key,
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
  });

  @override
  _OutTypesModalState createState() => _OutTypesModalState();
}

class _OutTypesModalState extends State<OutTypesModal> {
  bool isLoading = false;
  String? selectedDismissalType; // To store the selected dismissal type
  final stickers = [
    {
      "contest_id": 2,
      "match_id": 23,
      "innings_id": 3,
      "player_id": 92,
      "player_name": "SOURAV PAUL(RONO)",
      "runs_scored": 7,
      "balls_faced": 2,
      "strike_rate": 350,
      "fours": 1,
      "sixes": 0,
      "dismissal": null,
      "fifties": false,
      "hundreds": false,
      "ducks": false
    },
    {
      "contest_id": 2,
      "match_id": 23,
      "innings_id": 3,
      "player_id": 93,
      "player_name": "SRIKANT NANDI",
      "runs_scored": 40,
      "balls_faced": 15,
      "strike_rate": 266.67,
      "fours": 5,
      "sixes": 3,
      "dismissal": null,
      "fifties": false,
      "hundreds": false,
      "ducks": false
    }
  ];
  final List<String> dismissalTypes = [
    "Bowled",
    "Caught",
    "Caught Behind",
    "Caught And Bowled",
    "Leg Before Wicket",
    "Stumped",
    "Run Out",
    "Hit Wicket",
    "Hit Ball Twice",
    "Handled Ball",
    "Obstructing the Field",
    "Timed Out",
    "Retired",
    "Retired Hurt",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
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
            "Dismissal Types",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Dismissal Types List
          Wrap(
            spacing: 8, // Horizontal space between items
            runSpacing: 8, // Vertical space between lines
            children: dismissalTypes
                .map(
                  (type) => ChoiceChip(
                    label: Text(type),
                    selected: selectedDismissalType == type,
                    onSelected: (isSelected) {
                      setState(() {
                        selectedDismissalType =
                            isSelected ? type : null; // Update selected type
                      });
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: Colors.blue.shade100,
                    labelStyle: TextStyle(
                      color: selectedDismissalType == type
                          ? Colors.blue
                          : Colors.black,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          // Okay Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (selectedDismissalType == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select a dismissal type."),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
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
                    return WhoGotOutModal(
                        players: stickers,
                        // onPlayerSelected: (String) {},
                        outType: selectedDismissalType.toString(),
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
                        matchId: widget.matchId);
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Okay"),
            ),
          ),
        ],
      ),
    );
  }
}
