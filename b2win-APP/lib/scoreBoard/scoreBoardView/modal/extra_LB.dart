import 'package:b2winai/scoreBoard/scoreBoardView/scoreBoardView.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class ExtrasModalLB extends StatefulWidget {
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
  final String batsman1Name;
  final String batsman2Name;
  final int inningsId;
  const ExtrasModalLB({
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
  _ExtrasModalLBState createState() => _ExtrasModalLBState();
}

class _ExtrasModalLBState extends State<ExtrasModalLB> {
  bool isLoading = false;
  int striker_Id = 0;
  int nonStriker_Id = 0;
  int selectedRun = 0;

  @override
  void initState() {
    super.initState();
    striker_Id = widget.strikerid;
    nonStriker_Id = widget.nonStrikerId;
  }

  Future<void> updateScore() async {
    try {
      autoFlipBatsman(selectedRun);
      final response = await ApiService.updateScore(
          widget.contestId,
          widget.matchId,
          widget.team1Id,
          widget.inningsId,
          widget.bowlerId,
          'LB',
          widget.overNumber,
          widget.ballNumber,
          widget.strikerid,
          widget.nonStrikerId,
          selectedRun,
          "",
          0,
          0);
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
              batsMan1: striker_Id,
              batsMan2: nonStriker_Id,
              bowlerId: widget.bowlerId,
              bowlerIdName: widget.bowlerIdName,
              batsman1Name: widget.batsman1Name,
              batsman2Name: widget.batsman2Name,
              inningsId: widget.inningsId,
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
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Extras - LB",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(7, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRun = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selectedRun == index
                              ? Colors.blue
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "$index",
                            style: TextStyle(
                              fontSize: 16,
                              color: selectedRun == index
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: updateScore,
                    child: const Text("Next"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
