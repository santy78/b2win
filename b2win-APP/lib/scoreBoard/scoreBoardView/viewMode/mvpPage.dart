import 'package:flutter/material.dart';

class MVPPage extends StatelessWidget {
  final List<dynamic> mvpData;

  const MVPPage({super.key, required this.mvpData});

  @override
  Widget build(BuildContext context) {
    final filteredPlayers = mvpData
        .where((player) => player['total_points'] > 0)
        .toList()
      ..sort((a, b) => b['total_points'].compareTo(a['total_points']));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading and Info Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Most Valuable Players',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.blue),
                onPressed: () => _showCalculationInfo(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Player List
          ListView.builder(
            physics:
                const NeverScrollableScrollPhysics(), // Important: prevent nested scroll
            shrinkWrap: true, // Important: allow list inside column
            itemCount: filteredPlayers.length,
            itemBuilder: (context, index) {
              final player = filteredPlayers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: _buildPlayerAvatar(player),
                  title: Text(
                    player['player_name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player['team_name'],
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildPoints('Batting', player['batting_points']),
                          const SizedBox(width: 12),
                          _buildPoints('Bowling', player['bowling_points']),
                          const SizedBox(width: 12),
                          _buildPoints('Fielding', player['fielding_points']),
                        ],
                      ),
                    ],
                  ),
                  trailing: Text(
                    player['total_points'].toStringAsFixed(3),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPoints(String label, num points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
        Text(
          points.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerAvatar(Map<String, dynamic> player) {
    final imageUrl = player['player_image'];
    final playerName = player['player_name'] ?? "";

    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      return CircleAvatar(
        radius: 26,
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: Colors.grey[300],
      );
    } else {
      return CircleAvatar(
        radius: 26,
        backgroundColor: Colors.blue.shade400,
        child: Text(
          _getInitials(playerName),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );
    }
  }

  String _getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return parts[0][0] + parts[1][0]; // First letter of first and last name
    } else if (parts.isNotEmpty) {
      return parts[0][0]; // First letter only
    } else {
      return "?";
    }
  }

  void _showCalculationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'How is MVP Calculated?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: const Text(
            'MVP points are calculated based on:\n\n'
            '• Batting performance (runs, strike rate)\n'
            '• Bowling performance (wickets, economy)\n'
            '• Fielding performance (catches, run-outs)\n\n'
            'The total points are the sum of all these contributions.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
