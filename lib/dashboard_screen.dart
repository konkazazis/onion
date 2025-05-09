import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'profile.dart';
import 'shift_edit.dart';
import 'package:table_calendar/table_calendar.dart';
import 'services/shifts_service.dart';
import 'package:intl/intl.dart';
import 'widgets/shift_card.dart';
import 'widgets/calendar_widget.dart';
import 'shift_scheduler.dart';
import 'services/details_service.dart';

class DashboardScreen extends StatefulWidget {
  final String created;
  final String username;
  final String userid;
  final String email;

  const DashboardScreen(
      {super.key,
      required this.username,
        required this.created,
      required this.userid,
      required this.email});

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

  int overHours = 0;
  int overMinutes = 0;

  // Load events based on the selected day
  Future<void> loadShifts(DateTime selectedDate, String userID) async {
    setState(() => _isLoading = true);

    try {
      var responseMonth = await _shiftsService
          .fetchShiftsByMonth("${selectedDate.month}-${selectedDate.year}", userID);
      print("ResponseMonth: $responseMonth");

      Duration calculatedDuration = Duration();
      var overtime = 0;

      final dateFormat = DateFormat("HH:mm");

      for (var shift in responseMonth) {
        String start = shift['startTime'];
        String end = shift['endTime'];

        DateTime startTime = dateFormat.parse(start);
        DateTime endTime = dateFormat.parse(end);

        Duration duration = endTime.difference(startTime);
        calculatedDuration += duration;

        final parsedOvertime = int.tryParse(shift['overtime'] ?? '0');
        if (parsedOvertime != null) {
          overtime = overtime + parsedOvertime;
        }

      }

      int totalBreakMinutes = numberOfShifts * brakeTime;
      Duration totalBreakDuration = Duration(minutes: totalBreakMinutes);
      Duration netDuration = calculatedDuration - totalBreakDuration;

      int hours = overtime ~/ 60;
      int minutes = overtime % 60;

      setState(() {
        overHours = hours;
        overMinutes = minutes;
        numberOfShifts = responseMonth.length;
        monthlyEvents = responseMonth;
        totalMonthlyDuration = calculatedDuration;
        netHours = netDuration;
        if (totalMonthlyDuration.inHours != 0) {
          earnings = perHour * netHours.inHours;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There was an error with loading your shift')),
      );
      log("Error fetching events by month: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> loadDetails() async {
    try {
      final profileDetails = await _detailsService.fetchDetails(widget.userid);
      perHour = profileDetails[0]['perHour'] ?? 0;
      brakeTime = profileDetails[0]['brakeTime'] ?? 0;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There was an error with loading your profile details')),
      );
      print("Error fetching details: $e");
    }
  }

  List<Map<String, dynamic>> getEventsForDay(DateTime day) {
    return monthlyEvents.where((event) {
      DateTime eventDate = DateFormat('yyyy-MM-dd').parse(event['date']);
      return isSameDay(eventDate, day);
    }).toList();
  }

  Future<void> deleteShift(String id) async {
    try {
      await _shiftsService.deleteShift(id);
      await loadShifts(_selectedDay, widget.userid);
      await getEventsForDay(_selectedDay);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shift was deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There was an error with deleting your shift')),
      );
      print("Error deleting shift: $e");
    }
  }

  Future<void> editShift(String id, Map<String, dynamic> updatedData) async {
    try {
      await _shiftsService.editShift(
        id: id,
        date: updatedData['date'],
        startTime: updatedData['startTime'],
        endTime: updatedData['endTime'],
        workType: updatedData['workType'],
        notes: updatedData['notes'],
      );
      await loadShifts(_selectedDay, widget.userid);
      setState(() {
        filteredEvents = getEventsForDay(_selectedDay);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shift was edited successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There was an error with editing your shift')),
      );
      print("Error editing shift: $e");
    }
  }


  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = _selectedDay;
    loadShifts(_selectedDay, widget.userid);
    loadDetails();
  }

  final Map<String, Color> shiftColors = {
    'morning': Colors.yellow,
    'afternoon': Colors.orange,
    'night': Colors.indigo,
    'remote': Colors.black26,
    'On-site': Colors.blueGrey
  };


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:
        Padding(padding: EdgeInsets.only(left: 8), child: Text.rich(
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
        )),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8), // Added padding
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 23,
                      width: 23,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.notifications,
                        color: Color(0xFFBDBDBD),
                        size: 23,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '|',
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 32,
                        color: Color(0xFFE0E0E0),
                      ),
                    ),
                    SizedBox(
                        width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileComponent(
                              name: widget.username,
                              email: widget.email,
                              profileImageUrl: 'test',
                              userid: widget.userid,
                              created: widget.created
                            ),
                          ),
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.account_circle,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
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
                child: CalendarWidget(
                  calendarFormat: _calendarFormat,
                  selectedDay: _selectedDay,
                  focusedDay: _focusedDay,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      filteredEvents = getEventsForDay(selectedDay);
                    });
                  },
                  onPageChanged: (focusedDay) {
                    final monthStart = DateTime(focusedDay.year, focusedDay.month, 1);
                    setState(() {
                      _focusedDay = monthStart;
                      _selectedDay = monthStart;
                      filteredEvents = getEventsForDay(_selectedDay);
                    });
                    loadShifts(monthStart, widget.userid);
                  },
                  eventLoader: getEventsForDay,
                  shiftColors: shiftColors,
                )

              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEvents.isEmpty
                      ? const Center(child: Text("No shifts found"))
                      :  Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child:  Align(
                                alignment: Alignment.centerLeft,
                                child:
                                Text(
                                  DateFormat("EEEE, d 'of' MMMM").format(_selectedDay),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontSize: 18), // optional style
                                ),
                              )),
                            Divider(
                              color: Colors.grey[200],
                              thickness: 1,
                              indent: 20,
                              endIndent: 20,
                            ),
                            DefaultTabController(
                              length: 3,
                              child: Column(
                                children: [
                                  TabBar(
                                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                                    labelColor: Colors.black,
                                    unselectedLabelColor: Colors.grey,
                                    indicatorColor: Colors.white,
                                    dividerColor: Colors.white,
                                    tabs: [
                                        Tab(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.work),
                                              SizedBox(width: 6),
                                              Text("(${filteredEvents.length})"),
                                            ],
                                          ),
                                        ),
                                      Tab(icon: Icon(Icons.assignment)),
                                      Tab(icon: Icon(Icons.directions_bike)),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 300, // or use MediaQuery to calculate available space dynamically
                                    child: TabBarView(
                                      children: [
                                        // Scrollable list of shifts
                                        SingleChildScrollView(
                                          child: Column(
                                            children: List.generate(filteredEvents.length, (index) {
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
                                              return Card(
                                                margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                color: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  side: BorderSide(color: Colors.grey, width: 1),
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

                                                          if (result == 'refresh') {
                                                            await loadShifts(_selectedDay, widget.userid);
                                                            setState(() {
                                                              filteredEvents = getEventsForDay(_selectedDay);
                                                            });
                                                          }
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: Icon(Icons.close),
                                                        onPressed: () async {
                                                          final shiftId = filteredEvents[index]['id'];
                                                          await showDialog(context: context, builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              title: const Text('Are you sure you want to delete this shift?'),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  style: TextButton.styleFrom(
                                                                      textStyle: Theme.of(context).textTheme.labelLarge),
                                                                  child: const Text('Cancel'),
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                ),
                                                                TextButton(
                                                                  style: TextButton.styleFrom(
                                                                      textStyle: Theme.of(context).textTheme.labelLarge),
                                                                  child: const Text('Confirm'),
                                                                  onPressed: () async {
                                                                    await deleteShift(shiftId);
                                                                    await loadShifts(_selectedDay, widget.userid);
                                                                    setState(() {
                                                                      filteredEvents = getEventsForDay(_selectedDay);
                                                                    });
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  subtitle: Text(
                                                    [
                                                      eventDate,
                                                      "$shiftStart - $shiftEnd ${overtime != '' ? "+" + overtime : ''}",
                                                      if (notes.trim().isNotEmpty) notes
                                                    ].join('\n'),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                        Center(child: Icon(Icons.directions_transit)),
                                        Center(child: Icon(Icons.directions_bike)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                  ShiftCard(
                    title: "Total overtime this month :",
                    hours:
                    "${overHours}h ${overMinutes}m",
                    //earnings: "\€ ${earnings != 0 ? earnings : 0}",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShiftScheduler(userID: widget.userid),
            ),
          );

          if (result == 'refresh') {
            await loadDetails();
            await loadShifts(_selectedDay, widget.userid);
            print(_selectedDay);
            setState( () {
            filteredEvents = getEventsForDay(_selectedDay);
            });
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Add Event',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

    );
  }
}
