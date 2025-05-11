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
          .fetchShiftsByMonth(
          "${selectedDate.month}-${selectedDate.year}", userID);

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
        monthlyEvents = responseMonth;
        filteredEvents = getEventsForDay(_selectedDay);
        overHours = hours;
        overMinutes = minutes;
        numberOfShifts = responseMonth.length;
        totalMonthlyDuration = calculatedDuration;
        netHours = netDuration;
        if (totalMonthlyDuration.inHours != 0) {
          earnings = perHour * netHours.inHours;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('There was an error with loading your shift')),
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
        const SnackBar(content: Text(
            'There was an error with loading your profile details')),
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
        const SnackBar(
            content: Text('There was an error with deleting your shift')),
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
        const SnackBar(
            content: Text('There was an error with editing your shift')),
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: 1.0,
              ),
            ),
          ),
          child: AppBar(
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              "Welcome back, ${widget.username}!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
              Text("|", style: TextStyle(fontSize: 30),),
              IconButton(
                icon: Icon(Icons.account_circle),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProfileComponent(
                            name: widget.username,
                            email: widget.email,
                            profileImageUrl: 'test',
                            userid: widget.userid,
                            created: widget.created,
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SHIFT CARDS MOVED HERE
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: Row(
                  children: [
                    ShiftCard(
                      icon: Icons.access_time,
                      title: "Monthly Hours",
                      value: "${netHours.inHours}h ${netHours.inMinutes
                          .remainder(60)}m",
                      subtitle: "Total worked time",
                      color: Colors.blueAccent,
                    ),
                    SizedBox(width: 12),
                    ShiftCard(
                      icon: Icons.trending_up,
                      title: "Earnings",
                      value: "€ ${earnings != 0 ? earnings : 0}",
                      subtitle: "Based on hourly rate",
                      color: Colors.green,
                    ),
                    SizedBox(width: 12),
                    ShiftCard(
                      icon: Icons.timer,
                      title: "Overtime",
                      value: "${overHours}h ${overMinutes}m",
                      subtitle: "This month",
                      color: Colors.deepOrange,
                    ),
                  ],
                ),
              ),
              // CALENDAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CalendarWidget(
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
                        final monthStart = DateTime(
                            focusedDay.year, focusedDay.month, 1);
                        setState(() {
                          _focusedDay = monthStart;
                          _selectedDay = monthStart;
                          filteredEvents = getEventsForDay(_selectedDay);
                        });
                        loadShifts(monthStart, widget.userid);
                      },
                      eventLoader: getEventsForDay,
                      shiftColors: shiftColors,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Divider(
                color: Colors.grey[200],
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEvents.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(height: 20),
                    Text("No shifts found"),
                  ],
                ),
              )
                  : Column(
                children: [
                  DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        DefaultTabController(
                          length: 6,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: TabBar(
                              isScrollable: true,
                              overlayColor: MaterialStateProperty.all(
                                  Colors.transparent),
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Colors.black,
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold),
                              tabs: [
                                Tab(text: "Shifts (${filteredEvents.length})",
                                    icon: Icon(Icons.work)),
                                Tab(text: "Summary",
                                    icon: Icon(Icons.assignment)),
                                Tab(text: "Activities",
                                    icon: Icon(Icons.directions_bike)),
                                Tab(text: "Activities",
                                    icon: Icon(Icons.directions_bike)),
                                Tab(text: "Activities",
                                    icon: Icon(Icons.directions_bike)),
                                Tab(text: "Activities",
                                    icon: Icon(Icons.directions_bike)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 200,
                          child: TabBarView(
                            children: [
                              // Scrollable list of shifts
                              SingleChildScrollView(
                                child: Column(
                                  children: List.generate(
                                      filteredEvents.length, (index) {
                                    final event = filteredEvents[index];
                                    String shiftType = event['workType'] ??
                                        'No Event';
                                    String? rawDate = event['date'];
                                    String eventDate = (rawDate != null &&
                                        rawDate.contains('-'))
                                        ? "${rawDate.split("-")[1]}-${rawDate
                                        .split("-")[2]}"
                                        : 'No Date';
                                    String shiftStart = event['startTime'] ??
                                        '';
                                    String shiftEnd = event['endTime'] ?? '';
                                    String notes = event['notes'] ?? '';
                                    String overtime = event['overtime'] ?? '';
                                    return Card(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                            color: Colors.grey, width: 1),
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
                                                final result = await Navigator
                                                    .push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ShiftEdit(
                                                          shift: shift,
                                                          userID: widget.userid,
                                                          email: widget.email,
                                                        ),
                                                  ),
                                                );

                                                if (result == 'refresh') {
                                                  await loadShifts(_selectedDay,
                                                      widget.userid);
                                                  setState(() {
                                                    filteredEvents =
                                                        getEventsForDay(
                                                            _selectedDay);
                                                  });
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.close),
                                              onPressed: () async {
                                                final shiftId = filteredEvents[index]['id'];
                                                await showDialog(
                                                    context: context,
                                                    builder: (
                                                        BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Are you sure you want to delete this shift?'),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                                textStyle: Theme
                                                                    .of(context)
                                                                    .textTheme
                                                                    .labelLarge),
                                                            child: const Text(
                                                                'Cancel'),
                                                            onPressed: () {
                                                              Navigator
                                                                  .of(
                                                                  context)
                                                                  .pop();
                                                            },
                                                          ),
                                                          TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                                textStyle: Theme
                                                                    .of(context)
                                                                    .textTheme
                                                                    .labelLarge),
                                                            child: const Text(
                                                                'Confirm'),
                                                            onPressed: () async {
                                                              await deleteShift(
                                                                  shiftId);
                                                              await loadShifts(
                                                                  _selectedDay,
                                                                  widget
                                                                      .userid);
                                                              setState(() {
                                                                filteredEvents =
                                                                    getEventsForDay(
                                                                        _selectedDay);
                                                              });
                                                              Navigator
                                                                  .of(
                                                                  context)
                                                                  .pop();
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
                                            "$shiftStart - $shiftEnd ${overtime !=
                                                '' ? "+" + overtime : ''}",
                                            if (notes
                                                .trim()
                                                .isNotEmpty) notes
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("New Shift"),
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
            setState(() {
              filteredEvents = getEventsForDay(_selectedDay);
            });
          }
        },
        icon: Icon(Icons.add),
        tooltip: 'Add Event',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
    );
  }
}