import 'package:b2winai/scoreBoard/scoreBoardView/fieldingPositions.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class ScoreBoardPage extends StatefulWidget {
  const ScoreBoardPage({Key? key}) : super(key: key);

  @override
  State<ScoreBoardPage> createState() => _ScoreBoardPageState();
}

class _ScoreBoardPageState extends State<ScoreBoardPage> {
  String selectedRun = "6"; // Tracks the selected bowling score button
  Map<String, dynamic> firstInnings = {};
  Map<String, dynamic> secondInnings = {};
  List<Map<String, dynamic>> firstInningsbatting = [];
  List<Map<String, dynamic>> firstInningsBowling = [];
  List<Map<String, dynamic>> secondInningsbatting = [];
  List<Map<String, dynamic>> secondInningsBowling = [];
  @override
  void initState() {
    super.initState();
    getScore(context, 2, 23);
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

        List<Map<String, dynamic>> firstInnings_Batting =
            firstInnings['batting'];
        List<Map<String, dynamic>> firstInnings_Bowling =
            firstInnings['bowling'];
        List<Map<String, dynamic>> secondInnings_Batting =
            secondInnings['batting'];
        List<Map<String, dynamic>> secondInnings_Bowling =
            secondInnings['bowling'];

        setState(() {
          firstInningsbatting = firstInnings_Batting;
          firstInningsBowling = firstInnings_Bowling;
          secondInningsbatting = secondInnings_Batting;
          secondInningsBowling = secondInnings_Bowling;
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
        Map<String, dynamic> data = response['data'];

        setState(() {
          firstInnings = data['first_innings'];
          secondInnings = data['second_innings'];
        });
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
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      firstInnings['name'] ?? '',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${firstInnings["runs_scored"]}/${firstInnings["wickets_lost"]} (${firstInnings["over_number"]}/${firstInnings["ball_number"]})',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
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
              _buildPlayerCard('keshab hazra', 1, 1, true),
              _buildPlayerCard('ankit', 9, 3, false),
            ],
          ),
          const Divider(thickness: 1.0),
          // Bowling Team Info
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Team Tiger',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  '🔄 ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'keshab hazra',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),
                ),
                const SizedBox(width: 16.0),
                ...['1', '6', '2', '1'].map((run) {
                  final isSelected = run == selectedRun;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRun = run;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Run : $run")),
                          );
                        });
                      },
                      child: CircleAvatar(
                        backgroundColor:
                            isSelected ? Colors.blue : Colors.grey[200],
                        child: Text(
                          run,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
                ...['0', '1', '2', '3', 'Four', 'Six', 'OUT', 'UNDO']
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
    );
  }

  Widget _buildPlayerCard(String name, int runs, int balls, bool isStriker) {
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
  }

  Widget _buildScoreButton(String label) {
    final isActionButton = label == 'OUT' || label == 'UNDO';
    return ElevatedButton(
      onPressed: () {
        // Add action handling here
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => FieldingPositionModal(
              runs: label,
              overNumber: firstInnings["over_number"],
              ballNumber: firstInnings["ball_number"]),
        );
        print('$label tapped');
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
}
