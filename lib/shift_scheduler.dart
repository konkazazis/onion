import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'events.dart';

class ShiftScheduler extends StatefulWidget {
  const ShiftScheduler({super.key});

  @override
  State<ShiftScheduler> createState() => _ShiftSchedulerState();
}

class _ShiftSchedulerState extends State<ShiftScheduler> {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? selectedWorkType;
  final EventService _eventService = EventService();

  final List<String> workTypes = [
    'Morning',
    'Afternoon',
    'Night',
    'Remote',
    'On-site'
  ];

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

  void _saveShift() {
    if (selectedDate != null &&
        startTime != null &&
        endTime != null &&
        selectedWorkType != null) {
      final dateFormatted = DateFormat('dd-MM-yyyy').format(selectedDate!);

      try {
        _eventService.addEvent(selectedWorkType, dateFormatted,
            formatTimeOfDay(startTime!), formatTimeOfDay(endTime!));
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Shift Saved'),
            content: Text(
              'Date: $dateFormatted\n'
              'Start: ${startTime!.format(context)}\n'
              'End: ${endTime!.format(context)}\n'
              'Work Type: $selectedWorkType',
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'))
            ],
          ),
        );
      } catch (e) {
        print("Error adding event: $e");
      }
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 6.0,
                      shadowColor: Colors.black54,
                    ),
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 6.0,
                      shadowColor: Colors.black54,
                    ),
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 6.0,
                      shadowColor: Colors.black54,
                    ),
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
