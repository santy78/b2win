import 'package:flutter/material.dart';

class TossDetailPage extends StatefulWidget {
  const TossDetailPage({Key? key}) : super(key: key);

  @override
  State<TossDetailPage> createState() => _TossDetailPageState();
}

class _TossDetailPageState extends State<TossDetailPage> {
  String? selectedTeam;
  String? selectedChoice;

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
                  label: 'Team Tiger',
                  selected: selectedTeam == 'Team Tiger',
                  onTap: () => setState(() => selectedTeam = 'Team Tiger'),
                ),
                _buildSelectionCard(
                  label: 'Team Gold',
                  selected: selectedTeam == 'Team Gold',
                  onTap: () => setState(() => selectedTeam = 'Team Gold'),
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
                  onTap: () => setState(() => selectedChoice = 'Batting'),
                ),
                _buildIconSelectionCard(
                  label: 'Bowling',
                  icon: Icons.sports_kabaddi,
                  selected: selectedChoice == 'Bowling',
                  onTap: () => setState(() => selectedChoice = 'Bowling'),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (selectedTeam != null && selectedChoice != null)
                    ? () {
                        // Handle Next action
                      }
                    : null, // Disable button if selection is incomplete
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  backgroundColor:
                      (selectedTeam != null && selectedChoice != null)
                          ? Colors.blue
                          : Colors.grey[300],
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        height: 80,
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
