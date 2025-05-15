import 'package:b2winai/scoreBoard/scoreBoardView/viewMode/YouTubeLiveStreamPage.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/viewMode/YouTubePlayerPage.dart';
import 'package:b2winai/scoreBoard/scoreBoardView/viewMode/liveStreamPage.dart';
import 'package:b2winai/service/AuthService.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

enum StreamStatus { notStarted, active, paused }

class StreamManagerPage extends StatefulWidget {
  final int contestId;
  final int matchId;
  final String team1Name;
  final String team2Name;

  const StreamManagerPage({
    required this.contestId,
    required this.matchId,
    required this.team1Name,
    required this.team2Name,
    super.key,
  });

  @override
  State<StreamManagerPage> createState() => _StreamManagerPageState();
}

class _StreamManagerPageState extends State<StreamManagerPage> {
  StreamStatus _streamStatus = StreamStatus.notStarted;
  String currentUserRole = "";
  String streamTitle = "";
  String streamKey = "";
  String ytWatchURL = "";
  String teamName1 = "";
  String teamName2 = "";

  @override
  void initState() {
    super.initState();

    _loadSessionData();
  }

  Future<void> _loadSessionData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final sessionData = await AuthService.getSessionData();
      setState(() {
        currentUserRole = sessionData['role'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading session data: $e')),
      );
    }
  }

  Future<void> createStreamEvent(BuildContext context) async {
    try {
      setState(() {
        if (widget.team1Name != null && widget.team1Name != "") {
          teamName1 = widget.team1Name;
        } else {
          teamName1 = "Team A";
        }
        if (widget.team2Name != null && widget.team2Name != "") {
          teamName2 = widget.team2Name;
        } else {
          teamName2 = "Team B";
        }
        streamTitle = "$teamName1 vs $teamName2";
      });
      print(streamTitle);
      print(widget.matchId);
      final response = await ApiService.createStreamEvent(
          context, streamTitle, widget.matchId);

      // Show response message instead of data map
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Stream created')),
      );

      // Safely handle response
      if (response['statuscode'] == 200 && response['data'] != null) {
        setState(() {
          int eventId =
              int.tryParse(response['data']['event_id'].toString()) ?? 0;
          if (eventId > 0) {
            getRmtpStreamUrl(context, eventId);
            getYtStreamUrl(context, eventId);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Create Event Error: $e')),
      );
    }
  }

  Future<void> getRmtpStreamUrl(BuildContext context, int eventId) async {
    try {
      final response = await ApiService.getRmtpStreamUrl(context, eventId);
      if (response['statuscode'] == 200 && response['data'] != null) {
        setState(() {
          String rtmpURL = response['data']['youtube_watch_url'];
          streamKey = rtmpURL.split('/').last;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting RTMP URL: $e')),
      );
    }
  }

  Future<void> getYtStreamUrl(BuildContext context, int eventId) async {
    try {
      final response = await ApiService.getYtStreamUrl(context, eventId);
      if (response['statuscode'] == 200 && response['data'] != null) {
        setState(() {
          ytWatchURL = response['data']['youtube_watch_url'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting YT Watch URL: $e')),
      );
    }
  }

  void _setupStream() {
    createStreamEvent(context);
    setState(() {
      _streamStatus = StreamStatus.active;
    });
  }

  void _pauseStream() {
    setState(() {
      _streamStatus = StreamStatus.paused;
    });
  }

  void _resumeStream() {
    setState(() {
      _streamStatus = StreamStatus.active;
    });
  }

  void _goToStream() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => YouTubeLiveStreamPage(
                  streamKey: streamKey,
                )));
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => LiveStreamPage()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to stream page')),
    );
  }

  void _viewStream() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => YouTubePlayerPage(
                ytUrl: ytWatchURL,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Button 1 - Setup Stream or Go to Stream
          ElevatedButton(
            onPressed: _streamStatus == StreamStatus.notStarted
                ? _setupStream
                : _goToStream,
            style: ElevatedButton.styleFrom(
              backgroundColor: _streamStatus == StreamStatus.notStarted
                  ? Colors.blue
                  : Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              _streamStatus == StreamStatus.notStarted
                  ? 'Setup Stream'
                  : 'Go to Stream Page',
              style: const TextStyle(fontSize: 16),
            ),
          ),

          const SizedBox(height: 16),

          // Button 2 - Resume Stream (only shown when paused)
          if (_streamStatus == StreamStatus.paused)
            ElevatedButton(
              onPressed: _resumeStream,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Resume Stream',
                style: TextStyle(fontSize: 16),
              ),
            ),

          if (_streamStatus == StreamStatus.paused) const SizedBox(height: 16),

          // Button 3 - View Stream (shown when stream exists)
          if (_streamStatus != StreamStatus.notStarted)
            ElevatedButton(
              onPressed: _viewStream,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'View Stream',
                style: TextStyle(fontSize: 16),
              ),
            ),

          const SizedBox(height: 24),

          // Status display
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _streamStatus.toString().split('.').last,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
