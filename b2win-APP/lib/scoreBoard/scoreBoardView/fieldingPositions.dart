import 'dart:math';
import 'package:b2winai/scoreBoard/scoreBoardView/modal/dismissalType.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/modal/extra_BYE.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/modal/extra_LB.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/modal/extra_NB.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/modal/outTypeModal.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/scoreBoardView.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FieldingPositionModal extends StatefulWidget {
  final String runs;
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
  final String batsman1Name;
  final String batsman2Name;
  final String bowlerIdName;
  const FieldingPositionModal(
      {super.key,
      required this.runs,
      required this.overNumber,
      required this.ballNumber,
      required this.strikerid,
      required this.nonStrikerId,
      required this.team1Id,
      required this.team2Id,
      required this.team1Name,
      required this.team2Name,
      required this.bowlerId,
      required this.bowlerIdName,
      required this.contestId,
      required this.matchId,
      required this.batsman1Name,
      required this.batsman2Name});
  @override
  _FieldingPositionModalState createState() => _FieldingPositionModalState();
}

class _FieldingPositionModalState extends State<FieldingPositionModal> {
  TextEditingController runController = TextEditingController();
  bool showWheelFor1s2s3s = true;
  bool showWheelForDotBalls = true;
  Offset? tappedPosition;
  bool isLoading = false;
  int striker_Id = 0;
  int nonStriker_Id = 0;
  @override
  void initState() {
    super.initState();
    striker_Id = widget.strikerid;
    nonStriker_Id = widget.nonStrikerId;
  }

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
  Future<void> updateScore(
      contestId,
      matchId,
      teamId,
      bowlerId,
      runsType,
      overNumber,
      ballNumber,
      strikerId,
      nonStrikerId,
      extraRun,
      outType) async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      autoFlipBatsman(widget.runs);
      final response = await ApiService.updateScore(
          contestId,
          matchId,
          teamId,
          bowlerId,
          runsType,
          overNumber,
          ballNumber,
          strikerId,
          nonStrikerId,
          extraRun,
          outType,
          0,
          0);
      if (response['statuscode'] == 200) {
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
                    )));
      } else {}
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
/*Future<void> autoFlipBatsman(int run, String runType, int strikerId, int nonStrikerId) async {
  try {
    if (runType == '') {
      // Flip striker and non-striker only for 1 or 3 runs in normal cases
      if (run == 1 || run == 3) {
        // Switch striker and non-striker
        final temp = strikerId;
        strikerId = nonStrikerId;
        nonStrikerId = temp;
      }
    } else if (runType == 'BYE' || runType == 'legBye') {
      // Flip for bye/leg bye runs in the same way as normal runs
      if (run == 1 || run == 3 || run==5 || run==7
    ) {
        final temp = strikerId;
        strikerId = nonStrikerId;
        nonStrikerId = temp;
      }
    } else if (runType == 'WIDE' || runType == 'noBall') {
      // Wide and no-ball runs don't flip batsmen
      // No change to striker and non-striker
    } else {
      // Handle other types of runs if needed
      // Add additional conditions or logic for special cases
    }
  } catch (e) {
    print("Error in autoFlipBatsman: $e");
  }
}*/

  Future<void> autoFlipBatsman(String run) async {
    try {
      if (run == '1' || run == '2' || run == '3' || run == '4' || run == '6') {
        // Flip striker and non-striker only for 1 or 3 runs in normal cases
        if (run == '1' || run == '3') {
          // Switch striker and non-striker
          setState(() {
            final temp = striker_Id;
            striker_Id = nonStriker_Id;
            nonStriker_Id = temp;
          });
        }
      } /* else if (run == 'BYE' || run == 'LB') {
      // Flip for bye/leg bye runs in the same way as normal runs
      if (extraRun == '1' || extraRun == '3' || extraRun=='5' || extraRun=='7') {
        setState(() {
          final temp = striker_Id;
          striker_Id = nonStriker_Id;
          nonStriker_Id = temp;
        });
      }
    }*/
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error in auto-flipping batsmen: $e')),
      );
    }
  }

  // Log fielding position on click
  void logFieldingPosition(String position) {
    debugPrint("Selected position: $position");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Selected position: $position")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select fielding position',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Field Layout
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade200,
              ),
              child: GestureDetector(
                onTapUp: (details) {
                  // Detect which region was tapped
                  Offset tapPosition = details.localPosition;
                  String selectedPosition =
                      detectFieldingPosition(tapPosition, 300, 300);

                  setState(() {
                    tappedPosition = tapPosition; // Store the tapped position
                  });

                  logFieldingPosition(selectedPosition);
                },
                child: CustomPaint(
                  painter: FieldPainter(tappedPosition: tappedPosition),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 80,
                      color: Colors.brown.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Toggles
          /* ListTile(
            leading: Switch(
              value: showWheelFor1s2s3s,
              onChanged: (value) {
                setState(() {
                  showWheelFor1s2s3s = value;
                });
              },
            ),
            title: const Text("Show wheel for 1s, 2s and 3s"),
          ),
          ListTile(
            leading: Switch(
              value: showWheelForDotBalls,
              onChanged: (value) {
                setState(() {
                  showWheelForDotBalls = value;
                });
              },
            ),
            title: const Text("Show wheel for dot balls"),
          ),*/
          const SizedBox(height: 20),
          // Select Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (widget.runs == 'BYE') {
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
                      return ExtrasModalBYE(
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
                } else if (widget.runs == 'LB') {
                  // showRunModal(context);
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
                      return ExtrasModalLB(
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
                } else if (widget.runs == 'NB') {
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
                      return ExtrasModalNB(
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
                } else if (widget.runs == 'OUT') {
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
                      return DismissalType(
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
                } else {
                  updateScore(
                      widget.contestId,
                      widget.matchId,
                      widget.team1Id,
                      widget.bowlerId,
                      widget.runs,
                      widget.overNumber,
                      widget.ballNumber,
                      widget.strikerid,
                      widget.nonStrikerId,
                      0,
                      "");
                }
              },
              child: Text(
                "Select",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: Colors.blue,
              ),
            ),
          ),

          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void showRunModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Local state for loading
            bool isLoading = false;

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
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
                        "Extras - BYE",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Runs Input
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Runs",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: runController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Next Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Show loading state
                            setModalState(() {
                              isLoading = true;
                            });

                            // Call the API
                            try {
                              await updateScore(
                                widget.contestId,
                                widget.team1Id,
                                widget.matchId,
                                widget.team1Id,
                                widget.team1Name,
                                widget.team2Name,
                                striker_Id,
                                nonStriker_Id,
                                widget.bowlerId,
                                widget.bowlerIdName,
                                widget.batsman1Name,
                              );

                              // Close the modal after API call
                              Navigator.pop(context);

                              // Navigate to Scoreboard Page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScoreBoardPage(
                                    contestId: widget.contestId,
                                    team1Id: widget.team1Id,
                                    matchId: widget.matchId,
                                    team2Id: widget.team2Id,
                                    team1Name: widget.team1Name,
                                    team2Name: widget.team2Name,
                                    batsMan1: striker_Id,
                                    batsMan2: nonStriker_Id,
                                    bowlerId: widget.bowlerId,
                                    bowlerIdName: widget.bowlerIdName,
                                    batsman1Name: widget.batsman1Name,
                                    batsman2Name: widget.batsman2Name,
                                  ),
                                ),
                              );
                            } catch (e) {
                              // Handle API failure
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to update score: $e',
                                  ),
                                ),
                              );
                            } finally {
                              // Hide loading spinner
                              setModalState(() {
                                isLoading = false;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size(200, 50),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Next",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // extra bye

  String detectFieldingPosition(
      Offset tapPosition, double width, double height) {
    double centerX = width / 2;
    double centerY = height / 2;

    double dx = tapPosition.dx - centerX;
    double dy = tapPosition.dy - centerY;

    double angle = (atan2(dy, dx) * 180 / pi + 360) % 360;

    // Updated angle mapping for new positions
    if (angle >= 337.5 || angle < 22.5) {
      return "Deep square leg";
    } else if (angle >= 22.5 && angle < 67.5) {
      return "Deep mid wicket";
    } else if (angle >= 67.5 && angle < 112.5) {
      return "Long on";
    } else if (angle >= 112.5 && angle < 157.5) {
      return "Long off";
    } else if (angle >= 157.5 && angle < 202.5) {
      return "Deep cover";
    } else if (angle >= 202.5 && angle < 247.5) {
      return "Deep point";
    } else if (angle >= 247.5 && angle < 292.5) {
      return "Third man"; // Previously "Third man"
    } else if (angle >= 292.5 && angle < 337.5) {
      return "Deep fine leg";
    }

    return "Unknown position";
  }
}

class FieldPainter extends CustomPainter {
  final Offset? tappedPosition;

  FieldPainter({this.tappedPosition});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw circles
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2, paint);
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 4, paint);

    // Draw lines dividing the circle
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 8; i++) {
      double angle = i * pi / 4;
      double x = center.dx + (size.width / 2) * cos(angle);
      double y = center.dy + (size.height / 2) * sin(angle);
      canvas.drawLine(center, Offset(x, y), paint);
    }

    // Add labels at appropriate angles
    final labels = [
      "Deep square leg",
      "Deep mid wicket",
      "Long on",
      "Long off",
      "Deep cover",
      "Deep point",
      "Third man",
      "Deep fine leg"
    ];
    final labelAngles = List.generate(8, (i) => i * pi / 4);

    final textStyle = TextStyle(color: Colors.black, fontSize: 12);
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < labels.length; i++) {
      double angle = labelAngles[i];
      double x = center.dx + (size.width / 2.5) * cos(angle);
      double y = center.dy + (size.height / 2.5) * sin(angle);

      textPainter.text = TextSpan(text: labels[i], style: textStyle);
      textPainter.layout(minWidth: 0, maxWidth: 100);
      textPainter.paint(canvas, Offset(x - 30, y - 10));
    }

    // Draw tapped position marker
    if (tappedPosition != null) {
      final markerPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;

      canvas.drawCircle(tappedPosition!, 5, markerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
