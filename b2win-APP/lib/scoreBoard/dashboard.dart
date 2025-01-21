import 'package:b2winai/login/profile.dart';
import 'package:b2winai/scoreBoard/matches/matchList.dart';
import 'package:b2winai/scoreBoard/players/uploadAllPlayers.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/choosePlayer.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/fieldingPositions.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/scoreBoardView.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/tossDetails.dart';
import 'package:b2winai/scoreBoard/teams/teamList.dart';
import 'package:b2winai/scoreBoard/tournament/addTournament.dart';
import 'package:b2winai/scoreBoard/tournament/tournamentList.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 103, 178, 207),
          elevation: 0,
          title: Text(
            "Dashboard",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Create Team Section

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Create Team
                      _buildCarouselItem(
                        context,
                        icon: Icons.add,
                        title: "Set up a team in minutes.",
                        actionText: "Create team",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TeamsListPage()),
                          );
                        },
                      ),
                      SizedBox(width: 16),
                      // Create Match
                      _buildCarouselItem(
                        context,
                        icon: Icons.sports_cricket,
                        title: "Organize your own match.",
                        actionText: "Create match",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MatchListPage()),
                          );
                        },
                      ),
                      SizedBox(width: 16),
                      // Create Tournament
                      _buildCarouselItem(
                        context,
                        icon: Icons.emoji_events,
                        title: "Host a tournament.",
                        actionText: "Create tournament",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddTournamentPage()));
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Tournaments Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tournaments",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TournamentListPage()));
                      },
                      child: Text("View all",
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade300, Colors.blue.shade600],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.emoji_events, size: 40, color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        "champions trophy",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        "18 Dec - 19 Dec  •  Knockout",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Upcoming",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // No Matches Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "No Matches in this area!",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Enjoy the freedom of creating your\nown cricket matches or teams.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1, // Set this to the current tab index
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()),
              );
            } else if (index == 1) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => FieldingPositionModal(),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UploadAllPlayersPage()),
              );
            } else if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_cricket),
              label: "My Cricket",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: "Stats",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
          selectedItemColor: Colors.blue, // Active icon color
          unselectedItemColor: Colors.grey, // Inactive icon color
          type: BottomNavigationBarType.fixed,
        ));
  }

  Widget _buildCarouselItem(BuildContext context,
      {required IconData icon,
      required String title,
      required String actionText,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300, // Set a fixed width for each item
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.add, size: 30.0, color: Colors.blue),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  actionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
