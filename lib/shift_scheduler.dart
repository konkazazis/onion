import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ShiftScheduler extends StatefulWidget {
  final String userID;
  const ShiftScheduler({super.key, required this.userID});

  @override
  State<ShiftScheduler> createState() => _ShiftSchedulerState();
}

class _ShiftSchedulerState extends State<ShiftScheduler> {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? selectedWorkType;
  String notes = "";
  var selectedHour = 0;
  var brakeTime = '';
  var overtime = '';

  final List<String> workTypes = [
    'Morning',
    'Afternoon',
    'Night',
    'Remote',
    'On-site'
  ];

  // Function to add event (shift) to Firestore
  Future<void> addEvent(String? type, DateTime eventDate, TimeOfDay startTime,
      TimeOfDay endTime, String userID, String notes) async {
    try {
      DateTime startDateTime = DateTime(eventDate.year, eventDate.month,
          eventDate.day, startTime.hour, startTime.minute);
      DateTime endDateTime = DateTime(eventDate.year, eventDate.month,
          eventDate.day, endTime.hour, endTime.minute);

      print("notes $notes");

      await FirebaseFirestore.instance.collection('shifts').add({
        'workType': type,
        'startTime': Timestamp.fromDate(startDateTime),
        'endTime': Timestamp.fromDate(endDateTime),
        'overtime': overtime,
        'brakeTime': brakeTime,
        'userid': userID,
        'date': Timestamp.fromDate(eventDate),
        'notes': notes.isEmpty ? "" : notes
      });

      print("Shift added successfully!");
    } catch (e) {
      print("Error adding shift: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (startTime ?? TimeOfDay.now())
          : (endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() => isStartTime ? startTime = picked : endTime = picked);
    }
  }

  Future<void> _saveShift() async {
    if (selectedDate != null &&
        startTime != null &&
        endTime != null &&
        selectedWorkType != null) {
      await addEvent(selectedWorkType, selectedDate!, startTime!, endTime!,
          widget.userID, notes);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Shift Saved'),
          content:
              Text('Date: ${DateFormat('dd-MM-yyyy').format(selectedDate!)}\n'
                  'Start: ${startTime!.format(context)}\n'
                  'End: ${endTime!.format(context)}\n'
                  'Work Type: $selectedWorkType\n'
                  'Notes: $notes'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK')),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center horizontally
              mainAxisSize:
                  MainAxisSize.min, // Prevent Column from taking full heigh
              children: [
                Text(
                  'This is where you plan your next shift',
                  style: GoogleFonts.raleway(
                      textStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 28)),
                ),
                const SizedBox(height: 50),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                              color: Colors.black, width: 1), // Optional border
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.grey, width: 1),
                          ),
                        ),
                        onPressed: () => _selectDate(context),
                        child: Text(
                          style: TextStyle(color: Colors.black),
                          selectedDate != null
                              ? 'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'
                              : 'Select Date',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                              color: Colors.black, width: 1), // Optional border
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.grey, width: 1),
                          ),
                        ),
                        onPressed: () => _selectTime(context, true),
                        child: Text(
                          style: TextStyle(color: Colors.black),
                          startTime != null
                              ? 'Start: ${startTime!.format(context)}'
                              : 'Select Start Time',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                              color: Colors.black, width: 1), // Optional border
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.grey, width: 1),
                          ),
                        ),
                        onPressed: () => _selectTime(context, false),
                        child: Text(
                          style: TextStyle(color: Colors.black),
                          endTime != null
                              ? 'End: ${endTime!.format(context)}'
                              : 'Select End Time',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        //controller: timeController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Overtime (minutes)'
                        ),
                        onChanged: (value) {
                          setState(() {
                            overtime = value;
                            print(overtime);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child:  TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        //controller: timeController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Brake time (minutes)'
                        ),
                        onChanged: (value) {
                          setState(() {
                            brakeTime = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  focusColor: Colors.black,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Colors.black, width: 1),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  hint: Text("Select a work type"),
                  value: selectedWorkType,
                  items: workTypes
                      .map((type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedWorkType = value),
                ),
                const SizedBox(height: 24),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Notes',
                  ),
                  onChanged: (value) => setState(() => notes = value),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.black, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                    onPressed: _saveShift,
                    child: const Text(
                        style: TextStyle(color: Colors.black), 'Save Shift'),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: 24.0), // Adjust padding as needed
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: const CircleBorder(), // Fully round button
                        padding: const EdgeInsets.all(
                            15.0), // Increase for a bigger button
                        elevation: 6.0,
                        shadowColor: Colors.black54,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 25.0, // Bigger icon
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
