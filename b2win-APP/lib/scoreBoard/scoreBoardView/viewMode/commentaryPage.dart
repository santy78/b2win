import 'dart:async';
import 'package:flutter/material.dart';
import 'package:b2winai/service/apiService.dart';

class CommentaryPage extends StatefulWidget {
  final int contestId;
  final int matchId;
  final String team1Name;
  final String team2Name;

  const CommentaryPage({
    Key? key,
    required this.contestId,
    required this.matchId,
    required this.team1Name,
    required this.team2Name,
  }) : super(key: key);

  @override
  _CommentaryPageState createState() => _CommentaryPageState();
}

class _CommentaryPageState extends State<CommentaryPage> {
  List<dynamic> team1Commentary = [];
  List<dynamic> team2Commentary = [];
  String? selectedTeam;
  bool isLoading = true;
  bool hasError = false;
  int team1Score = 0;
  int team1WicketLost = 0;
  String team1runningOver = "0.0";
  int team2Score = 0;
  int team2WicketLost = 0;
  String team2runningOver = "0.0";
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    selectedTeam = widget.team1Name;
    _loadData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });
      await Future.wait([
        fetchCommentary(),
        getScore(context, widget.contestId, widget.matchId),
      ]);
    } catch (e) {
      setState(() {
        hasError = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchCommentary() async {
    final response = await ApiService.getCommentary(
      context,
      widget.contestId,
      widget.matchId,
    );

    if (response['statuscode'] == 200 && response['data'] != null) {
      setState(() {
        team1Commentary = response['data']['first_innings'] ?? [];
        team2Commentary = response['data']['second_innings'] ?? [];
      });
    }
  }

  Future<void> getScore(
      BuildContext context, int contestId, int matchId) async {
    final response = await ApiService.getScore(context, contestId, matchId);
    if (response['statuscode'] == 200 && response['data'] != null) {
      final data = response['data'];
      setState(() {
        team1Score = data['first_innings']["runs_scored"] ?? 0;
        team1WicketLost = data['first_innings']["wickets_lost"] ?? 0;
        team1runningOver = data['first_innings']["total_overs"] ?? "0.0";
        team2Score = data['second_innings']["runs_scored"] ?? 0;
        team2WicketLost = data['second_innings']["wickets_lost"] ?? 0;
        team2runningOver = data['second_innings']["total_overs"] ?? "0.0";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && team1Commentary.isEmpty && team2Commentary.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading match commentary...'),
          ],
        ),
      );
    }

    if (hasError && team1Commentary.isEmpty && team2Commentary.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to load commentary',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with team selector and score
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              // Team dropdown
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton<String>(
                    value: selectedTeam,
                    isExpanded: true,
                    underline: Container(),
                    icon: const Icon(Icons.arrow_drop_down, size: 24),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    items: [
                      _buildDropdownItem(widget.team1Name),
                      _buildDropdownItem(widget.team2Name),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTeam = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Score display
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Text(
                  _getCurrentScore(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Current over summary
        _buildCurrentOverSummary(),
        // Commentary list with pull-to-refresh
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: _buildCommentaryList(),
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String teamName) {
    return DropdownMenuItem(
      value: teamName,
      child: Row(
        children: [
          Icon(Icons.sports_cricket, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            teamName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _getCurrentScore() {
    if (selectedTeam == widget.team1Name) {
      return '$team1Score/$team1WicketLost ($team1runningOver Ov)';
    } else {
      return '$team2Score/$team2WicketLost ($team2runningOver Ov)';
    }
  }

  Widget _buildCurrentOverSummary() {
    final currentCommentary =
        selectedTeam == widget.team1Name ? team1Commentary : team2Commentary;

    if (currentCommentary.isEmpty) return Container();

    final latestOver = currentCommentary.first;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'End of over: ${latestOver['over_number']} | '
            '${latestOver['runs_in_over']} Runs ${latestOver['wickets_in_over']} Wkt',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${latestOver['batsman1_name']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${latestOver['batsman1_runs']} (${latestOver['batsman1_balls']}b)',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${latestOver['batsman2_name']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${latestOver['batsman2_runs']} (${latestOver['batsman2_balls']}b)',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${latestOver['bowler1_name']} ${latestOver['bowler1_overs']}-${latestOver['bowler1_maidens']}-${latestOver['bowler1_runs']}-${latestOver['bowler1_wickets']}',
                style: TextStyle(fontSize: 13, color: Colors.grey[800]),
              ),
              if (latestOver['bowler2_name'] != null)
                Text(
                  '${latestOver['bowler2_name']} ${latestOver['bowler2_overs']}-${latestOver['bowler2_maidens']}-${latestOver['bowler2_runs']}-${latestOver['bowler2_wickets']}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentaryList() {
    final currentCommentary =
        selectedTeam == widget.team1Name ? team1Commentary : team2Commentary;

    if (currentCommentary.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.comment, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No commentary available yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            TextButton(
              onPressed: _loadData,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      reverse: true,
      itemCount: currentCommentary.length,
      itemBuilder: (context, index) {
        final over = currentCommentary[index];
        return Card(
          margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Over ${over['over_number']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${over['runs_in_over']} runs, ${over['wickets_in_over']} wkts',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...over['balls'].map<Widget>((ball) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${ball['ball_number']}.${ball['ball_in_over']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ball['commentary_text'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
