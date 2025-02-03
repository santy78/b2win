import 'package:b2winai/scoreBoard/scoreBoardView/modal/choseFielder.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/modal/choseNewBatsman.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/modal/whoGotOutModal.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/scoreBoardView.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class DismissalType extends StatefulWidget {
  final int overNumber,
      ballNumber,
      strikerid,
      nonStrikerId,
      contestId,
      matchId,
      team1Id,
      team2Id,
      bowlerId;
  final int inningsId;
  final String team1Name, team2Name, bowlerIdName, batsman1Name, batsman2Name;

  const DismissalType({
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
    required this.batsman1Name,
    required this.batsman2Name,
    required this.inningsId,
  });

  @override
  _DismissalTypeState createState() => _DismissalTypeState();
}

class _DismissalTypeState extends State<DismissalType> {
  bool isLoading = false;
  int striker_Id = 0;
  int nonStriker_Id = 0;
  String? selectedDismissalType;

  bool _isDisposed = false; // Track if the widget is disposed

  final List<String> dismissalTypes = [
    "bowled",
    "caught",
    "caughtBehind",
    "caughtAndBowled",
    "lbw",
    "stumped",
    "runOut",
    "hitWicket",
    "hitBallTwice",
    "handledBall",
    "obstructingField",
    "timedOut",
    "retired",
    "retiredHurt",
  ];
  @override
  void initState() {
    super.initState();
    striker_Id = widget.strikerid;
    nonStriker_Id = widget.nonStrikerId;
  }

  @override
  void dispose() {
    _isDisposed = true; // Mark widget as disposed
    super.dispose();
  }

  Future<void> updateScore() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await ApiService.updateScore(
        widget.contestId,
        widget.matchId,
        widget.team1Id,
        widget.inningsId,
        widget.bowlerId,
        'OUT',
        widget.overNumber,
        widget.ballNumber,
        widget.strikerid,
        widget.nonStrikerId,
        0,
        selectedDismissalType!,
        widget.strikerid,
        widget.bowlerId,
      );

      // if (_isDisposed) return; // Stop execution if widget is disposed

      if (response['statuscode'] == 200) {
        Navigator.pop(context);
        // Navigator.of(context, rootNavigator: true).pop();
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
            return ChooseNewBatsman(
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
              inningsId: widget.inningsId,
            );
          },
        );
      } else {
        if (!_isDisposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'])),
          );
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send score: $e')),
        );
      }
    } finally {
      if (!_isDisposed) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> autoFlipBatsman(int run) async {
    if (run % 2 != 0) {
      setState(() {
        final temp = striker_Id;
        striker_Id = nonStriker_Id;
        nonStriker_Id = temp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Material(
        type: MaterialType.transparency,
        child: SingleChildScrollView(
          reverse: true,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                              selectedDismissalType = isSelected
                                  ? type
                                  : null; // Update selected type
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

                      // Navigator.pop(context);
                      if (selectedDismissalType == 'bowled' ||
                          selectedDismissalType == 'lbw' ||
                          selectedDismissalType == 'stumped' ||
                          selectedDismissalType == 'caughtBehind' ||
                          selectedDismissalType == 'caughtAndBowled' ||
                          selectedDismissalType == 'hitWicket' ||
                          selectedDismissalType == 'hitBallTwice' ||
                          selectedDismissalType == 'handledBall') {
                        updateScore();
                      } else if (selectedDismissalType == 'runOut' ||
                          selectedDismissalType == 'retired' ||
                          selectedDismissalType == 'retiredHurt' ||
                          selectedDismissalType == 'obstructingField' ||
                          selectedDismissalType == 'timedOut') {
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
                              // players: stickers,
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
                              matchId: widget.matchId,
                              batsman1Name: widget.batsman1Name,
                              batsman2Name: widget.batsman2Name,
                            );
                          },
                        );
                      } else if (selectedDismissalType == 'caught') {
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
                              outType: selectedDismissalType!,
                              OutPlayerId: widget.strikerid,
                              inningsId: widget.inningsId,
                            );
                          },
                        );
                      }
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
          ),
        ),
      ),
    );
  }
}
