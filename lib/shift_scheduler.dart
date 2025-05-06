import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      Navigator.pop(context, 'refresh');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text("Plan Your Shift",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22)
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabeledButton(
                  label: "Select Date",
                  value: selectedDate != null
                      ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                      : "No date selected",
                  icon: Icons.calendar_today,
                  onTap: () => _selectDate(context),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildLabeledButton(
                        label: "Start Time",
                        value: startTime?.format(context) ?? "Select",
                        icon: Icons.access_time,
                        onTap: () => _selectTime(context, true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildLabeledButton(
                        label: "End Time",
                        value: endTime?.format(context) ?? "Select",
                        icon: Icons.access_time_outlined,
                        onTap: () => _selectTime(context, false),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Text("Work Type", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  hint: const Text("Choose work type"),
                  value: selectedWorkType,
                  items: workTypes
                      .map((type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedWorkType = value),
                ),

                const SizedBox(height: 16),
                Text("Overtime (minutes)", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "Enter overtime"),
                  onChanged: (value) => setState(() => overtime = value),
                ),

                const SizedBox(height: 16),

                Text("Notes", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "Additional notes"),
                  onChanged: (value) => setState(() => notes = value),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text("Save Shift",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    onPressed: () async {
                      await _saveShift();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledButton({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "$label: $value",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
