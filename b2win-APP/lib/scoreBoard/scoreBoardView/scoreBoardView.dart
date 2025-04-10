import 'dart:math';

import 'package:b2winai/scoreBoard/dashboard.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/choosePlayer.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/fieldingPositions.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/modal/choseNewBatsman.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/tossDetails.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class ScoreBoardPage extends StatefulWidget {
  final int contestId;
  final int matchId;
  final int? team1Id;
  final int? team2Id;

  final String? team1Name;
  final String? team2Name;
  final int? batsMan1;
  final int? batsMan2;
  final int? bowlerId;
  final int? inningsId;
  final String? batsman1Name;
  final String? batsman2Name;
  final String? bowlerIdName;

  const ScoreBoardPage({
    Key? key,
    required this.contestId,
    required this.matchId,
    required this.team1Id,
    required this.team2Id,
    required this.team1Name,
    required this.team2Name,
    required this.batsMan1,
    required this.batsMan2,
    required this.bowlerId,
    required this.bowlerIdName,
    required this.batsman1Name,
    required this.batsman2Name,
    this.inningsId,
  }) : super(key: key);

  @override
  State<ScoreBoardPage> createState() => _ScoreBoardPageState();
}

class _ScoreBoardPageState extends State<ScoreBoardPage> {
  String selectedRun = "6"; // Tracks the selected bowling score button
  Map<String, dynamic> firstInnings = {};
  Map<String, dynamic> secondInnings = {};
  List<dynamic> firstInningsbatting = [];
  List<dynamic> firstInningsBowling = [];
  List<dynamic> secondInningsbatting = [];
  List<dynamic> secondInningsBowling = [];
  int? inningsNo;
  int? inningsId;
  //int? teamId;
  int strikerId = 0;
  int nonStrikerId = 0;
  int batsman1Score = 0;
  int batsMan1BallsFaced = 0;
  int bowler_Id = 0;
  int? overNumber;
  int? ballNumber;
  int? firstInningsScore;
  int? firstInningWiketLoss;
  String targetRunText = "";
  TextEditingController overNumberController = TextEditingController();
  // final bowlerList = ["John Doe", "Jane Smith", "Alex Brown"];
  TextEditingController runController = TextEditingController();
  List<dynamic> bowlerList = [];
  int teamId1 = 0;
  int teamId2 = 0;
  String teamName1 = "";
  String teamName2 = "";
  List<dynamic> ballingScoreList = [];
  int batsman2Score = 0;
  int batsMan2BallsFaced = 0;
  String batsman1Name = "";
  String batsman2Name = "";
  String bowler_Name = "";
  String? selectedBowler;
  int? selectedBowlerId;

  String _tossDecision = "";
  int _firstInningsTeamId = 0;
  String _firstInningsTeamName = "";
  int _secondInningsTeamId = 0;
  String _secondInningsTeamName = "";
  int _tossLossTeamId = 0;
  int _firstInningsId = 0;
  int _secondInningsId = 0;
  int _overPerInnings = 0;
  String _firstInningsStatus = "";
  String _secondInningsStatus = "";
  @override
  void initState() {
    super.initState();
    setState(() {
      strikerId = widget.batsMan1!;
      nonStrikerId = widget.batsMan2!;
      bowler_Id = widget.bowlerId!;
      bowler_Name = widget.bowlerIdName!;
      batsman1Name = widget.batsman1Name!;
      batsman2Name = widget.batsman2Name!;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call the modal and score-fetching methods here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //openTossModal(); // Show toss modal after the widget tree is ready.
      getTossDetails(context, widget.contestId, widget.matchId);

      getScoreBoard(context, widget.contestId, widget.matchId);
      /* getBatsmanScore(
          context, widget.contestId, widget.matchId, 1, widget.batsMan1);
      getBatsmanScore(
        context,
        widget.contestId,
        widget.matchId,
        1,
        widget.batsMan2,
      );*/
      //getBallingScore(context, widget.contestId, widget.matchId, 1, 1, 1);
    });
  }

  Future<void> getTossDetails(
      BuildContext context, int contestId, int matchId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getTossDetails(context, contestId, matchId);

      if (response['status'] == 'success' && response['data'] != null) {
        List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(response['data']);

        String tossDecision = "";
        int firstInningsTeamId = -1;
        String firstInningsTeamName = "";
        int secondInningsTeamId = -1;
        String secondInningsTeamName = "";
        int tossLossTeamId = -1;
        int firstInningsId = -1;
        int secondInningsId = -1;
        int overPerInnings = 0;
        String firstInningsStatus = "";
        String secondInningsStatus = "";

        for (var inning in data) {
          if (inning['inning_number'] == 1) {
            tossDecision = inning['toss_decision'] ?? "";
            firstInningsTeamName = inning['team_name'] ?? "";
            firstInningsStatus = inning["innings_status"];
            firstInningsTeamId = inning['team_id'] ?? -1;
            firstInningsId = inning['id'] ?? -1;
            overPerInnings = inning['over_per_innings'] ?? 0;
          } else if (inning['inning_number'] == 2) {
            secondInningsTeamName = inning['team_name'] ?? "";
            secondInningsTeamId = inning['team_id'] ?? -1;
            secondInningsStatus = inning["innings_status"];
            tossLossTeamId = inning['team_id'] ?? -1;
            secondInningsId = inning['id'] ?? -1;
          }
        }

        setState(() {
          // Update UI state with extracted toss details
          _tossDecision = tossDecision;
          _firstInningsTeamName = firstInningsTeamName;
          _secondInningsTeamName = secondInningsTeamName;
          _firstInningsStatus = firstInningsStatus;
          _secondInningsStatus = secondInningsStatus;
          _firstInningsTeamId = firstInningsTeamId;
          _secondInningsTeamId = secondInningsTeamId;
          _tossLossTeamId = tossLossTeamId;
          _firstInningsId = firstInningsId;
          _secondInningsId = secondInningsId;
          _overPerInnings = overPerInnings;
        });
        getScore(context, widget.contestId, widget.matchId);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TossDetailPage(
              contestId: widget.contestId,
              matchId: widget.matchId,
              team1Id: _firstInningsTeamId,
              team2Id: _secondInningsTeamId,
              team1Name: _firstInningsTeamName,
              team2Name: _secondInningsTeamName,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> getMatchBallingPlayers(BuildContext context, int contestId,
      int matchId, int teamId, overNumber) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getMatchPlayers(context, contestId, matchId, teamId);

      if (response['statuscode'] == 200) {
        Map<String, dynamic> data = response['data'];

        List<dynamic> dataResponse = data['playing_xi'];

        setState(() {
          bowlerList = dataResponse;
        });

        showAddBowlerModal(context, overNumber);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> Undo(BuildContext context, int contestId, int matchId,
      int teamId, int inningsId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.undo(contestId, matchId, teamId, inningsId);

      if (response['statuscode'] == 200) {
        // Reload the current page by replacing it with a new instance
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ScoreBoardPage(
              contestId: contestId,
              matchId: matchId,
              team1Id: teamId, // Ensure you pass correct teamId
              team2Id: teamId, // Adjust if needed
              team1Name: widget.team1Name, // Replace with actual team name
              team2Name: widget.batsman2Name, // Replace with actual team name
              batsMan1: strikerId, // Adjust values as needed
              batsMan2: nonStrikerId,
              bowlerId: bowler_Id,
              bowlerIdName: bowler_Name,
              batsman1Name: batsman1Name,
              batsman2Name: batsman2Name,
              inningsId: inningsId,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> changeBowler(
      BuildContext context, int contestId, int matchId, int teamId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getMatchPlayers(context, contestId, matchId, teamId);

      if (response['statuscode'] == 200) {
        Map<String, dynamic> data = response['data'];

        List<dynamic> dataResponse = data['playing_xi'];

        setState(() {
          bowlerList = dataResponse;
        });

        showChangeBowlerModal(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> getBallingScore(
    BuildContext context,
    int contestId,
    int matchId,
    int inningNo,
    int startOver,
    int endOver,
  ) async {
    try {
      // Call the API and get the response
      Map<String, dynamic> response = await ApiService.getBallingScore(
        context,
        contestId,
        matchId,
        inningNo,
        startOver,
        endOver,
      );

      if (response['statuscode'] == 200) {
        // Extract the data from the API response
        Map<String, dynamic> data = response['data'];

        // Overs is a map with overs as keys, so we need to iterate through it
        Map<String, dynamic> overs = data['overs'];

        // Flatten the overs data into a single list
        List<Map<String, dynamic>> ballingScoreList = [];
        overs.forEach((overNumber, balls) {
          // Add each ball in the over to the list
          for (var ball in balls) {
            ballingScoreList.add(ball);
          }
        });

        // Update the state with the new balling score list
        setState(() {
          this.ballingScoreList = ballingScoreList;
        });
        if (ballingScoreList.isNotEmpty) {
          Map<String, dynamic> lastBall = ballingScoreList.last;
          int batsman_id = lastBall['batsman_id'] ?? 0;
          int non_striker_id = lastBall['non_striker_id'] ?? 0;
          int bowler_id = lastBall['bowler_id'] ?? 0;
          String bowler = lastBall['bowler'] ?? "";
          int runsScored = lastBall['runs_scored'] ?? 0;
          int extraRuns = lastBall['extra_runs'] ?? 0;
          int ball_number = lastBall['ball_number'] ?? 0;

          autoFlipBatsman(runsScored, extraRuns, batsman_id, non_striker_id,
              bowler_id, bowler, ball_number);
          //debugPrint("Last Ball - Runs Scored: $runsScored, Extra Runs: $extraRuns");
        }
        // Show the modal
        //showAddBowlerModal(context);
      } else {
        throw Exception(
            'Failed to load balling score. Status: ${response['statuscode']}');
      }
    } catch (e) {
      // Handle errors and show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> autoFlipBatsman(int runsScored, int extraRuns, batsman_Id,
      int nonStricker_id, int bowlerid, String bowler, int ballNumber) async {
    final totalRuns = runsScored + extraRuns;
    if (totalRuns % 2 != 0) {
      setState(() {
        final temp = batsman_Id;
        strikerId = nonStricker_id;
        nonStrikerId = temp;
        bowler_Id = bowlerid;
        bowler_Name = bowler;
      });
    } else {
      setState(() {
        strikerId = batsman_Id;
        nonStrikerId = nonStricker_id;
        bowler_Id = bowlerid;
        bowler_Name = bowler;
      });
    }
    if (ballNumber % 6 == 0) {
      setState(() {
        final temp = strikerId;
        strikerId = nonStrikerId;
        nonStrikerId = temp;
        bowler_Id = bowlerid;
        bowler_Name = bowler;
      });
    }

    getBothBatsmanScores(strikerId, nonStrikerId);
    // getBatsmanScore(
    //     context, widget.contestId, widget.matchId, inningsNo!, strikerId);
    // getBatsmanScore(
    //     context, widget.contestId, widget.matchId, inningsNo!, nonStrikerId);
  }

  void getBothBatsmanScores(int strikerId, int nonStrikerId) {
    getBatsmanScore(
        context, widget.contestId, widget.matchId, inningsNo!, strikerId);
    getBatsmanScore(
        context, widget.contestId, widget.matchId, inningsNo!, nonStrikerId);
  }

  /*void switchInnings(firstInningsStatus, secondInningsStatus, overPerNumber) {
    int total_ball = (overNumber! * 6) + ballNumber!;
    int overPerNumber_ballCount = (overPerNumber * 6);
    if ((secondInningsStatus == 'yetToStart' &&
            total_ball == overPerNumber_ballCount) ||
        secondInningsStatus == 'running') {
      setState(() {
        inningsNo = 2;
        inningsId = _secondInningsId;
        teamId = _secondInningsTeamId;
        targetRunText = "Need $firstInningsScore in ${overPerNumber * 6}";
      });
    } else {
      setState(() {
        inningsNo = 1;
        inningsId = _firstInningsId;
        teamId = _firstInningsTeamId;
      });
    }
  }*/

  void switchInnings() {
    int total_ball = (overNumber! * 6) + ballNumber!;
    int overPerNumber_ballCount = (_overPerInnings! * 6);

    // Check if first innings has ended and second innings is starting
    if ((_secondInningsStatus == 'yetToStart' &&
            total_ball == overPerNumber_ballCount) ||
        _secondInningsStatus == 'running') {
      setState(() {
        inningsNo = 2;
        inningsId = _secondInningsId;
        teamId1 = _secondInningsTeamId!;
        teamId2 = _firstInningsTeamId!;

        // Swap batting and bowling teams
        /*  int tempTeamId = _firstInningsTeamId!;
        _firstInningsTeamId = _secondInningsTeamId;
        _secondInningsTeamId = tempTeamId;
        String tempName1 = _firstInningsTeamName!;*/

        teamName1 = _secondInningsTeamName!;
        teamName2 = _firstInningsTeamName!;

        // Set target text
        targetRunText =
            "Need $firstInningsScore in ${_overPerInnings! * 6} balls";

        // Reset Batsmen IDs
        /*strikerId = 0;
        nonStrikerId = 0;*/

        // Call method to initialize new batsmen
        if (strikerId == 0 && nonStrikerId == 0) {
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
              return ChoosePlayersPage(
                contestId: widget.contestId,
                matchId: widget.matchId,
                team1Id: teamId1,
                team1Name: teamName1,
                team2Id: teamId2,
                team2Name: teamName2,
              );
            },
          );
        }
      });
    } else {
      // First innings is still ongoing
      setState(() {
        inningsNo = 1;
        inningsId = _firstInningsId;
        teamId1 = _firstInningsTeamId!;
        teamId2 = _secondInningsTeamId!;
        teamName1 = _firstInningsTeamName!;
        teamName2 = _secondInningsTeamName!;
      });
    }
  }

  Future<void> getScoreBoard(
      BuildContext context, int contestId, int matchId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getScoreBoard(context, contestId, matchId);
      if (response['statuscode'] == 200) {
        Map<String, dynamic> data = response['data'];

        Map<String, dynamic> firstInnings = data['first_innings'];
        Map<String, dynamic> secondInnings = data['second_innings'];
        Map<String, dynamic> battingTeam = firstInnings['batting_team'];
        Map<String, dynamic> bowlingTeam = firstInnings['bowling_team'];

        int _teamId1 = battingTeam['team_id'];
        String _teamName1 = battingTeam['name'];
        int _teamId2 = bowlingTeam['team_id'];
        String _teamName2 = bowlingTeam['name'];
        List<dynamic> firstInnings_Batting = firstInnings['batting'];
        List<dynamic> firstInnings_Bowling = firstInnings['bowling'];
        List<dynamic> secondInnings_Batting = secondInnings['batting'];
        List<dynamic> secondInnings_Bowling = secondInnings['bowling'];

        setState(() {
          firstInningsbatting = firstInnings_Batting;
          firstInningsBowling = firstInnings_Bowling;
          secondInningsbatting = secondInnings_Batting;
          secondInningsBowling = secondInnings_Bowling;
          teamId1 = _teamId1;
          teamName1 = _teamName1;
          teamId2 = _teamId2;
          teamName2 = _teamName2;
        });
        if (firstInningsbatting.isEmpty) {
          if (strikerId <= 0 && nonStrikerId <= 0) {
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
                return ChoosePlayersPage(
                  contestId: widget.contestId,
                  matchId: widget.matchId,
                  team1Id: teamId1,
                  team1Name: teamName1,
                  team2Id: teamId2,
                  team2Name: teamName2,
                );
              },
            );
            // chose batsman
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> getBatsmanScore(BuildContext context, int contestId, int matchId,
      int inningsNo, int playerId) async {
    try {
      Map<String, dynamic> response = await ApiService.getBatsmanScore(
        context,
        contestId,
        matchId,
        inningsNo,
        playerId,
      );
      if (response['statuscode'] == 200) {
        Map<String, dynamic> data = response['data'];
        setState(() {
          if (playerId == strikerId) {
            batsman1Score = data['runs_scored'];
            batsMan1BallsFaced = data['balls_faced'];
            batsman1Name = data['player_name'] ?? "";
          } else if (playerId == nonStrikerId) {
            batsman2Score = data['runs_scored'];
            batsMan2BallsFaced = data['balls_faced'];
            batsman2Name = data['player_name'] ?? "";
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> getScore(
      BuildContext context, int contestId, int matchId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getScore(context, contestId, matchId);
      if (response['statuscode'] == 200) {
        if (response['data'] != null) {
          Map<String, dynamic> data = response['data'];

          setState(() {
            firstInnings = data['first_innings'];

            secondInnings = data['second_innings'];

            firstInningsScore = firstInnings["runs_scored"];
            firstInningWiketLoss = firstInnings["wickets_lost"];
            overNumber = firstInnings["over_number"];

            ballNumber = firstInnings["ball_number"];
          });
        } else {
          setState(() {
            firstInningsScore = 0;
            firstInningWiketLoss = 0;
            overNumber = 0;

            ballNumber = 0;
          });
        }

        switchInnings();
        if (ballNumber == 6) {
          getMatchBallingPlayers(context, widget.contestId, widget.matchId,
              _secondInningsTeamId!, overNumber);
        }

        getBallingScore(context, widget.contestId, widget.matchId, inningsNo!,
            overNumber!, overNumber!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    bool exitConfirmed = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Exit"),
          content: const Text(
              "Your progress will be lost. Do you want to continue?"),
          actions: [
            TextButton(
              onPressed: () {
                exitConfirmed = false;
                Navigator.of(context).pop();
              },
              child: const Text("Back"),
            ),
            TextButton(
              onPressed: () {
                exitConfirmed = true;
                //Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardPage()),
                );
              },
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );

    return exitConfirmed;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitConfirmationDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Score Board'),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Add menu actions here
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Team Info Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity, // Makes the card take the full width
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          teamName1, //firstInnings['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$firstInningsScore/$firstInningWiketLoss ($overNumber.$ballNumber)',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (targetRunText != "") ...{
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            targetRunText,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange),
                          ),
                        }
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Batting Players
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              /*    children: firstInningsbatting.map<Widget>((player) {
              return _buildPlayerCard(
                player['player_name'], // Player name
                player['runs_scored'], // Runs scored
                player['balls_faced'], // Balls faced
                player['isOut'], // Whether the player is out
              );
            }).toList(),*/
              children: [
                _buildPlayerCard(batsman1Name!, batsman1Score,
                    batsMan1BallsFaced, strikerId, true),
                _buildPlayerCard(batsman2Name!, batsman2Score,
                    batsMan2BallsFaced, nonStrikerId, false),
              ],
            ),
            const Divider(thickness: 1.0),
            // Bowling Team Info
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                teamName2!,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.sports_soccer,
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    width: 8.0, // Add spacing between the icon and text
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              bowler_Name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(
                                width: 8.0), // Space between name and button
                            GestureDetector(
                              onTap: () {
                                changeBowler(
                                  context,
                                  widget.contestId,
                                  widget.matchId,
                                  teamId2!,
                                );
                              },
                              child: const CircleAvatar(
                                radius: 16, // Adjust size of the button
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20, // Adjust icon size
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height:
                              10.0, // Add spacing between text and row of circles
                        ),
                        SingleChildScrollView(
                          scrollDirection:
                              Axis.horizontal, // Enable horizontal scrolling
                          child: Row(
                            children: ballingScoreList.map((ball) {
                              // Get details for each ball
                              final run = ball['runs_scored'].toString();
                              final isSelected = run ==
                                  selectedRun; // Check if this run is selected

                              // Logic for displaying based on extra_type and other conditions
                              String displayText =
                                  run; // Default to runs scored

                              // Check for player dismissal (wicket)
                              if (ball['player_out_id'] != null) {
                                displayText = 'W'; // Show 'W' for a wicket
                              }
                              // Check for extras and map to short names
                              else if (ball['extra_type'] != '' &&
                                  ball['extra_runs'] != null) {
                                switch (ball['extra_type']) {
                                  case 'wide':
                                    displayText = 'WB'; // Wide Ball
                                    break;
                                  case 'noBall':
                                    displayText = 'NB'; // No Ball
                                    break;
                                  case 'bye':
                                    displayText = 'BYE'; // Bye
                                    break;
                                  case 'legBye':
                                    displayText = 'LB'; // Leg Bye
                                    break;
                                  case 'penaltyRun':
                                    displayText = 'PR'; // Penalty Run
                                    break;
                                  default:
                                    displayText =
                                        'EX'; // Fallback for unknown extras
                                }
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedRun = run; // Update selected run
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Run: $run, Display: $displayText")),
                                      );
                                    });
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: isSelected
                                        ? Colors.blue
                                        : Colors
                                            .grey[200], // Highlight selected
                                    child: Text(
                                      displayText, // Display logic result (Run, W, or Extra Type Short Name)
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Score Buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                padding: const EdgeInsets.all(16.0),
                children: [
                  ...['0', '1', '2', '3', '4', '6', 'OUT', 'UNDO']
                      .map((label) => _buildScoreButton(label))
                      .toList(),
                  ...['WB', 'NB', 'BYE', 'LB']
                      .map((label) => _buildScoreButton(label))
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*Widget _buildPlayerCard(String name, int runs, int balls,int id, bool isStriker) {
    return Column(
      children: [
        Icon(
          isStriker ? Icons.sports_cricket : Icons.person,
          color: isStriker ? Colors.orange : Colors.grey,
        ),
        Text(
          name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isStriker ? Colors.orange : Colors.black,
          ),
        ),
        Text('($runs/$balls)', style: const TextStyle(fontSize: 14)),
      ],
    );
  }*/

  Widget _buildPlayerCard(
      String name, int runs, int balls, int id, bool isStriker) {
    return GestureDetector(
      onTap: () {
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
              overNumber: overNumber!,
              ballNumber: ballNumber!,
              strikerid: strikerId,
              nonStrikerId: nonStrikerId,
              team1Id: widget.team1Id,
              team2Id: widget.team2Id,
              team1Name: widget.team1Name,
              team2Name: widget.team2Name,
              bowlerId: bowler_Id,
              bowlerIdName: bowler_Name,
              contestId: widget.contestId,
              matchId: widget.matchId,
              batsman1Name: "",
              batsman2Name: "",
              inningsId: inningsId!,
            );
          },
        );
      },
      child: Column(
        children: [
          Icon(
            isStriker ? Icons.sports_cricket : Icons.person,
            color: isStriker ? Colors.orange : Colors.grey,
          ),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isStriker ? Colors.orange : Colors.black,
            ),
          ),
          Text('($runs/$balls)', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildScoreButton(String label) {
    final isActionButton = label == 'OUT' || label == 'UNDO';
    return ElevatedButton(
      onPressed: () {
        if (label == 'UNDO') {
          Undo(context, widget.contestId, widget.matchId, teamId1!, inningsId!);
        } else {
          // Add action handling here
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => FieldingPositionModal(
              runs: label,
              overNumber: overNumber!,
              ballNumber: ballNumber!,
              strikerid: strikerId,
              nonStrikerId: nonStrikerId,
              team1Id: teamId1,
              team2Id: teamId2,
              team1Name: _firstInningsTeamName,
              team2Name: _secondInningsTeamName,
              bowlerId: bowler_Id,
              bowlerIdName: bowler_Name,
              contestId: widget.contestId,
              matchId: widget.matchId,
              batsman1Name: batsman1Name,
              batsman2Name: batsman2Name,
              inningsId: inningsId!,
              inningsNo: inningsNo!,
            ),
          );
        }
        // print('$label tapped');
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: isActionButton ? Colors.white : Colors.black,
        backgroundColor: isActionButton
            ? (label == 'OUT' ? Colors.red : Colors.green)
            : Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  void showAddBowlerModal(BuildContext context, int overNo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modal handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Change New Bowler for over ${overNo + 1}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Select Bowler
              // Refactored DropdownButtonFormField
              DropdownButtonFormField<String>(
                value: selectedBowler,
                hint: const Text("Select Bowler"),
                items: bowlerList.map((bowler) {
                  final playerName = bowler['player_name'] as String?;
                  return DropdownMenuItem<String>(
                    value: playerName, // Use player name as the value
                    child: Text(playerName ?? "Unknown"), // Display player name
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBowler = value;

                    // Find the selected bowler's ID
                    final selectedBowlerData = bowlerList.firstWhere(
                      (bowler) => bowler['player_name'] == value,
                      orElse: () => null,
                    );
                    selectedBowlerId = selectedBowlerData?['player_id'];
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // Over Number
              /* TextFormField(
                controller: overNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter Over Number",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),*/
              const SizedBox(height: 24),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedBowlerId != null) {
                      Navigator.pop(context);

                      setState(() {
                        bowler_Id = selectedBowlerId!;
                        bowler_Name = selectedBowler.toString();
                        overNumber = overNumber! + 1;
                        ballNumber = 0;
                        ballingScoreList = [];
                      });
                      // Logic to handle bowler addition can go here
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Please select a bowler and enter over number"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Add Bowler",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void showChangeBowlerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modal handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Change Bowler",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Select Bowler
              // Refactored DropdownButtonFormField
              DropdownButtonFormField<String>(
                value: selectedBowler,
                hint: const Text("Select Bowler"),
                items: bowlerList.map((bowler) {
                  final playerName = bowler['player_name'] as String?;
                  return DropdownMenuItem<String>(
                    value: playerName, // Use player name as the value
                    child: Text(playerName ?? "Unknown"), // Display player name
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBowler = value;

                    // Find the selected bowler's ID
                    final selectedBowlerData = bowlerList.firstWhere(
                      (bowler) => bowler['player_name'] == value,
                      orElse: () => null,
                    );
                    selectedBowlerId = selectedBowlerData?['player_id'];
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // Over Number

              const SizedBox(height: 24),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedBowlerId != null) {
                      Navigator.pop(context);

                      setState(() {
                        bowler_Id = selectedBowlerId!;
                        bowler_Name = selectedBowler.toString();
                      });
                      // Logic to handle bowler addition can go here
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Please select a bowler and enter over number"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Change Bowler",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
