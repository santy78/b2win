import 'package:flutter/material.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/scoreBoardView.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/viewMode/viewModeScreen.dart';

class MatchActionPage extends StatefulWidget {
  final int contestId;
  final int matchId;
  final int team1Id;
  final int team2Id;
  final String team1Name;
  final String team2Name;
  final bool isGuest;

  const MatchActionPage({
    Key? key,
    required this.contestId,
    required this.matchId,
    required this.team1Id,
    required this.team2Id,
    required this.team1Name,
    required this.team2Name,
    this.isGuest = true,
  }) : super(key: key);

  @override
  _MatchActionPageState createState() => _MatchActionPageState();
}

class _MatchActionPageState extends State<MatchActionPage> {
  late int _matchId;

  @override
  void initState() {
    super.initState();
    _matchId = widget.matchId;

    // If user is guest, redirect directly to view mode
    if (widget.isGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ViewModeScreen(
              contestId: widget.contestId,
              matchId: _matchId,
              isGuest: widget.isGuest,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container while redirecting for guests
    if (widget.isGuest) {
      return Container();
    }

    // Normal view for non-guests
    return Scaffold(
      appBar: AppBar(
        title: Text('Match Options'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Match Info Card
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '${widget.team1Name} vs ${widget.team2Name}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Match ID: $_matchId',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40),

            // Action Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  // Scorer Mode Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScoreBoardPage(
                              contestId: widget.contestId,
                              matchId: _matchId,
                              team1Id: widget.team1Id,
                              team2Id: widget.team2Id,
                              team1Name: widget.team1Name,
                              team2Name: widget.team2Name,
                              batsMan1: 0,
                              batsMan2: 0,
                              bowlerId: 0,
                              bowlerIdName: "",
                              batsman1Name: "",
                              batsman2Name: "",
                              inningsId: 0,
                              lastBallId: 0,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Enter Scorer Mode',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Viewer Mode Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewModeScreen(
                              contestId: widget.contestId,
                              matchId: _matchId,
                              isGuest: widget.isGuest,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'View Scoreboard',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
