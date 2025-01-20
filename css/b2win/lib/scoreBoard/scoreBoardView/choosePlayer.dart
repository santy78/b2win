import 'package:flutter/material.dart';

class ChoosePlayersPage extends StatefulWidget {
  const ChoosePlayersPage({Key? key}) : super(key: key);

  @override
  State<ChoosePlayersPage> createState() => _ChoosePlayersPageState();
}

class _ChoosePlayersPageState extends State<ChoosePlayersPage> {
  String? selectedBatsman1;
  String? selectedBatsman2;
  String? selectedBowler;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Handle actions
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: const [
                        Text(
                          'Team Gold',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '0/0 (0.0/5)',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.5,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6.0,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Choose opening Batsmen',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPlayerCard(
                            name: 'keshab hazra',
                            initials: 'K',
                            selected: selectedBatsman1 == 'keshab hazra' ||
                                selectedBatsman2 == 'keshab hazra',
                            onTap: () => _selectBatsman('keshab hazra'),
                          ),
                          _buildPlayerCard(
                            name: 'ankit',
                            initials: 'A',
                            selected: selectedBatsman1 == 'ankit' ||
                                selectedBatsman2 == 'ankit',
                            onTap: () => _selectBatsman('ankit'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Choose Bowler for over 1',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPlayerCard(
                            name: 'keshab hazra',
                            initials: 'K',
                            subtitle: '0 overs',
                            selected: selectedBowler == 'keshab hazra',
                            onTap: () => setState(() {
                              selectedBowler = 'keshab hazra';
                            }),
                          ),
                          _buildPlayerCard(
                            name: 'ankit',
                            initials: 'A',
                            subtitle: '0 overs',
                            selected: selectedBowler == 'ankit',
                            onTap: () => setState(() {
                              selectedBowler = 'ankit';
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (selectedBatsman1 != null &&
                                  selectedBatsman2 != null &&
                                  selectedBowler != null)
                              ? () {
                                  // Handle Select action
                                }
                              : null, // Disable button if not all selections are made
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16.0),
                            backgroundColor: (selectedBatsman1 != null &&
                                    selectedBatsman2 != null &&
                                    selectedBowler != null)
                                ? Colors.blue
                                : Colors.grey[300],
                          ),
                          child: const Text(
                            'Select',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _selectBatsman(String batsman) {
    setState(() {
      if (selectedBatsman1 == batsman) {
        selectedBatsman1 = null;
      } else if (selectedBatsman2 == batsman) {
        selectedBatsman2 = null;
      } else if (selectedBatsman1 == null) {
        selectedBatsman1 = batsman;
      } else if (selectedBatsman2 == null) {
        selectedBatsman2 = batsman;
      }
    });
  }

  Widget _buildPlayerCard({
    required String name,
    required String initials,
    String? subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
              color: selected ? Colors.blue : Colors.grey, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
          color: selected ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: selected ? Colors.blue : Colors.grey[300],
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                color: selected ? Colors.blue : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.blue : Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
