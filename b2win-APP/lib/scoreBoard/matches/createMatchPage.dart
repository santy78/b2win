import 'package:b2winai/constant.dart';
import 'package:b2winai/scoreBoard/matches/addMatchSquard.dart';
import 'package:b2winai/scoreBoard/teams/addPlayersPage.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchCreatePage extends StatefulWidget {
  final List<Map<String, dynamic>> teamAList;
  final List<Map<String, dynamic>> teamBList;

  const MatchCreatePage(
      {super.key, required this.teamAList, required this.teamBList});

  @override
  _MatchCreatePageState createState() => _MatchCreatePageState();
}

class _MatchCreatePageState extends State<MatchCreatePage> {
  int inningsCount = 0;
  int oversPerBowler = 0;
  int powerPlayOvers = 0;
  String matchType = "Limited overs";
  String mode = "Casual";
  DateTime? matchDateTime;
  String teamA = "Team A";
  String teamB = "Team B";
  List<Map<String, dynamic>> teamAList = [];
  List<Map<String, dynamic>> teamBList = [];
  List<Map<String, dynamic>> teams = [];
  int contestId = ApiConstants.defaultContestId;
  bool isFromCreateMatchPage = true;
  final TextEditingController roundTypeController = TextEditingController();
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController matchDateTimeController = TextEditingController();
  String ballType = "";
  String pitchType = "";

  @override
  void initState() {
    super.initState();
    getTeams(context, contestId);
    teamAList = widget.teamAList;
    teamBList = widget.teamBList;
  }

  Future<void> getTeams(BuildContext context, int contestId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getTeams(context, contestId);
      if (response['statuscode'] == 200) {
        List<dynamic> data = response['data'];

        List<Map<String, dynamic>> dataResponse =
            List<Map<String, dynamic>>.from(data);
        setState(() {
          teams = dataResponse;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          matchDateTime = DateTime(pickedDate.year, pickedDate.month,
              pickedDate.day, pickedTime.hour, pickedTime.minute);
        });
      }
    }
  }

  void _selectTeam(BuildContext context, bool isTeamA) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: teams.map((team) {
            return ListTile(
              title: Text(team['name']),
              /* trailing: IconButton(
                icon: Icon(Icons.settings), */
              onTap: () {
                setState(() {
                  if (isTeamA) {
                    teamA = team['name'];
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddPlayersPage(
                                teamId: team["id"],
                                teamName: team["name"],
                                isFromCreateMatchPage: true,
                                isTeamA: true)));
                  } else {
                    teamB = team['name'];
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddPlayersPage(
                                teamId: team["id"],
                                teamName: team["name"],
                                isFromCreateMatchPage: true,
                                isTeamA: false)));
                  }
                });
              },
              /*),*/
              // onTap: () {
              //   setState(() {
              //     if (isTeamA) {
              //       teamA = team['name'];
              //     } else {
              //       teamB = team['name'];
              //     }
              //   });
              //   Navigator.pop(context);
              // },
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> startMatch() async {
    Map<String, dynamic> requestBody = {
      "contest_id": contestId,
      "matches": [
        {
          "round_type": roundTypeController.text,
          "group_name": groupNameController.text,
          "pitch_type": pitchType,
          "ball_type": ballType,
          "match_type": matchType,
          "innings_count": inningsCount,
          "match_number": 0,
          "team1_name": teamA,
          "team2_name": teamB,
          "match_datetime": matchDateTimeController.text,
          "team1_players": teamAList,
          "team2_players": teamBList,
          "flag": "I"
        }
      ]
    };
    try {
      Map<String, dynamic> response =
          await ApiService.createMatch(requestBody, context);
      if (response['statuscode'] == 200) {
        List<dynamic> data = response['data'];
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
        title: const Text("Add Match"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => _selectTeam(context, true),
                      child: Column(
                        children: [
                          CircleAvatar(radius: 30, child: Text(teamA[0])),
                          SizedBox(height: 8),
                          Text(teamA)
                        ],
                      ),
                    ),
                    const Text("VS",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => _selectTeam(context, false),
                      child: Column(
                        children: [
                          CircleAvatar(radius: 30, child: Text(teamB[0])),
                          SizedBox(height: 8),
                          Text(teamB)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: roundTypeController,
                decoration: InputDecoration(
                    hintText: "Round Type", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: groupNameController,
                decoration: InputDecoration(
                    hintText: "Group Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              const Text("Match Schedule",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: matchDateTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: matchDateTime == null
                      ? "Select Date & Time"
                      : DateFormat('yyyy-MM-dd – kk:mm').format(matchDateTime!),
                  border: const OutlineInputBorder(),
                ),
                onTap: () => _selectDateTime(context),
              ),
              const SizedBox(height: 10),
              const Text("Ball Type",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBallType("leather"),
                  _buildBallType("tennis"),
                  _buildBallType("other"),
                ],
              ),
              const SizedBox(height: 10),
              const Text("Pitch Type",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPitchType("rough"),
                  _buildPitchType("cement"),
                  _buildPitchType("turf"),
                  _buildPitchType("asphalt"),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: Text("Match Type",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<String>(
                      value: matchType,
                      items: ["Limited overs", "Test Match"].map((String type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          matchType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildCounter("Innings Count", inningsCount,
                  (value) => setState(() => inningsCount = value)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    //Call Start match api
                    startMatch();
                  },
                  child: const Text("Start Match"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBallType(String type) {
    return GestureDetector(
        onTap: () {
          setState(() {
            ballType = type; // Update selected value
          });
        },
        child: Column(
          children: [
            const Icon(Icons.sports_cricket, size: 40),
            Text(type),
          ],
        ));
  }

  Widget _buildPitchType(String type) {
    return GestureDetector(
        onTap: () {
          setState(() {
            pitchType = type; // Update selected pitch type
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(type),
        ));
  }

  Widget _buildCounter(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => onChanged(value > 1 ? value - 1 : 1),
            ),
            Text("$value",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        )
      ],
    );
  }
}
