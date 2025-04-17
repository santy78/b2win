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

  List<dynamic> firstInningsbatting = [];
  List<dynamic> firstInningsBowling = [];
  List<dynamic> secondInningsbatting = [];
  List<dynamic> secondInningsBowling = [];

  int teamId1 = 0;
  int teamId2 = 0;
  String teamName1 = "";
  String teamName2 = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    getScoreBoard(context, widget.contestId, widget.matchId);
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
        List<dynamic> firstInnings_Batting = firstInnings['batting'];
        List<dynamic> firstInnings_Bowling = firstInnings['bowling'];
        List<dynamic> secondInnings_Batting = secondInnings['batting'];
        List<dynamic> secondInnings_Bowling = secondInnings['bowling'];

        setState(() {
          firstInningsbatting = firstInnings_Batting;
          firstInningsBowling = firstInnings_Bowling;
          secondInningsbatting = secondInnings_Batting;
          secondInningsBowling = secondInnings_Bowling;
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
                _buildScoreSection(),
                _buildPerformancesSection(),
              ],
            ),
          ),

          // Full Scorecard Tab
          const FullScorecardTab(),

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
Widget _buildScoreSection() {
  return Card(
    margin: const EdgeInsets.all(16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Match Result',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTeamScore('SVCC Lions', '56/5 (7.5 Ov)'),
          const SizedBox(height: 8),
          _buildTeamScore('SVCC Tigers', '49/4 (8.0 Ov)'),
          const SizedBox(height: 16),
          const Text(
            'SVCC Lions won by 7 runs',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    ),
  );
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
    margin: const EdgeInsets.all(16),
    child: Padding(
      padding: const EdgeInsets.all(16),
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
    border: TableBorder.all(),
    columnWidths: const {
      0: FlexColumnWidth(2),
      1: FlexColumnWidth(1),
      2: FlexColumnWidth(1),
      3: FlexColumnWidth(1),
      4: FlexColumnWidth(1),
      5: FlexColumnWidth(1),
    },
    children: [
      TableRow(
        children: headers
            .map((header) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    header,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
  const FullScorecardTab({super.key});

  @override
  State<FullScorecardTab> createState() => _FullScorecardTabState();
}

class _FullScorecardTabState extends State<FullScorecardTab> {
  bool _isTeam1Expanded = true;
  bool _isTeam2Expanded = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Match Result
          const Text(
            'MAVERICKS won by 7 runs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),

          // Team 1 Section
          _buildTeamSection(
            teamName: 'MAVERICKS',
            score: '56/5',
            overs: '7.5',
            isExpanded: _isTeam1Expanded,
            onTap: () => setState(() => _isTeam1Expanded = !_isTeam1Expanded),
            children: [
              BattingTable(
                battingData: [
                  {
                    'name': 'Vivek',
                    'dismissal': 'c Anuj b Dinesh',
                    'runs': 30,
                    'balls': 22,
                    'fours': 3,
                    'sixes': 0,
                    'strikeRate': 196.36,
                  },
                  {
                    'name': 'Neel',
                    'dismissal': 'b Dinesh',
                    'runs': 4,
                    'balls': 3,
                    'fours': 0,
                    'sixes': 0,
                    'strikeRate': 133.33,
                  },
                  {
                    'name': 'Pranav',
                    'dismissal': 'not out',
                    'runs': 8,
                    'balls': 12,
                    'fours': 0,
                    'sixes': 0,
                    'strikeRate': 66.67,
                  },
                ],
              ),
              const SizedBox(height: 20),
              _buildTotalScore('0', '56/5', '7.5', '6.13'),
              const SizedBox(height: 10),
              _buildFallOfWickets(),
            ],
          ),

          const SizedBox(height: 20),

          // Team 2 Section
          _buildTeamSection(
            teamName: 'DEVILS',
            score: '49/4',
            overs: '8.0',
            isExpanded: _isTeam2Expanded,
            onTap: () => setState(() => _isTeam2Expanded = !_isTeam2Expanded),
            children: [
              BattingTable(
                battingData: [
                  {
                    'name': 'Vivek',
                    'dismissal': 'c Anuj b Dinesh',
                    'runs': 30,
                    'balls': 22,
                    'fours': 3,
                    'sixes': 0,
                    'strikeRate': 196.36,
                  },
                  {
                    'name': 'Neel',
                    'dismissal': 'b Dinesh',
                    'runs': 4,
                    'balls': 3,
                    'fours': 0,
                    'sixes': 0,
                    'strikeRate': 133.33,
                  },
                  {
                    'name': 'Pranav',
                    'dismissal': 'not out',
                    'runs': 8,
                    'balls': 12,
                    'fours': 0,
                    'sixes': 0,
                    'strikeRate': 66.67,
                  },
                ],
              ),
              const SizedBox(height: 20),
              _buildTotalScore('0', '49/4', '8.0', '6.13'),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeekDetailSection() {
    return Column(
      children: [
        const Text(
          'Week Detail (c)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('C.Peramolo Dezalba Street Shash'),
        const SizedBox(height: 10),
        _buildPlayerPerformance('Week Detail', '4', '3', '0', '0', '133.33'),
        const Text('B-Chelsea Shash'),
        const SizedBox(height: 10),
        _buildPlayerPerformance('Primary Patel', '8', '12', '0', '0', '66.67'),
        const Text('C.Bolio Capital & Chelsea Shash'),
        const SizedBox(height: 10),
        const Text('Estras | 0 |'),
      ],
    );
  }

  Widget _buildPlayerPerformance(
      String name, String r, String b, String fours, String sixes, String sr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name),
        Text('| $r   $b   $fours   $sixes   $sr |'),
      ],
    );
  }

  Widget _buildTotalScore(
      String extra, String score, String overs, String crr) {
    return Column(
      children: [
        ColoredBox(
          color: Colors.grey!,
          child: Padding(
            padding: const EdgeInsets.all(8),
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
          color: Colors.grey!,
          child: Padding(
            padding: const EdgeInsets.all(8),
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
          color: Colors.grey!,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Text('Fall of Wickets',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text('Score(over)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
      border: TableBorder.all(),
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
          decoration: BoxDecoration(color: Colors.grey),
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
                  padding: const EdgeInsets.all(4),
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
