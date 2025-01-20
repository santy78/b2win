import 'package:flutter/material.dart';

class AddTournamentPage extends StatefulWidget {
  @override
  _AddTournamentPageState createState() => _AddTournamentPageState();
}

class _AddTournamentPageState extends State<AddTournamentPage> {
  final TextEditingController _tournamentNameController =
      TextEditingController();
  String _selectedTournamentType = 'Knockout';
  DateTime? _startDate;
  DateTime? _endDate;

  void _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Tournament'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add Banner Image Section
                Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: screenWidth * 0.1,
                            backgroundColor: Colors.blue,
                            child: const Icon(
                              Icons.emoji_events,
                              size: 40.0,
                              color: Colors.white,
                            ),
                          ),
                          CircleAvatar(
                            radius: screenWidth * 0.04,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                size: 12.0,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                // Handle editing the icon
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                // Tournament Name Field
                const Text(
                  'Tournament Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: _tournamentNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter tournament name',
                  ),
                ),
                const SizedBox(height: 16.0),
                // Tournament Type Dropdown
                const Text(
                  'Tournament Type',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                DropdownButtonFormField<String>(
                  value: _selectedTournamentType,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedTournamentType = newValue!;
                    });
                  },
                  items: ['Knockout', 'Box League', 'Round Robin']
                      .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Date Pickers
                const Text(
                  'Start Date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                GestureDetector(
                  onTap: () => _selectDate(context, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      _startDate != null
                          ? '${_startDate!.toLocal()}'.split(' ')[0]
                          : 'Select start date',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'End Date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                GestureDetector(
                  onTap: () => _selectDate(context, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      _endDate != null
                          ? '${_endDate!.toLocal()}'.split(' ')[0]
                          : 'Select end date',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Team Selection
                const Text(
                  'Team Selection',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                GestureDetector(
                  onTap: () {
                    // Navigate to team selection screen
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'Select teams',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                // Create Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle tournament creation logic
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.2,
                        vertical: screenHeight * 0.02,
                      ),
                    ),
                    child: const Text('Create'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
