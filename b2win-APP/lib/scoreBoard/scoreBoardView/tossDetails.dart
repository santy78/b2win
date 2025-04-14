import 'package:b2winai/scoreBoard/scoreBoardView/choosePlayer.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/scoreBoardView.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class TossDetailPage extends StatefulWidget {
  final int contestId;
  final int matchId;
  final int team1Id;
  final int team2Id;
  final String? team1Name;
  final String? team2Name;
  const TossDetailPage(
      {Key? key,
      required this.contestId,
      required this.matchId,
      required this.team1Id,
      required this.team2Id,
      this.team1Name,
      this.team2Name})
      : super(key: key);

  @override
  State<TossDetailPage> createState() => _TossDetailPageState();
}

class _TossDetailPageState extends State<TossDetailPage> {
  int selectedWinTeamId = 0;
  int selectedLossTeamId = 0;
  String? selectedChoice;
  String? selectedWinTeamName;
  String? selectedLossTeamName;
  String? _tossDecision;
  int? _tossWinnerTeamId;
  int? _tossLossTeamId;
  int? _firstInningsId;
  int? _secondInningsId;
  int? _overPerInnings;
  String? _firstInningsStatus;
  String? _secondInningsStatus;
  List<Map<String, dynamic>> tossDetails = [];
  final TextEditingController overNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();

    setState(() {
      //  getTossDetails(context, widget.contestId, widget.matchId);
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

        int tossWinnerTeamId = -1;
        int tossLossTeamId = -1;
        String firstInningsTeamName = "";
        String secondInningsTeamName = "";

        for (var inning in data) {
          if (inning['inning_number'] == 1) {
            firstInningsTeamName = inning['team_name'] ?? "";
            tossWinnerTeamId = inning['team_id'] ?? -1;
          } else if (inning['inning_number'] == 2) {
            secondInningsTeamName = inning['team_name'] ?? "";
            tossLossTeamId = inning['team_id'] ?? -1;
          }
        }

        setState(() {
          // Update UI state with extracted toss details
          _tossWinnerTeamId = tossWinnerTeamId;
          _tossLossTeamId = tossLossTeamId;
        });

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
              team1Id: _tossWinnerTeamId!,
              team1Name: firstInningsTeamName.toString(),
              team2Id: _tossLossTeamId!,
              team2Name: secondInningsTeamName.toString(),
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> updateTossDetails(BuildContext context, int contestId,
      int matchId, int teamId, overNumber, tossDecision) async {
    try {
      String tossDecided;
      if (tossDecision == 'Batting') {
        tossDecided = 'bat';
      } else {
        tossDecided = 'bowl';
      }
      int overs = int.parse(overNumber.text);
      Map<String, dynamic> response = await ApiService.tossDetails(
          context, contestId, matchId, teamId, overs, tossDecided);

      if (response['status'] == "success") {
        getTossDetails(context, widget.contestId, widget.matchId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Toss Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Who won the toss?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSelectionCard(
                  label: widget.team1Name!,
                  selected: selectedWinTeamId == widget.team1Id,
                  onTap: () => setState(() {
                    selectedWinTeamId = widget.team1Id;
                    selectedWinTeamName = widget.team1Name;
                    selectedLossTeamId = widget.team2Id;
                    selectedLossTeamName = widget.team2Name;
                  }),
                ),
                _buildSelectionCard(
                  label: widget.team2Name!,
                  selected: selectedWinTeamId == widget.team2Id,
                  onTap: () => setState(() {
                    selectedWinTeamId = widget.team2Id;
                    selectedWinTeamName = widget.team2Name;
                    selectedLossTeamId = widget.team1Id;
                    selectedLossTeamName = widget.team1Name;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Toss-winner elected to - ?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIconSelectionCard(
                  label: 'Batting',
                  icon: Icons.sports_cricket,
                  selected: selectedChoice == 'Batting',
                  onTap: () => setState(() {
                    selectedChoice = 'Batting';
                  }),
                ),
                _buildIconSelectionCard(
                  label: 'Bowling',
                  icon: Icons.sports_baseball,
                  selected: selectedChoice == 'Bowling',
                  onTap: () => setState(() => selectedChoice = 'Bowling'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'How many overs to be played ?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: overNumberController,
              decoration: const InputDecoration(
                  labelText: 'Overs Per Innings', border: OutlineInputBorder()),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (selectedWinTeamId > 0 && selectedChoice != null)
                    ? () {
                        updateTossDetails(
                            context,
                            widget.contestId,
                            widget.matchId,
                            selectedWinTeamId,
                            overNumberController,
                            selectedChoice);
                      }
                    : null, // Disable button if selection is incomplete
                // style: ElevatedButton.styleFrom(
                //   padding: const EdgeInsets.all(16.0),

                // ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      (selectedWinTeamId != null && selectedChoice != null)
                          ? Colors.blue
                          : Colors.grey[300],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    // Split the label by space to break into lines
    final lines = label.split(' ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: selected ? Colors.blue : Colors.grey, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
          color: selected ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
        ),
        width: 120,
        height: 100,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: selected ? Colors.blue : Colors.grey[300],
              child: const Text(
                'T',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lines.join('\n'), // Join each word with newline
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              textAlign: TextAlign.center, // Center align the text
              style: TextStyle(
                fontSize: 14,
                color: selected ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSelectionCard({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: selected ? Colors.blue : Colors.grey, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
          color: selected ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
        ),
        width: 120,
        height: 120,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: selected ? Colors.blue : Colors.grey),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                  fontSize: 14,
                  color: selected ? Colors.blue : Colors.black,
                )),
          ],
        ),
      ),
    );
  }
}
