import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ShiftEdit extends StatefulWidget {
  final String userID;
  final String email;
  final Map<String,dynamic> shift;
  const ShiftEdit({super.key, required this.userID, required this.email, required this.shift});

  @override
  State<ShiftEdit> createState() => _ShiftEditState();
}

class _ShiftEditState extends State<ShiftEdit> {
  late TextEditingController overtimeController;
  late TextEditingController notesController;

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? selectedWorkType;
  String notes = "";
  var selectedHour = 0;
  var brakeTime = '';
  var overtime = '';

  @override
  void initState() {
    super.initState();
    print(widget.shift);

    selectedDate = widget.shift['date'] != null ? DateTime.parse(widget.shift['date']) : null;

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

    selectedWorkType = widget.shift['workType'];
    overtimeController = TextEditingController(text: widget.shift['overtime'] ?? '3');
    notesController = TextEditingController(text: widget.shift['notes'] ?? '');
  }


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
                  'Shift Edit',
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
                TextField(
                  controller: overtimeController,
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
                    });
                  },
                ),
                const SizedBox(width: 16),
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
                  controller: notesController,
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
                    onPressed: () async {
                      Navigator.pop(context, 'refresh');
                    },
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
                      onPressed: () => Navigator.pop(context, 'refresh'),
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
