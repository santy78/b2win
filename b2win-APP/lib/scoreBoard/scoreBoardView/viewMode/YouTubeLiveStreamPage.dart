import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:apivideo_live_stream/apivideo_live_stream.dart';

class YouTubeLiveStreamPage extends StatefulWidget {
  final String streamKey;

  const YouTubeLiveStreamPage({
    required this.streamKey,
    Key? key,
  }) : super(key: key);

  @override
  _YouTubeLiveStreamPageState createState() => _YouTubeLiveStreamPageState();
}

class _YouTubeLiveStreamPageState extends State<YouTubeLiveStreamPage>
    with WidgetsBindingObserver {
  late ApiVideoLiveStreamController _controller;
  bool _isStreaming = false;
  bool _isMicOn = true;
  bool _isCameraInitialized = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();

      if (!cameraStatus.isGranted || !micStatus.isGranted) {
        throw Exception('Camera and microphone permissions are required');
      }

      _controller = ApiVideoLiveStreamController(
        initialAudioConfig: AudioConfig(),
        initialVideoConfig: VideoConfig(
          resolution: Resolution.RESOLUTION_720,
          bitrate: 3000000,
          fps: 30,
        ),
      );

      await _controller.initialize();

      setState(() {
        _isCameraInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      _showErrorSnackbar('Failed to initialize camera: $e');
    }
  }

  Future<void> _startStreaming() async {
    if (!await _checkPermissions()) {
      _showErrorSnackbar('Camera/Mic permissions not granted');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      //const String streamKey = "k9w0-xzc0-awz5-fzbw-f0x5";
      const String rtmpUrl = "rtmp://x.rtmp.youtube.com/live2";
      await _controller.startStreaming(
        streamKey: widget.streamKey,
        url: rtmpUrl,
      );

      if (!mounted) return;
      setState(() {
        _isStreaming = true;
        _isLoading = false;
      });

      _showErrorSnackbar('Stream started successfully!', isError: false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Failed to start stream: $e');
    }
  }

  Future<void> _stopStreaming() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _controller.stopStreaming();

      if (!mounted) return;
      setState(() {
        _isStreaming = false;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Failed to stop stream: $e');
    }
  }

  void _showErrorSnackbar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<bool> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;
    return cameraStatus.isGranted && micStatus.isGranted;
  }

  Future<void> _switchCamera() async {
    if (!_isCameraInitialized || _isLoading) return;

    try {
      setState(() {
        _isLoading = true;
      });
      await _controller.switchCamera();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Failed to switch camera: $e');
    }
  }

  Future<void> _toggleMicrophone() async {
    if (!_isCameraInitialized || _isLoading) return;

    try {
      setState(() {
        _isLoading = true;
      });
      await _controller.toggleMute();
      if (!mounted) return;
      setState(() {
        _isMicOn = !_isMicOn;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Failed to toggle microphone: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isCameraInitialized)
          ApiVideoCameraPreview(controller: _controller)
        else
          Container(color: Colors.black),
        if (_isLoading || _errorMessage != null)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: _isStreaming ? Icons.stop : Icons.videocam,
                color: _isStreaming ? Colors.red : Colors.green,
                onPressed: _isStreaming ? _stopStreaming : _startStreaming,
                disabled: !_isCameraInitialized || _isLoading,
              ),
              _buildControlButton(
                icon: Icons.cameraswitch,
                color: Colors.blue,
                onPressed: _switchCamera,
                disabled: !_isCameraInitialized || _isLoading,
              ),
              _buildControlButton(
                icon: _isMicOn ? Icons.mic : Icons.mic_off,
                color: _isMicOn ? Colors.orange : Colors.grey,
                onPressed: _toggleMicrophone,
                disabled: !_isCameraInitialized || _isLoading,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool disabled = false,
  }) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: CircleAvatar(
        radius: 30,
        backgroundColor: color,
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: disabled ? null : onPressed,
        ),
      ),
    );
  }
}
