import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

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
  int team2Score = 0;
  int team2WicketLost = 0;
  int team2overNumber = 0;
  int team2ballNumber = 0;
  int team2extras = 0;
  double team2crr = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    getScoreBoard(context, widget.contestId, widget.matchId);
    getScore(context, widget.contestId, widget.matchId);
    getExtras(context, widget.contestId, widget.matchId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            'dismissal':
                player['dismissal'].isEmpty ? 'not out' : player['dismissal'],
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
            'dismissal':
                player['dismissal'].isEmpty ? 'not out' : player['dismissal'],
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
            //team2 details
            team2Score = secondInnings["runs_scored"] ?? 0;
            team2WicketLost = secondInnings["wickets_lost"] ?? 0;
            team2overNumber = secondInnings["over_number"] ?? 0;
            team2ballNumber = secondInnings["ball_number"] ?? 0;
            team2crr = firstInnings["current_run_rate"].toDouble() ?? 0.0;
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
            Map<String, dynamic> firstInnings = data['first_innings'];
            Map<String, dynamic> secondInnings = data['second_innings'];

            //team1 details
            team1extras = firstInnings["extras"] ?? 0;
            //team2 details
            team2extras = secondInnings["extras"] ?? 0;
          });
        } else {}
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
            Tab(text: 'Scorecard'),
            Tab(text: 'Commentary'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Match Information Tab
          MatchInfoTab(
            matchInfo: {
              "Tournament": "SVCC 2019",
              "Round": "League Matches",
              "Match Type": "Limited Overs",
              "Overs": "8",
              "Date & Time": "13-Jul-19 05:57 pm",
              "Venue": "SVCC 2, Ahmedabad",
              "Toss": "SVCC Lions won the toss and elected to bat",
              "Ball Type": "TENNIS",
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
                  team2overNumber,
                  team2ballNumber,
                ),
                _buildPerformancesSection(), // yet to be done need to speak with Suman Da
              ],
            ),
          ),

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
          ),

          // Commentary Tab
          Center(
            child: Text(
              'Live Commentary',
              style: TextStyle(fontSize: 18),
            ),
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
    int team2overNumber,
    int team2ballNumber) {
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
              '$team1Score/$team1WicketLost ($team1overNumber.$team1ballNumber Ov)'),
          const SizedBox(height: 8),
          _buildTeamScore('$teamName2',
              '$team2Score/$team2WicketLost ($team2overNumber.$team2ballNumber Ov)'),
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
    return '$team1 is winning by ${team1Score - team2Score} runs';
  } else if (team2Score > team1Score) {
    return '$team2 is winning by ${team2Score - team1Score} runs';
  }
  return 'Scores are tied at $team1Score';
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

Widget _buildPerformancesSection() {
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
          _buildPerformanceTable(
            headers: ['Batsmen', 'R', 'B', 'As', 'Gs', 'S/R'],
            rows: [
              _buildBattingRow('Abhishek Desai SPCC (Jones)', '35', '22', '3',
                  '0', '159.09'),
              _buildBattingRow(
                  'Vivek Desai SPCC (Tigers)', '30', '22', '3', '0', '136.36'),
              _buildBattingRow(
                  'Jailev Desai SPCC (Jones)', '18', '19', '1', '0', '94.74'),
            ],
          ),
          const SizedBox(height: 16),
          // Bowling Performances
          _buildPerformanceTable(
            headers: ['Bowlers', 'O', 'M', 'R', 'W', 'Eco'],
            rows: [
              _buildBowlingRow(
                  'Vivek Desai SPCC (Tigers)', '2.5', '0', '26', '3', '9.18'),
              _buildBowlingRow(
                  'Pranav Patel SPCC (Tigers)', '3.0', '0', '14', '2', '4.67'),
              _buildBowlingRow(
                  'Chintan Sheth SPCC (Jones)', '3.0', '0', '19', '2', '6.33'),
            ],
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
            overs: '${widget.team1overNumber}.${widget.team1ballNumber}',
            isExpanded: _isTeam1Expanded,
            onTap: () => setState(() => _isTeam1Expanded = !_isTeam1Expanded),
            children: [
              BattingTable(battingData: widget.team1BattingData),
              const SizedBox(height: 20),
              _buildTotalScore(
                  '${widget.team1extras}',
                  '${widget.team1Score}/${widget.team1WicketLost}',
                  '${widget.team1overNumber}.${widget.team1ballNumber}',
                  '${widget.team1crr}'),
              const SizedBox(height: 10),
              _buildFallOfWickets(),
            ],
          ),

          const SizedBox(height: 20),

          // Team 2 Section
          _buildTeamSection(
            teamName: widget.teamName2,
            score: '${widget.team2Score}/${widget.team2WicketLost}',
            overs: '${widget.team2overNumber}.${widget.team2ballNumber}',
            isExpanded: _isTeam2Expanded,
            onTap: () => setState(() => _isTeam2Expanded = !_isTeam2Expanded),
            children: [
              BattingTable(battingData: widget.team2BattingData),
              const SizedBox(height: 20),
              _buildTotalScore(
                  '${widget.team2extras}',
                  '${widget.team2Score}/${widget.team2WicketLost}',
                  '${widget.team2overNumber}.${widget.team2ballNumber}',
                  '${widget.team2crr}'),
              const SizedBox(height: 10),
              _buildFallOfWickets(),
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

  Widget _buildFallOfWickets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ColoredBox(
          color: Colors.blue!,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
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
        _buildWicket('1. Neel Patel', '5 (0.4 Ov)'),
        _buildWicket('2. Pranav Patel', '31 (4.4 Ov)'),
      ],
    );
  }

  Widget _buildWicket(String player, String details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(player, style: const TextStyle(fontWeight: FontWeight.bold)),
          Spacer(),
          Text(details),
        ],
      ),
    );
  }
}

class BattingTable extends StatelessWidget {
  final List<Map<String, dynamic>> battingData;

  const BattingTable({super.key, required this.battingData});

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
                        batsman['dismissal'] ?? 'not out', // Handle null case
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
