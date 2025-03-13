import 'package:b2winai/scoreBoard/tournament/addTournament.dart';
import 'package:flutter/material.dart';

class TournamentListPage extends StatelessWidget {
  final List<Map<String, String>> tournaments = [
    {
      'title': 'khalil',
      'date': '19 Dec - 20 Dec',
      'type': 'Knockout',
      'status': 'Upcoming',
    },
    {
      'title': 'DPL',
      'date': '01 Jan - 02 Jan',
      'type': 'Knockout',
      'status': 'Upcoming',
    },
    {
      'title': 'ICC T20 CRICKET',
      'date': '07 Jan - 08 Jan',
      'type': 'Box League',
      'status': 'Upcoming',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: const Text('Tournaments'),
        /*leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),*/
        actions: [
          IconButton(
            icon: Icon(Icons.add), // Add Icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTournamentPage()),
              );
            },
          ),
        ],
      ), */
      body: ListView.builder(
        itemCount: tournaments.length,
        itemBuilder: (context, index) {
          final tournament = tournaments[index];
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                gradient: const LinearGradient(
                  colors: [Colors.lightBlueAccent, Colors.blue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(26.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 40.0,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tournament['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '${tournament['date']} • ${tournament['type']}',
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        tournament['status'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10), // Adjust space below FAB
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddTournamentPage()));
            print("Floating Button Pressed!");
          },
          child: Icon(Icons.add, size: 30),
          backgroundColor: Colors.lightBlueAccent,
          shape: CircleBorder(),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Bottom-right
    );
  }
}
