import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/details_service.dart';
import 'services/shifts_service.dart';
import 'shift_edit.dart';




class ShiftHistory extends StatefulWidget {
  final String created;
  final String userid;
  final String email;
  const ShiftHistory({super.key, required this.userid, required this.email, required this.created});

  @override
  State<ShiftHistory> createState() => _ShiftHistoryState();

}

class _ShiftHistoryState extends State<ShiftHistory> {
  final detailsService _detailsService = detailsService();
  final shiftsService _shiftsService = shiftsService();

  bool _isLoading = true;
  int numberOfShifts = 0;
  int perHour = 0;
  int earnings = 0;
  int brakeTime = 0;
  double totalBrakeTime = 0.0;

  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> filteredEvents = [];
  List<Map<String, dynamic>> monthlyEvents = [];

  Duration totalMonthlyDuration = Duration();
  Duration netHours = Duration();

  DateTime _selectedDay = DateTime.now();

  Future<void> loadShifts(DateTime selectedDate, String userid) async {
    setState(() => _isLoading = true);

    DateTime created = DateTime.parse(widget.created);

    try {
      var responseMonth = await _shiftsService
          .fetchAllShifts(widget.created, widget.userid);

      setState(() {
        filteredEvents = responseMonth;
      });

    } catch (e) {
      log("Error fetching events by month: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void initState() {
    loadShifts(_selectedDay, widget.userid);
    print(filteredEvents);
  }

  Future<void> deleteShift(String id) async {
    try {
      await _shiftsService.deleteShift(id);
      await loadShifts(_selectedDay, widget.userid);
      //await getEventsForDay(_selectedDay);
    } catch (e) {
      print("Error deleting shift: $e");
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
        title: Text(
          "Shift History",
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : filteredEvents.isEmpty
            ? const Center(child: Text("No shifts found"))
            :  Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                String shiftType = event['workType'] ?? 'No Event';
                String? rawDate = event['date'];
                String eventDate = (rawDate != null &&
                    rawDate.contains('-'))
                    ? "${rawDate.split("-")[1]}-${rawDate.split("-")[2]}"
                    : 'No Date';
                String shiftStart = event['startTime'] ?? '';
                String shiftEnd = event['endTime'] ?? '';
                String notes = event['notes'] ?? '';
                String overtime = event['overtime'] ?? '';
                return
                  Card(
                    margin: EdgeInsets.symmetric(
                        horizontal: 5, vertical: 5),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      selected: false,
                      leading: const Icon(Icons.event),
                      title: Text(shiftType),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () async {
                              final shift = filteredEvents[index];
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShiftEdit(
                                    shift: shift,
                                    userID: widget.userid,
                                    email: widget.email,
                                  ),
                                ),
                              );

                              // if (result == 'refresh') {
                              //   await loadShifts(_selectedDay);
                              //   setState(() {
                              //     filteredEvents = getEventsForDay(_selectedDay);
                              //   });
                              // }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () async {
                              final shiftId = filteredEvents[index]['id'];
                              await deleteShift(shiftId);
                              await loadShifts(_selectedDay, widget.userid);
                              setState(() {
                                //filteredEvents = getEventsForDay(_selectedDay);
                              });
                            },
                          ),
                        ],
                      ),
                      subtitle: Text(
                        [
                          eventDate,
                          "$shiftStart - $shiftEnd ${overtime != '' ? "+" + overtime : ''}",
                          if (notes.trim().isNotEmpty)
                            notes
                        ].join('\n'),
                      ),
                    ),
                  );
              },
            ),
          ],
        ),
      ),
    );
  }
}