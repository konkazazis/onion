import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:onion/new_activity.dart';
import 'package:onion/services/house_service.dart';
import 'package:onion/services/social_service.dart';
import 'profile.dart';
import 'shift_edit.dart';
import 'package:table_calendar/table_calendar.dart';
import 'services/shifts_service.dart';
import 'package:intl/intl.dart';
import 'widgets/shift_card.dart';
import 'widgets/calendar_widget.dart';
import 'services/details_service.dart';
import 'services/personal_service.dart';
import 'services/physical_service.dart';
import 'package:dynamic_tabbar/dynamic_tabbar.dart';

class DashboardScreen extends StatefulWidget {
  final String created;
  final String username;
  final String userid;
  final String email;

  const DashboardScreen(
      {super.key,
       this.username = "Not found",
        this.created = "",
      required this.userid,
       this.email = ""});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final detailsService _detailsService = detailsService();
  final shiftsService _shiftsService = shiftsService();
  final PersonalService _personalSerivce = PersonalService();
  final PhysicalService _physicalSerivce = PhysicalService();
  final SocialService _socialSerivce = SocialService();
  final HouseService _houseSerivce = HouseService();


  bool _isLoading = true;
  bool nxtIcon = true;
  bool bckIcon = true;

  int numberOfShifts = 0;
  int perHour = 0;
  int earnings = 0;
  int brakeTime = 0;
  double totalBrakeTime = 0.0;

  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> filteredWork = [];
  List<Map<String, dynamic>> filteredPersonal = [];
  List<Map<String, dynamic>> filteredPhysical = [];
  List<Map<String, dynamic>> filteredSocial = [];
  List<Map<String, dynamic>> filteredHouse = [];
  List<Map<String, dynamic>> monthlyPersonal = [];
  List<Map<String, dynamic>> monthlyWork = [];
  List<Map<String, dynamic>> monthlyPhysical = [];
  List<Map<String, dynamic>> monthlySocial = [];
  List<Map<String, dynamic>> monthlyHouse = [];


  Duration totalMonthlyDuration = Duration();
  Duration netHours = Duration();

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  int overHours = 0;
  int overMinutes = 0;

  // Load events based on the selected day
  Future<void> loadActivities(DateTime selectedDate, String userID) async {
    setState(() => _isLoading = true);

    try {
      var resWork = await _shiftsService
          .fetchShiftsByMonth(
          "${selectedDate.month}-${selectedDate.year}", userID);
      var resPersonal= await _personalSerivce
          .fetchPersonalByMonth(
          "${selectedDate.month}-${selectedDate.year}", userID);
      var resPhysical= await _physicalSerivce
          .fetchPhysicalByMonth(
          "${selectedDate.month}-${selectedDate.year}", userID);
      var resSocial= await _socialSerivce
          .fetchSocialByMonth(
          "${selectedDate.month}-${selectedDate.year}", userID);
      var resHouse= await _houseSerivce
          .fetchHouseByMonth(
          "${selectedDate.month}-${selectedDate.year}", userID);

      // total work time calculation
      Duration calculatedDuration = Duration();
      var overtime = 0;
      final dateFormat = DateFormat("HH:mm");

      for (var shift in resWork) {
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
      //------------------------------------

      setState(() {
        monthlyPersonal = resPersonal;
        monthlyWork = resWork;
        monthlyPhysical = resPhysical;
        monthlySocial = resSocial;
        monthlyHouse = resHouse;
        filteredWork = getActivitiesForDay(monthlyWork, _selectedDay);
        filteredPersonal = getActivitiesForDay(monthlyPersonal, _selectedDay);
        filteredPhysical = getActivitiesForDay(monthlyPhysical, _selectedDay);
        filteredSocial = getActivitiesForDay(monthlySocial, _selectedDay);
        filteredHouse = getActivitiesForDay(monthlyHouse, _selectedDay);

        overHours = hours;
        overMinutes = minutes;
        numberOfShifts = resWork.length;
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

  List<Map<String, dynamic>> getActivitiesForDay(List<Map<String, dynamic>> monthlyActivities, DateTime day) {
    return monthlyActivities.where((event) {
      DateTime eventDate = DateFormat('yyyy-MM-dd').parse(event['date']);
      return isSameDay(eventDate, day);
    }).toList();
  }

  Future<void> deleteActivity(List<Map<String, dynamic>> monthlyActivities, String id) async {
    try {
      await _shiftsService.deleteShift(id);
      await loadActivities(_selectedDay, widget.userid);
      await getActivitiesForDay(monthlyWork, _selectedDay);
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
      await loadActivities(_selectedDay, widget.userid);
      setState(() {
        //filteredEvents = getActivitiesForDay(monthlyWork, _selectedDay);
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
    loadActivities(_selectedDay, widget.userid);
    loadDetails();
  }

  final Map<String, Color> shiftColors = {
    'morning': Colors.yellow,
    'afternoon': Colors.orange,
    'night': Colors.indigo,
    'remote': Colors.black26,
    'On-site': Colors.blueGrey
  };

  List<TabData> getTabs() {
    List<TabData> tabs = [];

    if (filteredWork.isNotEmpty) {
      tabs.add(
        TabData(
          index: 1,
          title: Tab(text: "Work (${filteredWork.length})", icon: Icon(Icons.work)),
          content:  SingleChildScrollView(
            child: Column(
              children: List.generate(
                  filteredWork.length, (index) {
                final event = filteredWork[index];
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
                            final shift = filteredWork[index];
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
                              await loadActivities(_selectedDay,
                                  widget.userid);
                              setState(() {
                                filteredWork =
                                    getActivitiesForDay(
                                        monthlyWork,
                                        _selectedDay);
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () async {
                            final shiftId = filteredWork[index]['id'];
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
                                          await deleteActivity(
                                              monthlyWork,
                                              shiftId);
                                          await loadActivities(
                                              _selectedDay,
                                              widget
                                                  .userid);
                                          setState(() {
                                            filteredWork =
                                                getActivitiesForDay(
                                                    monthlyWork,
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
        ),
      );
    }

    if (filteredPersonal.isNotEmpty) {
      tabs.add(
        TabData(
          index: tabs.length + 1,
          title: Tab(
              text: "Personal (${filteredPersonal.length})",
              icon: Icon(Icons.person)),
          content: SingleChildScrollView(
            child: Column(
              children: List.generate(
                  filteredPersonal.length, (index) {
                final event = filteredPersonal[index];
                String? rawDate = event['date'];
                String eventDate = (rawDate != null &&
                    rawDate.contains('-'))
                    ? "${rawDate.split("-")[1]}-${rawDate
                    .split("-")[2]}"
                    : 'No Date';
                String notes = event['notes'] ?? '';
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
                    leading: const Icon(Icons.person),
                    title: Text("Personal"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            final shift = filteredWork[index];
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
                              await loadActivities(_selectedDay,
                                  widget.userid);
                              setState(() {
                                filteredWork =
                                    getActivitiesForDay(
                                        monthlyWork,
                                        _selectedDay);
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () async {
                            final shiftId = filteredWork[index]['id'];
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
                                          await deleteActivity(
                                              monthlyWork,
                                              shiftId);
                                          await loadActivities(
                                              _selectedDay,
                                              widget
                                                  .userid);
                                          setState(() {
                                            filteredWork =
                                                getActivitiesForDay(
                                                    monthlyWork,
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
        ),
      );
    }

    if (filteredPhysical.isNotEmpty) {
      tabs.add(
        TabData(
          index: tabs.length + 2,
          title: Tab(
              text: "Physical (${filteredPhysical.length})",
              icon: Icon(Icons.directions_bike)),
          content: SingleChildScrollView(
            child: Column(
              children: List.generate(
                  filteredPhysical.length, (index) {
                final event = filteredPhysical[index];
                String? rawDate = event['date'];
                String eventDate = (rawDate != null &&
                    rawDate.contains('-'))
                    ? "${rawDate.split("-")[1]}-${rawDate
                    .split("-")[2]}"
                    : 'No Date';
                String notes = event['notes'] ?? '';
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
                    leading: const Icon(Icons.directions_bike),
                    title: Text("Physical"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            final shift = filteredWork[index];
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
                              await loadActivities(_selectedDay,
                                  widget.userid);
                              setState(() {
                                filteredPhysical =
                                    getActivitiesForDay(
                                        monthlyWork,
                                        _selectedDay);
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () async {
                            final shiftId = filteredWork[index]['id'];
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
                                          await deleteActivity(
                                              monthlyWork,
                                              shiftId);
                                          await loadActivities(
                                              _selectedDay,
                                              widget
                                                  .userid);
                                          setState(() {
                                            filteredWork =
                                                getActivitiesForDay(
                                                    monthlyWork,
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
        ),
      );
    }

    if (filteredSocial.isNotEmpty) {
      tabs.add(
        TabData(
          index: tabs.length + 3,
          title: Tab(
              text: "Social (${filteredSocial.length})",
              icon: Icon(Icons.groups)),
          content: SingleChildScrollView(
            child: Column(
              children: List.generate(
                  filteredSocial.length, (index) {
                final event = filteredSocial[index];
                String? rawDate = event['date'];
                String eventDate = (rawDate != null &&
                    rawDate.contains('-'))
                    ? "${rawDate.split("-")[1]}-${rawDate
                    .split("-")[2]}"
                    : 'No Date';
                String notes = event['notes'] ?? '';
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
                    leading: const Icon(Icons.groups),
                    title: Text("Social"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            final shift = filteredWork[index];
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
                              await loadActivities(_selectedDay,
                                  widget.userid);
                              setState(() {
                                filteredSocial =
                                    getActivitiesForDay(
                                        monthlyWork,
                                        _selectedDay);
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () async {
                            final shiftId = filteredWork[index]['id'];
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
                                          await deleteActivity(
                                              monthlyWork,
                                              shiftId);
                                          await loadActivities(
                                              _selectedDay,
                                              widget
                                                  .userid);
                                          setState(() {
                                            filteredWork =
                                                getActivitiesForDay(
                                                    monthlyWork,
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
        ),
      );
    }

    if (filteredHouse.isNotEmpty) {
      tabs.add(
        TabData(
          index: tabs.length + 2,
          title: Tab(
              text: "Household (${filteredHouse.length})",
              icon: Icon(Icons.house)),
          content: SingleChildScrollView(
            child: Column(
              children: List.generate(
                  filteredHouse.length, (index) {
                final event = filteredHouse[index];
                String? rawDate = event['date'];
                String eventDate = (rawDate != null &&
                    rawDate.contains('-'))
                    ? "${rawDate.split("-")[1]}-${rawDate
                    .split("-")[2]}"
                    : 'No Date';
                String notes = event['notes'] ?? '';
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
                    leading: const Icon(Icons.house),
                    title: Text("Household"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            final shift = filteredWork[index];
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
                              await loadActivities(_selectedDay,
                                  widget.userid);
                              setState(() {
                                filteredPhysical =
                                    getActivitiesForDay(
                                        monthlyWork,
                                        _selectedDay);
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () async {
                            final shiftId = filteredWork[index]['id'];
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
                                          await deleteActivity(
                                              monthlyWork,
                                              shiftId);
                                          await loadActivities(
                                              _selectedDay,
                                              widget
                                                  .userid);
                                          setState(() {
                                            filteredWork =
                                                getActivitiesForDay(
                                                    monthlyWork,
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
        ),
      );
    }

    // // Add other categories similarly
    // tabs.addAll([
    //   TabData(
    //     index: tabs.length + 1,
    //     title: Tab(text: "Physical", icon: Icon(Icons.directions_bike)),
    //     content: const Center(child: Text('Physical activities')),
    //   ),
    //   TabData(
    //     index: tabs.length + 2,
    //     title: Tab(text: "Social", icon: Icon(Icons.groups)),
    //     content: const Center(child: Text('Social activities')),
    //   ),
    //   TabData(
    //     index: tabs.length + 3,
    //     title: Tab(text: "Household", icon: Icon(Icons.house)),
    //     content: const Center(child: Text('Household tasks')),
    //   ),
    // ]);
    print(tabs.length);
    if (tabs.length == 1)
      {
        nxtIcon = false;
        bckIcon = false;
      }
    else {
      nxtIcon = true;
      bckIcon = true;
    }

    return tabs;
  }



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
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            actions: [
              IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
              Text("|", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),),
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
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          filteredWork = getActivitiesForDay(monthlyWork,selectedDay);
                          filteredPersonal = getActivitiesForDay(monthlyPersonal, selectedDay);
                          filteredPhysical = getActivitiesForDay(monthlyPhysical, selectedDay);
                          filteredSocial = getActivitiesForDay(monthlySocial, selectedDay);
                          //filteredHouse = getActivitiesForDay(monthlyHouse, selectedDay);
                        });
                      },
                      onPageChanged: (focusedDay) {
                        final monthStart = DateTime(
                            focusedDay.year, focusedDay.month, 1);
                        setState(() {
                          _focusedDay = monthStart;
                          _selectedDay = monthStart;
                          filteredWork = getActivitiesForDay(monthlyWork, _selectedDay);
                          filteredPersonal = getActivitiesForDay(monthlyPersonal, _selectedDay);
                          filteredPhysical = getActivitiesForDay(monthlyPhysical, _selectedDay);
                          filteredSocial = getActivitiesForDay(monthlySocial, _selectedDay);
                          filteredHouse = getActivitiesForDay(monthlyHouse, _selectedDay);
                        });
                        loadActivities(monthStart, widget.userid);
                      },
                      eventLoader: (day) => getActivitiesForDay(monthlyWork, day),
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
                  : filteredWork.isEmpty && filteredPersonal.isEmpty && filteredPhysical.isEmpty
                      && filteredSocial.isEmpty && filteredHouse.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(height: 20),
                    Text("No activities found"),
                  ],
                ),
              )
                  : Column(
                children: [
                  Container(
                    height: 300,
                    child:
                    Center(
                      child: DynamicTabBarWidget(
                        labelColor: Colors.black,
                        indicatorColor: Colors.black,
                        dynamicTabs: getTabs(),
                        isScrollable: true,
                        onTabControllerUpdated: (controller) {},
                        onTabChanged: (index) {},
                        onAddTabMoveTo: MoveToTab.last,
                        showBackIcon: bckIcon,
                        showNextIcon: nxtIcon,
                        onAddTabMoveToIndex: 1,
                      ),
                    )
                  )

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
            ]
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("New Activity"),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewActivity(userid: widget.userid,),
            ),
          );

          if (result == 'refresh') {
            await loadDetails();
            await loadActivities(_selectedDay, widget.userid);
            setState(() {
              filteredWork = getActivitiesForDay(monthlyWork, _selectedDay);
              filteredPersonal = getActivitiesForDay(monthlyPersonal, _selectedDay);
              filteredPhysical = getActivitiesForDay(monthlyPhysical, _selectedDay);
              filteredSocial = getActivitiesForDay(monthlySocial, _selectedDay);
              filteredHouse = getActivitiesForDay(monthlyHouse, _selectedDay);

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