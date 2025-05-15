// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;

// import 'package:camera/camera.dart';
// import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:path_provider/path_provider.dart';

// class LiveStreamPage extends StatefulWidget {
//   const LiveStreamPage({Key? key}) : super(key: key);

//   @override
//   State<LiveStreamPage> createState() => _LiveStreamPageState();
// }

// class _LiveStreamPageState extends State<LiveStreamPage> {
//   CameraController? _controller;
//   final GlobalKey _repaintKey = GlobalKey();
//   bool _isStreaming = false;
//   bool _isMicEnabled = true;

//   // Cricket Scoreboard Info
//   int runs = 0, wickets = 0;
//   double overs = 0.0;
//   String striker = "Rohit Sharma";
//   String nonStriker = "Virat Kohli";
//   String bowler = "Jasprit Bumrah";
//   String teamName = "Team A";

//   final String rtmpUrl =
//       "rtmp://a.rtmp.youtube.com/live2/k9w0-xzc0-awz5-fzbw-f0x5"; // Replace with actual key

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     try {
//       final cameras = await availableCameras();
//       _controller = CameraController(cameras[0], ResolutionPreset.medium);
//       await _controller!.initialize();
//       setState(() {});
//     } catch (e) {
//       print("Camera init error: $e");
//     }
//   }

//   Future<void> _startStreaming() async {
//     setState(() => _isStreaming = true);

//     final tempDir = await getTemporaryDirectory();
//     final pipePath = '${tempDir.path}/stream_pipe.y4m';

//     await File(pipePath).delete().catchError((_) {});
//     await Process.run('mkfifo', [pipePath]);

//     final audioInput = _isMicEnabled ? "-f avfoundation -i :0" : "";
//     final audioMap = _isMicEnabled ? "-map 1:a" : "";
//     final ffmpegCmd = '''
//       -f y4m -i $pipePath $audioInput 
//       -filter_complex "[0:v]fps=30[v]" -map "[v]" $audioMap 
//       -c:v libx264 -preset ultrafast -tune zerolatency 
//       -pix_fmt yuv420p -f flv $rtmpUrl
//     ''';

//     FFmpegKit.executeAsync(ffmpegCmd);
//     _captureFramesToPipe(pipePath);
//   }

//   Future<void> _captureFramesToPipe(String pipePath) async {
//     final pipe = File(pipePath).openWrite();

//     Timer.periodic(Duration(milliseconds: 100), (timer) async {
//       if (!_isStreaming) {
//         timer.cancel();
//         await pipe.flush();
//         await pipe.close();
//         return;
//       }

//       try {
//         final image = await _captureOverlayImage();
//         final y4mData = await _convertImageToY4M(image);
//         pipe.add(y4mData);
//       } catch (_) {}
//     });
//   }

//   Future<ui.Image> _captureOverlayImage() async {
//     final boundary =
//         _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//     return await boundary.toImage(pixelRatio: 1.0);
//   }

//   Future<Uint8List> _convertImageToY4M(ui.Image image) async {
//     final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
//     final raw = byteData!.buffer.asUint8List();
//     final width = image.width;
//     final height = image.height;

//     final header = 'YUV4MPEG2 W$width H$height F30:1 Ip A1:1 C444\nFRAME\n';
//     return Uint8List.fromList([...utf8.encode(header), ...raw]);
//   }

//   void _stopStreaming() {
//     setState(() => _isStreaming = false);
//     FFmpegKit.cancel();
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     _stopStreaming();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_controller == null || !_controller!.value.isInitialized) {
//       return Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       body: RepaintBoundary(
//         key: _repaintKey,
//         child: Stack(
//           children: [
//             CameraPreview(_controller!),

//             // 🏏 Cricket Overlay
//             Positioned(
//               top: 40,
//               left: 20,
//               right: 20,
//               child: Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.black87,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("$teamName vs Team B",
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold)),
//                     Text(
//                         "Score: $runs/$wickets  |  Overs: ${overs.toStringAsFixed(1)}",
//                         style: TextStyle(color: Colors.white, fontSize: 16)),
//                     Text("Striker: $striker | Non-striker: $nonStriker",
//                         style: TextStyle(color: Colors.white70, fontSize: 14)),
//                     Text("Bowler: $bowler",
//                         style: TextStyle(color: Colors.white70, fontSize: 14)),
//                   ],
//                 ),
//               ),
//             ),

//             // 🎮 Controls
//             Positioned(
//               bottom: 100,
//               left: 20,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ElevatedButton(
//                       onPressed: () => setState(() => runs += 1),
//                       child: Text("Add 1 Run")),
//                   ElevatedButton(
//                       onPressed: () => setState(() => runs += 4),
//                       child: Text("Add 4 Runs")),
//                   ElevatedButton(
//                       onPressed: () => setState(() => runs += 6),
//                       child: Text("Add 6 Runs")),
//                   ElevatedButton(
//                       onPressed: () => setState(() => wickets += 1),
//                       child: Text("Add Wicket")),
//                   ElevatedButton(
//                       onPressed: () => setState(() => overs += 0.1),
//                       child: Text("Next Ball")),
//                 ],
//               ),
//             ),

//             // 🎙️ Mic Toggle
//             Positioned(
//               bottom: 180,
//               right: 20,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   setState(() {
//                     _isMicEnabled = !_isMicEnabled;
//                   });
//                 },
//                 icon: Icon(_isMicEnabled ? Icons.mic : Icons.mic_off),
//                 label: Text(_isMicEnabled ? "Mic On" : "Mic Off"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _isMicEnabled ? Colors.green : Colors.grey,
//                 ),
//               ),
//             ),

//             // 🔴 Start/Stop Stream
//             Positioned(
//               bottom: 40,
//               right: 20,
//               child: ElevatedButton(
//                 onPressed: _isStreaming ? _stopStreaming : _startStreaming,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _isStreaming ? Colors.red : Colors.green,
//                 ),
//                 child: Text(_isStreaming ? "Stop Stream" : "Start Stream"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
