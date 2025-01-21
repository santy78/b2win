import 'dart:math';
import 'package:flutter/material.dart';

class FieldingPositionModal extends StatefulWidget {
  @override
  _FieldingPositionModalState createState() => _FieldingPositionModalState();
}

class _FieldingPositionModalState extends State<FieldingPositionModal> {
  bool showWheelFor1s2s3s = true;
  bool showWheelForDotBalls = true;
  Offset? tappedPosition;

  // Log fielding position on click
  void logFieldingPosition(String position) {
    debugPrint("Selected position: $position");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Selected position: $position")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select fielding position',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Field Layout
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade200,
              ),
              child: GestureDetector(
                onTapUp: (details) {
                  // Detect which region was tapped
                  Offset tapPosition = details.localPosition;
                  String selectedPosition =
                      detectFieldingPosition(tapPosition, 300, 300);

                  setState(() {
                    tappedPosition = tapPosition; // Store the tapped position
                  });

                  logFieldingPosition(selectedPosition);
                },
                child: CustomPaint(
                  painter: FieldPainter(tappedPosition: tappedPosition),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 80,
                      color: Colors.brown.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Toggles
          ListTile(
            leading: Switch(
              value: showWheelFor1s2s3s,
              onChanged: (value) {
                setState(() {
                  showWheelFor1s2s3s = value;
                });
              },
            ),
            title: const Text("Show wheel for 1s, 2s and 3s"),
          ),
          ListTile(
            leading: Switch(
              value: showWheelForDotBalls,
              onChanged: (value) {
                setState(() {
                  showWheelForDotBalls = value;
                });
              },
            ),
            title: const Text("Show wheel for dot balls"),
          ),
          const SizedBox(height: 20),
          // Select Button
          ElevatedButton(
            onPressed: () {
              // Action for the Select button
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Fielding position selected!"),
                ),
              );
            },
            child: const Text("Select"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  String detectFieldingPosition(
      Offset tapPosition, double width, double height) {
    double centerX = width / 2;
    double centerY = height / 2;

    double dx = tapPosition.dx - centerX;
    double dy = tapPosition.dy - centerY;

    double angle = (atan2(dy, dx) * 180 / pi + 360) % 360;

    // Updated angle mapping for new positions
    if (angle >= 337.5 || angle < 22.5) {
      return "Deep square leg";
    } else if (angle >= 22.5 && angle < 67.5) {
      return "Deep mid wicket";
    } else if (angle >= 67.5 && angle < 112.5) {
      return "Long on";
    } else if (angle >= 112.5 && angle < 157.5) {
      return "Long off";
    } else if (angle >= 157.5 && angle < 202.5) {
      return "Deep cover";
    } else if (angle >= 202.5 && angle < 247.5) {
      return "Deep point";
    } else if (angle >= 247.5 && angle < 292.5) {
      return "Third man"; // Previously "Third man"
    } else if (angle >= 292.5 && angle < 337.5) {
      return "Deep fine leg";
    }

    return "Unknown position";
  }
}

class FieldPainter extends CustomPainter {
  final Offset? tappedPosition;

  FieldPainter({this.tappedPosition});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw circles
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2, paint);
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 4, paint);

    // Draw lines dividing the circle
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 8; i++) {
      double angle = i * pi / 4;
      double x = center.dx + (size.width / 2) * cos(angle);
      double y = center.dy + (size.height / 2) * sin(angle);
      canvas.drawLine(center, Offset(x, y), paint);
    }

    // Add labels at appropriate angles
    final labels = [
      "Deep square leg",
      "Deep mid wicket",
      "Long on",
      "Long off",
      "Deep cover",
      "Deep point",
      "Third man",
      "Deep fine leg"
    ];
    final labelAngles = List.generate(8, (i) => i * pi / 4);

    final textStyle = TextStyle(color: Colors.black, fontSize: 12);
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < labels.length; i++) {
      double angle = labelAngles[i];
      double x = center.dx + (size.width / 2.5) * cos(angle);
      double y = center.dy + (size.height / 2.5) * sin(angle);

      textPainter.text = TextSpan(text: labels[i], style: textStyle);
      textPainter.layout(minWidth: 0, maxWidth: 100);
      textPainter.paint(canvas, Offset(x - 30, y - 10));
    }

    // Draw tapped position marker
    if (tappedPosition != null) {
      final markerPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;

      canvas.drawCircle(tappedPosition!, 5, markerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
