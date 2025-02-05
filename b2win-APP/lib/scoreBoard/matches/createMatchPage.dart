import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchCreatePage extends StatefulWidget {
  @override
  _MatchCreatePageState createState() => _MatchCreatePageState();
}

class _MatchCreatePageState extends State<MatchCreatePage> {
  int overs = 10;
  int oversPerBowler = 2;
  int powerPlayOvers = 0;
  String matchType = "Limited overs";
  String mode = "Casual";
  DateTime? matchDateTime;
  String teamA = "Team A";
  String teamB = "Team B";

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          matchDateTime = DateTime(pickedDate.year, pickedDate.month,
              pickedDate.day, pickedTime.hour, pickedTime.minute);
        });
      }
    }
  }

  void _selectTeam(BuildContext context, bool isTeamA) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: [
            ListTile(
              title: Text("Team 1"),
              onTap: () {
                setState(() {
                  if (isTeamA) {
                    teamA = "Team 1";
                  } else {
                    teamB = "Team 1";
                  }
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Team 2"),
              onTap: () {
                setState(() {
                  if (isTeamA) {
                    teamA = "Team 2";
                  } else {
                    teamB = "Team 2";
                  }
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Match"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => _selectTeam(context, true),
                      child: const Column(
                        children: [
                          CircleAvatar(radius: 30, child: Text("A")),
                          SizedBox(height: 8),
                          Text("Team Name")
                        ],
                      ),
                    ),
                    const Text("VS",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => _selectTeam(context, true),
                      child: Column(
                        children: [
                          CircleAvatar(radius: 30, child: Text("B")),
                          SizedBox(height: 8),
                          Text("Team Name")
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                    hintText: "Round Type", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(
                    hintText: "Group Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              const Text("Match Schedule",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: matchDateTime == null
                      ? "Select Date & Time"
                      : DateFormat('yyyy-MM-dd – kk:mm').format(matchDateTime!),
                  border: const OutlineInputBorder(),
                ),
                onTap: () => _selectDateTime(context),
              ),
              const SizedBox(height: 10),
              const Text("Ball Type",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBallType("leather"),
                  _buildBallType("tennis"),
                  _buildBallType("other"),
                ],
              ),
              const SizedBox(height: 10),
              const Text("Pitch Type",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPitchType("rough"),
                  _buildPitchType("cement"),
                  _buildPitchType("turf"),
                  _buildPitchType("asphalt"),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: Text("Match Type",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<String>(
                      value: matchType,
                      items: ["Limited overs", "Test Match"].map((String type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          matchType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildCounter("Innings Count", overs,
                  (value) => setState(() => overs = value)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Start Match"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBallType(String type) {
    return Column(
      children: [
        const Icon(Icons.sports_cricket, size: 40),
        Text(type),
      ],
    );
  }

  Widget _buildPitchType(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(type),
    );
  }

  Widget _buildCounter(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => onChanged(value > 1 ? value - 1 : 1),
            ),
            Text("$value",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        )
      ],
    );
  }
}
