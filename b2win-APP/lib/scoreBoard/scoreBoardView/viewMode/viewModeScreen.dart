import 'package:b2winai/scoreBoard/scoreBoardView/viewMode/commentaryPage.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/viewMode/liveStreamingPage.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/viewMode/mvpPage.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewModeScreen extends StatefulWidget {
  final int contestId;
  final int matchId;

  const ViewModeScreen({
    Key? key,
    required this.contestId,
    required this.matchId,
  }) : super(key: key);

  @override
  _ViewModeScreenState createState() => _ViewModeScreenState();
}

class _ViewModeScreenState extends State<ViewModeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> team1BattingData = [];
  List<Map<String, dynamic>> team1BowlingData = [];
  List<Map<String, dynamic>> team2BattingData = [];
  List<Map<String, dynamic>> team2BowlingData = [];

  List<String> formattedTeam1Wickets = [];
  List<String> formattedTeam2Wickets = [];

  Map<String, String> team1Dismissals = {};
  Map<String, String> team2Dismissals = {};

  Map<String, dynamic> bestPerformanceData = {};

  List<dynamic> mvpData = [];

  int teamId1 = 0;
  int teamId2 = 0;
  String teamName1 = "";
  String teamName2 = "";
  int team1Score = 0;
  int team1WicketLost = 0;
  int team1overNumber = 0;
  int team1ballNumber = 0;
  int team1extras = 0;
  double team1crr = 0.0;
  String team1runningOver = "0.0";
  int team2Score = 0;
  int team2WicketLost = 0;
  int team2overNumber = 0;
  int team2ballNumber = 0;
  int team2extras = 0;
  double team2crr = 0.0;
  String team2runningOver = "0.0";
  String tossDeclaration = "";
  String timeStamp = "";
  String ballType = "";
  String pitchType = "";
  String matchType = "";
  String roundType = "";
  int inningsCount = 0;
  int overNumber = 0;
  String tournamentName = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    getMatchInfo(context, widget.contestId, widget.matchId);
    getBestPerformance(context, widget.contestId, widget.matchId);
    getMvp(context, widget.contestId, widget.matchId);
    getScoreBoard(context, widget.contestId, widget.matchId);
    getScore(context, widget.contestId, widget.matchId);
    getExtras(context, widget.contestId, widget.matchId);
    getMatchInningsDetails(context, widget.contestId, widget.matchId);
    getFallOfWickets(context, widget.contestId, widget.matchId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> getMatchInfo(
      BuildContext context, int contestId, int matchId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getMatchInfo(context, contestId, matchId);
      if (response['statuscode'] == 200) {
        if (response['data'] != null) {
          Map<String, dynamic> data = response['data'];

          setState(() {
            String originalTimestamp = data["match_datetime"] ?? "";
            // Parse the original timestamp
            DateTime dateTime = DateTime.parse(originalTimestamp);
            // Format the DateTime object to the desired format
            timeStamp = DateFormat('dd-MMM-yy hh:mm a').format(dateTime);

            ballType = data["ball_type"] ?? "";

            pitchType = data["pitch_type"] ?? "";

            matchType = data["match_type"] ?? "";

            roundType = data["round_type"] ?? "";

            inningsCount = data["innings_count"] ?? 0;
          });
        } else {}
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> getBestPerformance(
      BuildContext context, int contestId, int matchId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getBestPerformance(context, contestId, matchId);
      if (response['statuscode'] == 200) {
        if (response['data'] != null) {
          setState(() {
            bestPerformanceData = response['data'];
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> getMvp(BuildContext context, int contestId, int matchId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getMvp(context, contestId, matchId);
      if (response['statuscode'] == 200 && response['data'] != null) {
        setState(() {
          mvpData = response['data'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> getMatchInningsDetails(
      BuildContext context, int contestId, int matchId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getTossDetails(context, contestId, matchId);

      if (response['status'] == 'success' && response['data'] != null) {
        List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(response['data']);

        String team1TossDecision = "";
        String team2TossDecision = "";
        int overPerInnings = 0;

        for (var inning in data) {
          if (inning['inning_number'] == 1) {
            team1TossDecision = inning['toss_decision'] ?? "";
            overPerInnings = inning['over_per_innings'] ?? 0;
          } else if (inning['inning_number'] == 2) {
            team2TossDecision = inning['toss_decision'] ?? "";
          }
        }

        setState(() {
          // Update UI state with extracted toss details
          if (team1TossDecision != "") {
            tossDeclaration =
                "$teamName1 won the toss and elected to $team1TossDecision";
          } else if (team2TossDecision != "") {
            tossDeclaration =
                "$teamName2 won the toss and elected to $team2TossDecision";
          }
          overNumber = overPerInnings;
        });
      } else {}
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
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
        Map<String, dynamic> battingTeam = firstInnings['batting_team'];
        Map<String, dynamic> bowlingTeam = firstInnings['bowling_team'];

        int _teamId1 = battingTeam['team_id'];
        String _teamName1 = battingTeam['name'];
        int _teamId2 = bowlingTeam['team_id'];
        String _teamName2 = bowlingTeam['name'];
        final team1Batting = firstInnings['batting'];
        final team1Bowling = firstInnings['bowling'];
        final team2Batting = secondInnings['batting'];
        final team2Bowling = secondInnings['bowling'];

        team1BattingData = team1Batting.map<Map<String, dynamic>>((player) {
          return {
            'name': player['player_name'],
            // 'dismissal':
            //     player['dismissal'].isEmpty ? 'not out' : player['dismissal'],
            'runs': player['runs_scored'],
            'balls': player['balls_faced'],
            'fours': player['fours'],
            'sixes': player['sixes'],
            'strikeRate': player['strike_rate'].toDouble(),
          };
        }).toList();

        team2BattingData = team2Batting.map<Map<String, dynamic>>((player) {
          return {
            'name': player['player_name'] ?? '',
            // 'dismissal':
            //     player['dismissal'].isEmpty ? 'not out' : player['dismissal'],
            'runs': player['runs_scored'] ?? 0,
            'balls': player['balls_faced'] ?? 0,
            'fours': player['fours'] ?? 0,
            'sixes': player['sixes'] ?? 0,
            'strikeRate': player['strike_rate'].toDouble() ?? 0.0,
          };
        }).toList();

        setState(() {
          teamId1 = _teamId1;
          teamName1 = _teamName1;
          teamId2 = _teamId2;
          teamName2 = _teamName2;
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
        if (response['data'] != null) {
          Map<String, dynamic> data = response['data'];

          setState(() {
            Map<String, dynamic> firstInnings = data['first_innings'];
            Map<String, dynamic> secondInnings = data['second_innings'];

            //team1 details
            team1Score = firstInnings["runs_scored"] ?? 0;
            team1WicketLost = firstInnings["wickets_lost"] ?? 0;
            team1overNumber = firstInnings["over_number"] ?? 0;
            team1ballNumber = firstInnings["ball_number"] ?? 0;
            team1crr = firstInnings["current_run_rate"].toDouble() ?? 0.0;
            team1runningOver = firstInnings["total_overs"] ?? "0.0";
            //team2 details
            team2Score = secondInnings["runs_scored"] ?? 0;
            team2WicketLost = secondInnings["wickets_lost"] ?? 0;
            team2overNumber = secondInnings["over_number"] ?? 0;
            team2ballNumber = secondInnings["ball_number"] ?? 0;
            team2crr = secondInnings["current_run_rate"].toDouble() ?? 0.0;
            team2runningOver = secondInnings["total_overs"] ?? "0.0";
          });
        } else {}
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> getExtras(
      BuildContext context, int contestId, int matchId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getExtras(context, contestId, matchId);
      if (response['statuscode'] == 200) {
        if (response['data'] != null) {
          Map<String, dynamic> data = response['data'];

          setState(() {
            // For team1 (first innings)
            if (data['first_innings'] is Map &&
                data['first_innings']['extras'] is Map) {
              team1extras =
                  data['first_innings']['extras']['extras_conceded'] ?? 0;
            } else {
              team1extras = 0;
            }

            // For team2 (second innings)
            if (data['second_innings'] is Map &&
                data['second_innings']['extras'] is Map) {
              team2extras =
                  data['second_innings']['extras']['extras_conceded'] ?? 0;
            } else {
              team2extras = 0;
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching extras: $e')),
      );
    }
  }

  Future<void> getFallOfWickets(
      BuildContext context, int contestId, int matchId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.getFallOfWickets(context, contestId, matchId);
      if (response['statuscode'] == 200 && response['data'] != null) {
        Map<String, dynamic> data = response['data'];

        List<Map<String, dynamic>> firstInningsWickets =
            List<Map<String, dynamic>>.from(
                data['first_innings']['wicket_falls']);
        List<Map<String, dynamic>> secondInningsWickets =
            List<Map<String, dynamic>>.from(
                data['second_innings']['wicket_falls']);

        List<String> tempFormattedTeam1Wickets = [];
        List<String> tempFormattedTeam2Wickets = [];
        Map<String, String> tempTeam1Dismissals = {};
        Map<String, String> tempTeam2Dismissals = {};

        for (int i = 0; i < firstInningsWickets.length; i++) {
          var w = firstInningsWickets[i];
          tempFormattedTeam1Wickets.add(
              '${i + 1}. ${w["batsman"]["name"]}    ${w["run_scored"]} (${w["over_number"]}.${w["ball_number"]} Ov)');
        }

        for (int i = 0; i < secondInningsWickets.length; i++) {
          var w = secondInningsWickets[i];
          tempFormattedTeam2Wickets.add(
              '${i + 1}. ${w["batsman"]["name"]}    ${w["run_scored"]} (${w["over_number"]}.${w["ball_number"]} Ov)');
        }

        for (var wicket in firstInningsWickets) {
          final batsman = wicket['batsman']['name'];
          final bowler = wicket['bowler']['name'];
          final dismissalType = wicket['dismissal'];
          final taker = wicket['fullname'] ?? bowler;

          String dismissal = '';
          if (dismissalType == 'caught') {
            dismissal = 'c $taker b $bowler';
          } else if (dismissalType == 'bowled') {
            dismissal = 'b $bowler';
          } else if (dismissalType == 'run out') {
            dismissal = 'run out ($taker)';
          } else {
            dismissal = dismissalType;
          }

          tempTeam1Dismissals[batsman] = dismissal;
        }

        for (var wicket in secondInningsWickets) {
          final batsman = wicket['batsman']['name'];
          final bowler = wicket['bowler']['name'];
          final dismissalType = wicket['dismissal'];
          final taker = wicket['fullname'] ?? bowler;

          String dismissal = '';
          if (dismissalType == 'caught') {
            dismissal = 'c $taker b $bowler';
          } else if (dismissalType == 'bowled') {
            dismissal = 'b $bowler';
          } else if (dismissalType == 'run out') {
            dismissal = 'run out ($taker)';
          } else {
            dismissal = dismissalType;
          }

          tempTeam2Dismissals[batsman] = dismissal;
        }

        setState(() {
          formattedTeam1Wickets = tempFormattedTeam1Wickets;
          formattedTeam2Wickets = tempFormattedTeam2Wickets;
          team1Dismissals = tempTeam1Dismissals;
          team2Dismissals = tempTeam2Dismissals;
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
        title: Text('$teamName1 vs $teamName2'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // this makes the TabBar scrollable
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Match Info'),
            Tab(text: 'Summary'),
            Tab(text: 'MVP'),
            Tab(text: 'Scorecard'),
            Tab(text: 'Commentary'),
            Tab(text: 'Live Stream'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Match Information Tab
          MatchInfoTab(
            matchInfo: {
              "Tournament": tournamentName.isEmpty
                  ? '$teamName1 vs $teamName2'
                  : tournamentName,
              "Round": roundType,
              "Match Type": matchType,
              "Overs": overNumber.toString(),
              "Date & Time": timeStamp,
              "Venue": "SVCC 2, Ahmedabad",
              "Toss": tossDeclaration,
              "Ball Type": ballType,
              "Pitch Type": pitchType,
            },
          ),

          // Match Summary Tab
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildScoreSection(
                  teamName1,
                  teamName2,
                  team1Score,
                  team1WicketLost,
                  team1overNumber,
                  team1ballNumber,
                  team2Score,
                  team2WicketLost,
                  team1runningOver,
                  team2runningOver,
                ),
                _buildPerformancesSection(bestPerformanceData),
              ],
            ),
          ),

          //MVP Tab
          MVPPage(mvpData: mvpData),

          // Full Scorecard Tab
          FullScorecardTab(
              teamName1: teamName1,
              teamName2: teamName2,
              team1Score: team1Score,
              team1WicketLost: team1WicketLost,
              team1overNumber: team1overNumber,
              team1ballNumber: team1ballNumber,
              team2Score: team2Score,
              team2WicketLost: team2WicketLost,
              team2overNumber: team2overNumber,
              team2ballNumber: team2ballNumber,
              team1BattingData: team1BattingData,
              team2BattingData: team2BattingData,
              team1extras: team1extras,
              team2extras: team2extras,
              team1crr: team1crr,
              team2crr: team2crr,
              formattedTeam1Wickets: formattedTeam1Wickets,
              formattedTeam2Wickets: formattedTeam2Wickets,
              team1Dismissals: team1Dismissals,
              team2Dismissals: team2Dismissals,
              team1runningOver: team1runningOver,
              team2runningOver: team2runningOver),

          // Commentary Tab
          CommentaryPage(
            contestId: widget.contestId,
            matchId: widget.matchId,
            team1Name: teamName1,
            team2Name: teamName2,
          ),

          //Live Streaming Tab
          LiveStreamingTab(
            contestId: widget.contestId,
            matchId: widget.matchId,
            team1Name: teamName1,
            team2Name: teamName2,
          ),
        ],
      ),
    );
  }
}

// ++ Match Info Tab ++
class MatchInfoTab extends StatelessWidget {
  final Map<String, String> matchInfo;

  const MatchInfoTab({super.key, required this.matchInfo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "INFO",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(thickness: 1),
              ...matchInfo.entries.map((entry) => MatchInfoRow(
                    label: entry.key,
                    value: entry.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class MatchInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const MatchInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
// -- Match Info Tab --

// ++ Match Summary Tab ++
Widget _buildScoreSection(
    String teamName1,
    String teamName2,
    int team1Score,
    int team1WicketLost,
    int team1overNumber,
    int team1ballNumber,
    int team2Score,
    int team2WicketLost,
    String team1runningOver,
    String team2runningOver) {
  return Card(
    margin: const EdgeInsets.all(4),
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          const Text(
            'Match Result',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTeamScore('$teamName1',
              '$team1Score/$team1WicketLost ($team1runningOver Ov)'),
          const SizedBox(height: 8),
          _buildTeamScore('$teamName2',
              '$team2Score/$team2WicketLost ($team2runningOver Ov)'),
          const SizedBox(height: 16),
          Text(
            compareScores(team1Score, team2Score, teamName1, teamName2),
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    ),
  );
}

String compareScores(
    int team1Score, int team2Score, String team1, String team2) {
  if (team1Score > team2Score) {
    return '$team1 won by ${team1Score - team2Score} runs';
  } else if (team2Score > team1Score) {
    return '$team2 won by ${team2Score - team1Score} runs';
  }
  return 'Scores tied at $team1Score';
}

Widget _buildTeamScore(String team, String score) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        team,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      Text(
        score,
        style: const TextStyle(fontSize: 16),
      ),
    ],
  );
}

Widget _buildPerformancesSection(bestPerformanceData) {
  return Card(
    margin: const EdgeInsets.all(2),
    child: Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        children: [
          const Text(
            'BEST PERFORMANCES',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Batting Performances
          if (bestPerformanceData.isNotEmpty &&
              bestPerformanceData['top_batsmen'] != null)
            _buildPerformanceTable(
              headers: ['Batsmen', 'R', 'B', '4s', '6s', 'S/R'],
              rows: bestPerformanceData['top_batsmen'].map<TableRow>((batsman) {
                return _buildBattingRow(
                  '${batsman['player_name']} (${batsman['team_name']})',
                  batsman['runs_scored'].toString(),
                  batsman['balls_faced'].toString(),
                  batsman['fours'].toString(),
                  batsman['sixes'].toString(),
                  batsman['strike_rate'].toStringAsFixed(2),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
          // Bowling Performances
          if (bestPerformanceData.isNotEmpty &&
              bestPerformanceData['top_bowlers'] != null)
            _buildPerformanceTable(
              headers: ['Bowlers', 'O', 'M', 'R', 'W', 'Eco'],
              rows: bestPerformanceData['top_bowlers'].map<TableRow>((bowler) {
                return _buildBowlingRow(
                  '${bowler['player_name']} (${bowler['team_name']})',
                  bowler['over_number'].toString(),
                  bowler['maiden'].toString(),
                  bowler['runs_conceded'].toString(),
                  bowler['wicket_taken'].toString(),
                  bowler['economy_rate'].toStringAsFixed(2),
                );
              }).toList(),
            ),
        ],
      ),
    ),
  );
}

Widget _buildPerformanceTable(
    {required List<String> headers, required List<TableRow> rows}) {
  return Table(
    // border: TableBorder.all(),
    columnWidths: const {
      0: FlexColumnWidth(2.5),
      1: FlexColumnWidth(0.8),
      2: FlexColumnWidth(0.8),
      3: FlexColumnWidth(0.8),
      4: FlexColumnWidth(0.8),
      5: FlexColumnWidth(1.5),
    },
    children: [
      TableRow(
        decoration: const BoxDecoration(
          color: Colors.blue, // Background color for header row
        ),
        children: headers
            .map((header) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    header,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ))
            .toList(),
      ),
      ...rows,
    ],
  );
}

TableRow _buildBattingRow(String name, String runs, String balls, String fours,
    String sixes, String strikeRate) {
  return TableRow(
    children: [
      _buildCell(name, isBold: true),
      _buildCell(runs, isBold: true),
      _buildCell(balls),
      _buildCell(fours),
      _buildCell(sixes),
      _buildCell(strikeRate),
    ],
  );
}

TableRow _buildBowlingRow(String name, String overs, String maidens,
    String runs, String wickets, String economy) {
  return TableRow(
    children: [
      _buildCell(name, isBold: true),
      _buildCell(overs, isBold: true),
      _buildCell(maidens),
      _buildCell(runs),
      _buildCell(wickets, isBold: true),
      _buildCell(economy),
    ],
  );
}

Widget _buildCell(String text, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Text(
      text,
      style:
          TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
      textAlign: TextAlign.center,
    ),
  );
}
// -- Match Summary Tab --

// ++ Full Scorecard Tab ++
class FullScorecardTab extends StatefulWidget {
  final String teamName1;
  final String teamName2;
  final int team1Score;
  final int team1WicketLost;
  final int team1overNumber;
  final int team1ballNumber;
  final int team2Score;
  final int team2WicketLost;
  final int team2overNumber;
  final int team2ballNumber;
  final List<Map<String, dynamic>> team1BattingData;
  final List<Map<String, dynamic>> team2BattingData;
  final int team1extras;
  final int team2extras;
  final double team1crr;
  final double team2crr;
  final List<String> formattedTeam1Wickets;
  final List<String> formattedTeam2Wickets;
  final Map<String, String> team1Dismissals;
  final Map<String, String> team2Dismissals;
  final String team1runningOver;
  final String team2runningOver;

  const FullScorecardTab({
    super.key,
    required this.teamName1,
    required this.teamName2,
    required this.team1Score,
    required this.team1WicketLost,
    required this.team1overNumber,
    required this.team1ballNumber,
    required this.team2Score,
    required this.team2WicketLost,
    required this.team2overNumber,
    required this.team2ballNumber,
    required this.team1BattingData,
    required this.team2BattingData,
    required this.team1extras,
    required this.team2extras,
    required this.team1crr,
    required this.team2crr,
    required this.formattedTeam1Wickets,
    required this.formattedTeam2Wickets,
    required this.team1Dismissals,
    required this.team2Dismissals,
    required this.team1runningOver,
    required this.team2runningOver,
  });

  @override
  State<FullScorecardTab> createState() => _FullScorecardTabState();
}

class _FullScorecardTabState extends State<FullScorecardTab> {
  bool _isTeam1Expanded = true;
  bool _isTeam2Expanded = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Match Result
          Text(
            ' ' +
                compareScores(widget.team1Score, widget.team2Score,
                    widget.teamName1, widget.teamName2),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),

          // Team 1 Section
          _buildTeamSection(
            teamName: widget.teamName1,
            score: '${widget.team1Score}/${widget.team1WicketLost}',
            overs: '${widget.team1runningOver}',
            isExpanded: _isTeam1Expanded,
            onTap: () => setState(() => _isTeam1Expanded = !_isTeam1Expanded),
            children: [
              BattingTable(
                  battingData: widget.team1BattingData,
                  dismissals: widget.team1Dismissals),
              const SizedBox(height: 20),
              _buildTotalScore(
                  '${widget.team1extras}',
                  '${widget.team1Score}/${widget.team1WicketLost}',
                  '${widget.team1runningOver}',
                  '${widget.team1crr}'),
              const SizedBox(height: 10),
              _buildFallOfWickets(widget.formattedTeam1Wickets),
            ],
          ),

          const SizedBox(height: 20),

          // Team 2 Section
          _buildTeamSection(
            teamName: widget.teamName2,
            score: '${widget.team2Score}/${widget.team2WicketLost}',
            overs: '${widget.team2runningOver}',
            isExpanded: _isTeam2Expanded,
            onTap: () => setState(() => _isTeam2Expanded = !_isTeam2Expanded),
            children: [
              BattingTable(
                  battingData: widget.team2BattingData,
                  dismissals: widget.team2Dismissals),
              const SizedBox(height: 20),
              _buildTotalScore(
                  '${widget.team2extras}',
                  '${widget.team2Score}/${widget.team2WicketLost}',
                  '${widget.team2runningOver}',
                  '${widget.team2crr}'),
              const SizedBox(height: 10),
              _buildFallOfWickets(widget.formattedTeam2Wickets),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection({
    required String teamName,
    String? score,
    String? overs,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: score != null && overs != null
                ? Row(
                    children: [
                      Text(
                        teamName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(), // This will push the score to the right
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(text: score),
                            WidgetSpan(
                              child: Transform.translate(
                                offset: const Offset(
                                    0, 0), // Slight vertical adjustment
                                child: Text(
                                  ' ($overs Ov)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Text(
                    teamName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: onTap,
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTotalScore(
      String extra, String score, String overs, String crr) {
    return Column(
      children: [
        ColoredBox(
          color: Colors.blue!,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Text(
                  'Extras',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(extra.toString()),
              ],
            ),
          ),
        ),
        ColoredBox(
          color: Colors.blue!,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text('$score', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('($overs Ov)', style: const TextStyle(fontSize: 12)),
                const Text('   '),
                Text('CRR ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(crr.toString()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallOfWickets(List<String> formattedWickets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ColoredBox(
          color: Colors.blue!,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: const [
                Text('Fall of Wickets',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                Spacer(),
                Text('Score(over)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ),
        for (String line in formattedWickets) _buildWicketRow(line),
      ],
    );
  }

  Widget _buildWicketRow(String formattedLine) {
    final parts = formattedLine.split(RegExp(r'\s{2,}'));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(parts[0], style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(parts.length > 1 ? parts[1] : ''),
        ],
      ),
    );
  }
}

class BattingTable extends StatelessWidget {
  final List<Map<String, dynamic>> battingData;
  final Map<String, String> dismissals;

  const BattingTable({
    super.key,
    required this.battingData,
    required this.dismissals,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      // border: TableBorder.all(),
      columnWidths: const {
        0: FlexColumnWidth(2.5), // Wider for batsmen names
        1: FlexColumnWidth(0.8),
        2: FlexColumnWidth(0.8),
        3: FlexColumnWidth(0.8),
        4: FlexColumnWidth(0.8),
        5: FlexColumnWidth(1.5),
      },
      children: [
        // Header Row
        const TableRow(
          decoration: BoxDecoration(color: Colors.blue),
          children: [
            Center(child: _TableHeaderCell('Batsmen')),
            Center(child: _TableHeaderCell('R')),
            Center(child: _TableHeaderCell('B')),
            Center(child: _TableHeaderCell('4s')),
            Center(child: _TableHeaderCell('6s')),
            Center(child: _TableHeaderCell('SR')),
          ],
        ),
        // Data Rows
        ...battingData.map((batsman) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        batsman['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        dismissals[batsman['name']] ??
                            'not out', // Handle null case
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _TableDataCell(batsman['runs'].toString()),
                _TableDataCell(batsman['balls'].toString()),
                _TableDataCell(batsman['fours'].toString()),
                _TableDataCell(batsman['sixes'].toString()),
                _TableDataCell(batsman['strikeRate'].toString()),
              ],
            )),
      ],
    );
  }
}

// Reusable header cell widget
class _TableHeaderCell extends StatelessWidget {
  final String text;

  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

// Reusable data cell widget
class _TableDataCell extends StatelessWidget {
  final String text;

  const _TableDataCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
// -- Full Scorecard Tab --
