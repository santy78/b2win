import 'package:b2winai/scoreBoard/matches/createMatch.dart';
import 'package:b2winai/scoreBoard/matches/createMatchPage.dart';
import 'package:b2winai/scoreBoard/matches/matchActionPage.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/scoreBoardView.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/tossDetails.dart';
import 'package:b2winai/service/AuthService.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchListPage extends StatefulWidget {
  @override
  _MatchListPageState createState() => _MatchListPageState();
}

class _MatchListPageState extends State<MatchListPage> {
  List<Map<String, dynamic>> yetToStartMatches = [];
  List<Map<String, dynamic>> runningMatches = [];
  List<Map<String, dynamic>> finishMatches = [];
  List<Map<String, dynamic>> allMatches = [];
  String? currentUserUid;
  bool isGuest = true;
  List<Map<String, dynamic>> contests = [];

  @override
  void initState() {
    super.initState();
    _loadSessionData();
    getContestList(context);
    getSingleMatches(context);
  }

  Future<void> _loadSessionData() async {
    try {
      final sessionData = await AuthService.getSessionData();
      setState(() {
        currentUserUid = sessionData['uid'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading session data: $e')),
      );
    }
  }

  Future<void> getContestList(BuildContext context) async {
    try {
      Map<String, dynamic> response = await ApiService.getContest(context);
      if (response['statuscode'] == 200) {
        List<dynamic> data = response['data'];

        List<Map<String, dynamic>> dataResponse =
            List<Map<String, dynamic>>.from(data);
        setState(() {
          contests = dataResponse;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> getSingleMatches(BuildContext context) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getSingleMatches(context);

      if (response['statuscode'] == 200) {
        setState(() {
          allMatches = List<Map<String, dynamic>>.from(
              response['data']['Single Match']['No Group']);
          print(allMatches);

          // Check if current user is associated with any match
          if (currentUserUid != null) {
            isGuest = !allMatches.any((match) =>
                    match['created_delegated_uid'] ==
                    currentUserUid // Check match's uid
                );
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
      /*appBar: AppBar(
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
                MaterialPageRoute(builder: (context) => MatchCreatePage()),
              );
            },
          ),
        ],
      ), */
      body: allMatches.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: allMatches.length,
              itemBuilder: (context, index) {
                final match = allMatches[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MatchActionPage(
                            contestId: match['contest_id'],
                            matchId: match['match_id'],
                            team1Id: match['team1_id'],
                            team2Id: match['team2_id'],
                            team1Name: match['team1_name'],
                            team2Name: match['team2_name'],
                            isGuest: isGuest ||
                                match['created_delegated_uid'] !=
                                    currentUserUid,
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
                            // Match Date and Triple Dot Menu
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatDate(match["match_datetime"]),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (String value) {
                                    if (value == 'Add Team Squad') {
                                      // Handle Add Team Squad action
                                      /* Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTeamSquadPage(matchId: match['match_id']),
                        ),
                      );*/
                                    } else if (value == 'Edit Match') {
                                      // Handle Edit Match action
                                      /*Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditMatchPage(matchId: match['match_id']),
                        ),
                      );*/
                                    }
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'Add Team Squad',
                                      child: Text('Add Team Squad'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'Edit Match',
                                      child: Text('Edit Match'),
                                    ),
                                  ],
                                  icon: const Icon(Icons.more_vert),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Team 1 Info
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

                            // Team 2 Info
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

                            // Match Location and Status
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
      /*  bottomNavigationBar: BottomNavigationBar(
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
      ), */
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10), // Adjust space below FAB
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MatchCreatePage(
                          teamAName: "Team A",
                          teamBName: "Team B",
                          teamAList: [],
                          teamBList: [],
                        )));
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
