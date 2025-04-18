import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:picnic_search/profile.dart';
import 'package:table_calendar/table_calendar.dart';
import 'services/shifts_service.dart';
import 'package:intl/intl.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/shift_card.dart';
import 'shift_scheduler.dart';
import 'package:intl/intl.dart';
import 'services/details_service.dart';

class DashboardScreen extends StatefulWidget {
  final String username;
  final String userID;

  const DashboardScreen(
      {super.key, required this.username, required this.userID});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month; // Initial format
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
  DateTime _focusedDay = DateTime.now();

  // Load events based on the selected day
  Future<void> loadShifts(DateTime selectedDate) async {
    setState(() => _isLoading = true);

    print("Selected month: ${_selectedDay.month}-${_selectedDay.year}");

    try {
      // Fetch events for the selected date
      final fetchedEvents = await _shiftsService.fetchShifts(selectedDate);
      setState(() {
        events = fetchedEvents;
        filteredEvents = fetchedEvents;
        print(filteredEvents);
      });
    } catch (e) {
      log("Error fetching events: $e");
      setState(() {
        filteredEvents = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }

    try {
      var responseMonth = await _shiftsService
          .fetchShiftsByMonth("${_selectedDay.month}-${_selectedDay.year}");
      print("ResponseMonth: $responseMonth");

      setState(() {
        numberOfShifts = responseMonth.length;
        monthlyEvents = responseMonth;
      });

      Duration calculatedDuration = Duration(); // temporary container

      final dateFormat = DateFormat("HH:mm");

      for (var shift in responseMonth) {
        String start = shift['startTime'];
        String end = shift['endTime'];

        DateTime startTime = dateFormat.parse(start);
        DateTime endTime = dateFormat.parse(end);

        Duration duration = endTime.difference(startTime);
        calculatedDuration += duration;
      }

      int totalBreakMinutes = numberOfShifts * brakeTime;
      Duration totalBreakDuration = Duration(minutes: totalBreakMinutes);

      Duration netDuration = calculatedDuration - totalBreakDuration;
      setState((){
        netHours = netDuration;
      });

      setState(() {
        totalMonthlyDuration = calculatedDuration;
        if (totalMonthlyDuration.inHours != 0) {
          earnings = perHour * netHours.inHours;
        }
      });
    } catch (e) {
      log("Error fetching events by month: $e");
    }
  }

  Future <void> loadDetails() async {
    try {
      final profileDetails = await _detailsService.fetchDetails(widget.userID);
      perHour = profileDetails[0]['perHour'] ?? 0;
      brakeTime = profileDetails[0]['brakeTime'] ?? 0;
    }catch (e) {
      print("Error fetching details: $e");
    }
  }

  List<Map<String, dynamic>> getEventsForDay(DateTime day) {
    return monthlyEvents.where((event) {
      DateTime eventDate = DateFormat('yyyy-MM-dd').parse(event['date']);
      return isSameDay(eventDate, day);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = _selectedDay;
    loadShifts(_selectedDay);
    loadDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text.rich(
          TextSpan(
            text: 'Welcome back, ',
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(
                text: widget.username, // Bold username
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' !'), // Exclamation mark
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                child: TableCalendar(
                  weekNumbersVisible : true,
                  firstDay: DateTime.utc(2000, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    loadShifts(selectedDay);
                  },
                  eventLoader: getEventsForDay,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.deepOrange,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration( // Optional: customize marker
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEvents.isEmpty
                      ? const Center(child: Text("No shifts found"))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
                            String eventName = event['workType'] ?? 'No Event';
                            String eventDate = event['date'].split("-")[1] + "-" + event['date'].split("-")[2] ?? 'No Date';
                            String shiftStart = event['startTime'] ?? '';
                            String shiftEnd = event['endTime'] ?? '';
                            String notes = event['notes'] ?? '';
                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                                title: Text(eventName),
                                subtitle: Text(
                                  [
                                    eventDate,
                                    "$shiftStart - $shiftEnd",
                                    if (notes.trim().isNotEmpty)
                                      notes, // Only include if not empty
                                  ].join('\n'),
                                ),
                              ),
                            );
                          },
                        ),
              const SizedBox(height: 20),
              Divider(
                color: Colors.grey[200],
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ShiftCard(
                    title: "Total hours this month :",
                    hours:
                        "${netHours.inHours}h ${netHours.inMinutes.remainder(60)}m",
                    earnings: "\€ ${earnings != 0 ? earnings : 0}",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ShiftScheduler(userID: widget.userID)),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Event',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
    );
  }
}
