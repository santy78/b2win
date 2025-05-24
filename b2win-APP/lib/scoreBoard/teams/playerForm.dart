import 'package:b2winai/constant.dart';
import 'package:b2winai/scoreBoard/teams/teamList.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';

class PlayerForm extends StatefulWidget {
  final String phoneNumber;
  final int teamId;
  const PlayerForm(
      {super.key, required this.phoneNumber, required this.teamId});

  @override
  _PlayerFormState createState() => _PlayerFormState();
}

class _PlayerFormState extends State<PlayerForm> {
  final TextEditingController playerNameController = TextEditingController();
  final TextEditingController playerPositionController =
      TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController infoController = TextEditingController();

  int teamId = 0;
  List searchedPlayer = [];
  int newlyCreatedPlayerId = 0;
  String phoneNumber = "";

  @override
  void initState() {
    super.initState();
    teamId = widget.teamId;
  }

  void dispose() {
    playerNameController.dispose();
    playerPositionController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> createPlayer() async {
    try {
      final response = await ApiService.createPlayer(
          playerNameController.text.trim(),
          dobController.text.trim(),
          phoneNumber,
          emailController.text.trim(),
          genderController.text.trim(),
          playerPositionController.text.trim(),
          infoController.text.trim(),
          context);
      if (response['statuscode'] == 200) {
        _showSnackbar(response['message']);
        List<Map<String, dynamic>> playerData =
            List<Map<String, dynamic>>.from(response['data']);
        setState(() {
          newlyCreatedPlayerId =
              playerData.isNotEmpty ? playerData[0]['playerId'] as int : 0;
        });
        setSelectedPlayerAndAdd(newlyCreatedPlayerId);
      } else {
        _showSnackbar(response['message']);
      }
    } catch (e) {
      _showSnackbar("Error creating team: $e");
    }
  }

  setSelectedPlayerAndAdd(int playerId) {
    searchedPlayer.add({
      "name": playerNameController.text.trim(),
      "position": playerPositionController.text.trim(),
      "playerId": playerId,
      "phonenumber": phoneNumber,
      "flag": "I"
    });
    addTeamSquardPlayers();
  }

  Future<void> addTeamSquardPlayers() async {
    try {
      final response = await ApiService.addTeamSquardPlayer(
          widget.teamId, searchedPlayer, context);
      if (response['statuscode'] == 200) {
        _showSnackbar(response['message']);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => TeamsListPage()));
      } else {
        _showSnackbar(response['message']);
      }
    } catch (e) {
      _showSnackbar("Error creating team: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900), // Earliest selectable date
      lastDate: DateTime.now(), // No future dates allowed
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text =
            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}"; // Format the date
      });
    }
  }

  bool isValidPhoneNumber(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  void validateAndSubmit() {
    phoneNumber = widget.phoneNumber;

    if (isValidPhoneNumber(phoneNumber)) {
      print("Valid Phone Number: $phoneNumber");
      createPlayer(); //create a player then add the player
    } else {
      print("Invalid Phone Number!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter a valid 10-digit phone number")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: playerNameController,
              decoration: const InputDecoration(labelText: 'Player Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dobController,
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true, // Prevent manual input
              onTap: () => _selectDate(context), // Open date picker on tap
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: widget.phoneNumber),
              decoration: const InputDecoration(labelText: 'Phone Number'),
              enabled: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: genderController,
              decoration: const InputDecoration(labelText: 'Gender'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: playerPositionController,
              decoration: const InputDecoration(labelText: 'Player Position'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: infoController,
              decoration: const InputDecoration(labelText: 'Info'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  validateAndSubmit();
                },
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
