import 'package:flutter/material.dart';

class ScoreBoardPage extends StatefulWidget {
  const ScoreBoardPage({Key? key}) : super(key: key);

  @override
  State<ScoreBoardPage> createState() => _ScoreBoardPageState();
}

class _ScoreBoardPageState extends State<ScoreBoardPage> {
  String selectedRun = "6"; // Tracks the selected bowling score button

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
                    const Text(
                      'Team Gold',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '10/0 (0.4/5)',
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
                ...['0', '1', '2', '3', '4\nFour', '6\nSix', 'OUT', 'UNDO']
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
