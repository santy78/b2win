import 'package:b2winai/scoreBoard/matches/createMatch.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/scoreBoardView.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/tossDetails.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchListPage extends StatefulWidget {
  @override
  _MatchListPageState createState() => _MatchListPageState();
}

class _MatchListPageState extends State<MatchListPage> {
  List<Map<String, dynamic>> matches = [];

  @override
  void initState() {
    super.initState();
    getMatches(context, 2);
  }

  Future<void> getMatches(BuildContext context, int contestId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getMatches(context, contestId);

      if (response['statuscode'] == 200) {
        setState(() {
          /*if (List<Map<String, dynamic>>.from(response['data']['yetToStart'])
              .isNotEmpty) {
            matches =
                List<Map<String, dynamic>>.from(response['data']['yetToStart']);
          } else if (List<Map<String, dynamic>>.from(
                  response['data']['running'])
              .isNotEmpty) {
            matches =
                List<Map<String, dynamic>>.from(response['data']['running']);
          } else */
          if (List<Map<String, dynamic>>.from(response['data']['finish'])
              .isNotEmpty) {
            matches =
                List<Map<String, dynamic>>.from(response['data']['finish']);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  String formatDate(String datetime) {
    final DateTime parsedDate = DateTime.parse(datetime);
    return DateFormat('EEE, d MMM yyyy - hh:mm a').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 103, 178, 207),
        title: const Text(
          "Matches",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              // Handle filter action
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewMatchPage()),
              );
            },
          ),
        ],
      ),
      body: matches.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScoreBoardPage(
                            contestId: match['contest_id'],
                            matchId: match['match_id'],
                            team1Id: match['team1_id'],
                            team2Id: match['team2_id'],
                            team1Name: match['team1_name'],
                            team2Name: match['team2_name'],
                            batsMan1: -1,
                            batsMan2: -1,
                            bowlerId: -1,
                            bowlerIdName: "",
                            batsman1Name: "",
                            batsman2Name: "",
                          ),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatDate(match["match_datetime"]),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blue.shade100,
                                      child: Text(
                                        match["team1_name"][0],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      match["team1_name"],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Text(
                                  match["team1_score"]?.toString() ?? "0",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.red.shade100,
                                      child: Text(
                                        match["team2_name"][0],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      match["team2_name"],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Text(
                                  match["team2_score"]?.toString() ?? "0",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  match["location"] ?? "Location not available",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    match["match_status"],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_cricket),
            label: "Matches",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Teams",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: "Tournament",
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
