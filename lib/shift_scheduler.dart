import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final List<String> workTypes = [
    'Morning',
    'Afternoon',
    'Night',
    'Remote',
    'On-site'
  ];

  // Function to add event (shift) to Firestore
  Future<void> addEvent(String? type, DateTime eventDate, TimeOfDay startTime,
      TimeOfDay endTime, String userID) async {
    try {
      DateTime startDateTime = DateTime(eventDate.year, eventDate.month,
          eventDate.day, startTime.hour, startTime.minute);
      DateTime endDateTime = DateTime(eventDate.year, eventDate.month,
          eventDate.day, endTime.hour, endTime.minute);

      await FirebaseFirestore.instance.collection('shifts').add({
        'workType': type,
        'startTime': Timestamp.fromDate(startDateTime),
        'endTime': Timestamp.fromDate(endDateTime),
        'userid': userID, // Replace with actual user ID if needed
        'date': Timestamp.fromDate(eventDate),
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

  // Save the shift by calling addEvent
  Future<void> _saveShift() async {
    if (selectedDate != null &&
        startTime != null &&
        endTime != null &&
        selectedWorkType != null) {
      await addEvent(
          selectedWorkType, // work type
          selectedDate!, // event date
          startTime!, // start time
          endTime!, // end time
          widget.userID);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Shift Saved'),
          content: Text(
            'Date: ${DateFormat('dd-MM-yyyy').format(selectedDate!)}\n'
            'Start: ${startTime!.format(context)}\n'
            'End: ${endTime!.format(context)}\n'
            'Work Type: $selectedWorkType',
          ),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
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
                    onPressed: () => _selectTime(context, true),
                    child: Text(
                      startTime != null
                          ? 'Start: ${startTime!.format(context)}'
                          : 'Select Start Time',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectTime(context, false),
                    child: Text(
                      endTime != null
                          ? 'End: ${endTime!.format(context)}'
                          : 'Select End Time',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Work Type',
              ),
              value: selectedWorkType,
              items: workTypes
                  .map((type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => selectedWorkType = value),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _saveShift,
                child: const Text('Save Shift'),
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
                        24.0), // Increase for a bigger button
                    elevation: 6.0,
                    shadowColor: Colors.black54,
                  ),
                  child: const Icon(
                    Icons.highlight_off,
                    size: 36.0, // Bigger icon
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
