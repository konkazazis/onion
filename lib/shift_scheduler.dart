import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      final dateFormatted = DateFormat('yyyy-MM-dd').format(selectedDate!);
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
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(
                selectedDate != null
                    ? 'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'
                    : 'Select Date',
              ),
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
          ],
        ),
      ),
    );
  }
}
