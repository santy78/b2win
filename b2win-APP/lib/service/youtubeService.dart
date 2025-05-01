import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart' as yt;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';

class YouTubeService {
  final AuthClient _authClient;
  final yt.YouTubeApi _youtubeApi;

  YouTubeService(AuthClient authClient)
      : _authClient = authClient,
        _youtubeApi = yt.YouTubeApi(authClient);

  Future<Map<String, String>> createLiveStream({
    required String title,
    required String description,
  }) async {
    final now = DateTime.now();
    final startTime = now.add(const Duration(minutes: 1));
    final endTime = startTime.add(const Duration(hours: 2));

    // Create broadcast
    final broadcast = yt.LiveBroadcast()
      ..snippet = (yt.LiveBroadcastSnippet()
        ..title = title
        ..description = description
        ..scheduledStartTime = startTime
        ..scheduledEndTime = endTime)
      ..status = (yt.LiveBroadcastStatus()..privacyStatus = 'public')
      ..kind = 'youtube#liveBroadcast';

    final insertedBroadcast = await _youtubeApi.liveBroadcasts.insert(
      broadcast,
      ['snippet', 'status', 'contentDetails'],
    );

    // Create stream
    final stream = yt.LiveStream()
      ..snippet = (yt.LiveStreamSnippet()..title = 'Mobile Stream')
      ..cdn = (yt.CdnSettings()
        ..format = '1080p'
        ..ingestionType = 'rtmp');

    final insertedStream = await _youtubeApi.liveStreams.insert(
      stream,
      ['snippet', 'cdn'],
    );

    // Bind broadcast to stream
    await _youtubeApi.liveBroadcasts.bind(
      insertedBroadcast.id!,
      ['id', 'snippet'],
      streamId: insertedStream.id!,
    );

    return {
      'streamId': insertedStream.id!,
      'rtmpUrl':
          '${insertedStream.cdn?.ingestionInfo?.ingestionAddress}/${insertedStream.cdn?.ingestionInfo?.streamName}',
      'streamKey': insertedStream.cdn?.ingestionInfo?.streamName ?? '',
      'broadcastId': insertedBroadcast.id!,
      'streamUrl': 'https://youtube.com/watch?v=${insertedBroadcast.id}',
    };
  }

  Future<void> endStream(String broadcastId) async {
    try {
      await _youtubeApi.liveBroadcasts.transition(
        broadcastId,
        'complete',
        ['status'],
      );
    } catch (e) {
      debugPrint('Error ending stream: $e');
      throw Exception('Failed to end stream: $e');
    }
  }

  void dispose() {
    _authClient.close();
  }
}
