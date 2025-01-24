import 'package:b2winai/scoreBoard/scoreBoardView/scoreBoardView.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class ExtrasModalNB extends StatefulWidget {
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
  final int batsMan1;
  final int batsMan2;
  final int bowlerId;

  final String bowlerIdName;
  const ExtrasModalNB({
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
    required this.batsMan1,
    required this.batsMan2,
    required this.bowlerId,
    required this.bowlerIdName,
  });
  @override
  _ExtrasModalNBState createState() => _ExtrasModalNBState();
}

class _ExtrasModalNBState extends State<ExtrasModalNB> {
  bool isLoading = false;
  final TextEditingController runController = TextEditingController();
  Future<void> updateScore(
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
      outType) async {
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
      onTap: () =>
          FocusScope.of(context).unfocus(), // Close keyboard on tap outside
      child: SingleChildScrollView(
        reverse: true, // Ensures the modal shifts up when the keyboard is open
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom, // Adjusts height based on keyboard
        ),
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
                "Extras - NB",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Form Row for BYE and RUNS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BYE Field
                  Expanded(
                    child: Column(
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
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close modal
                    updateScore(
                        widget.contestId,
                        widget.matchId,
                        widget.team1Id,
                        widget.bowlerId,
                        'NB',
                        widget.overNumber,
                        widget.ballNumber,
                        widget.strikerid,
                        widget.nonStrikerId,
                        int.parse(runController.text),
                        "");
                  },
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
    );
  }
}
