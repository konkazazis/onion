import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/shifts_service.dart';

class ShiftEdit extends StatefulWidget {
  final String userID;
  final String email;
  final Map<String, dynamic> shift;

  const ShiftEdit({
    super.key,
    required this.userID,
    required this.email,
    required this.shift,
  });

  @override
  State<ShiftEdit> createState() => _ShiftEditState();
}

class _ShiftEditState extends State<ShiftEdit> {
  final shiftsService _shiftsService = shiftsService();

  late TextEditingController overtimeController;
  late TextEditingController notesController;

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? selectedWorkType;
  String shiftID = '';
  String overtime = '';
  String notes = '';

  final List<String> workTypes = [
    'Morning',
    'Afternoon',
    'Night',
    'Remote',
    'On-site'
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = widget.shift['date'] != null
        ? DateTime.parse(widget.shift['date'])
        : null;

    if (widget.shift['startTime'] != null) {
      final startParts = widget.shift['startTime'].split(":");
      startTime = TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      );
    }

    if (widget.shift['endTime'] != null) {
      final endParts = widget.shift['endTime'].split(":");
      endTime = TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      );
    }

    shiftID = widget.shift['id'];
    selectedWorkType = widget.shift['workType'];
    overtime = widget.shift['overtime'] ?? '';
    notes = widget.shift['notes'] ?? '';

    overtimeController = TextEditingController(text: overtime);
    notesController = TextEditingController(text: notes);
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

  Future<void> _saveEditedShift() async {
    if (selectedDate != null &&
        startTime != null &&
        endTime != null &&
        selectedWorkType != null) {
      DateTime finalStartTime = DateTime(selectedDate!.year, selectedDate!.month,
          selectedDate!.day, startTime!.hour, startTime!.minute);
      DateTime finalEndTime = DateTime(selectedDate!.year, selectedDate!.month,
          selectedDate!.day, endTime!.hour, endTime!.minute);

      await _shiftsService.editShift(
        id: shiftID,
        date: selectedDate,
        startTime: finalStartTime,
        endTime: finalEndTime,
        overtime: overtime,
        notes: notes,
        workType: selectedWorkType,
      );

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
        title: Center(
          child: Text(
            "Edit Your Shift",
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22),
          ),
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
                  controller: overtimeController,
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
                  controller: notesController,
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
                    label: const Text("Save Shift", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _saveEditedShift,
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
