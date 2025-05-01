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
  bool isLoading = true;
  bool hasError = false;
  Timer? _refreshTimer;
  bool _expandTeam1 = true;
  bool _expandTeam2 = true;

  @override
  void initState() {
    super.initState();
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
      if (mounted) _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      await Future.wait([
        _fetchInningCommentary(1),
        _fetchInningCommentary(2),
      ]);
    } catch (e) {
      setState(() => hasError = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchInningCommentary(int inningNo) async {
    try {
      final response = await ApiService.getBallingScore(
        context,
        widget.contestId,
        widget.matchId,
        inningNo,
        0,
        20,
      );

      if (response['statuscode'] == 200 && response['data'] != null) {
        List<dynamic> filteredBalls = [];
        Map<String, dynamic> overs = response['data']['overs'];

        overs.forEach((overNumber, balls) {
          for (var ball in balls) {
            if ((ball['commentary'] ?? '').trim().isNotEmpty) {
              filteredBalls.add({
                'commentary': ball['commentary'],
                'is_four': ball['is_four'] ?? false,
                'is_six': ball['is_six'] ?? false,
                'is_wicket': (ball['dismissal'] ?? '').isNotEmpty,
              });
            }
          }
        });

        setState(() {
          if (inningNo == 1) {
            team1Commentary = filteredBalls.reversed.toList();
          } else {
            team2Commentary = filteredBalls.reversed.toList();
          }
        });
      }
    } catch (e) {
      print('Error fetching inning $inningNo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && team1Commentary.isEmpty && team2Commentary.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError && team1Commentary.isEmpty && team2Commentary.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text('Failed to load commentary'),
            TextButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            // Team 1 Commentary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  childrenPadding: const EdgeInsets.all(0),
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.team1Name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  initiallyExpanded: _expandTeam1,
                  onExpansionChanged: (expanded) {
                    setState(() => _expandTeam1 = expanded);
                  },
                  children: [
                    if (team1Commentary.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No commentary available'),
                      )
                    else
                      SizedBox(
                        height: 330,
                        child: _buildCommentaryList(
                          team1Commentary,
                          Colors.blue[100]!,
                          Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Team 2 Commentary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  childrenPadding: const EdgeInsets.all(0),
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.team2Name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  initiallyExpanded: _expandTeam2,
                  onExpansionChanged: (expanded) {
                    setState(() => _expandTeam2 = expanded);
                  },
                  children: [
                    if (team2Commentary.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No commentary available'),
                      )
                    else
                      SizedBox(
                        height: 330,
                        child: _buildCommentaryList(
                          team2Commentary,
                          Colors.blue[100]!,
                          Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentaryList(
      List<dynamic> commentary, Color color1, Color color2) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: commentary.length,
      itemBuilder: (context, index) {
        final ball = commentary[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: index.isEven ? color1 : color2,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ball['is_four'])
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: const Text(
                    'FOUR!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              if (ball['is_six'])
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: const Text(
                    'SIX!',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              if (ball['is_wicket'])
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: const Text(
                    'OUT!',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              Text(
                ball['commentary'],
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}
