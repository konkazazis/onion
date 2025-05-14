// import 'package:flutter/material.dart';
// import 'package:dynamic_tabbar/dynamic_tabbar.dart';
//
//
// class DynamicTabExample extends StatefulWidget {
//   final List<Map<String, dynamic>> filteredWork;
//   final List<Map<String, dynamic>> filteredPersonal;
//
//
//   const DynamicTabExample({super.key,   required this.filteredWork, required this.filteredPersonal  });
//   @override
//   State<DynamicTabExample> createState() => _DynamicTabExampleState();
// }
//
// class _DynamicTabExampleState extends State<DynamicTabExample> {
//   late List<TabData> tabs;
//
//   List<TabData> getTabs() {
//     List<TabData> tabs = [];
//
//     if (widget.filteredWork.isNotEmpty) {
//       tabs.add(
//         TabData(
//           index: 1,
//           title: Tab(text: "Work (${widget.filteredWork.length})", icon: Icon(Icons.work)),
//           content: SingleChildScrollView(
//             child: Column(
//               children: List.generate(widget.filteredWork.length, (index) {
//                 final event = widget.filteredWork[index];
//                 String shiftType = event['workType'] ?? 'No Event';
//                 String? rawDate = event['date'];
//                 String eventDate = (rawDate != null && rawDate.contains('-'))
//                     ? "${rawDate.split("-")[1]}-${rawDate.split("-")[2]}"
//                     : 'No Date';
//                 String shiftStart = event['startTime'] ?? '';
//                 String shiftEnd = event['endTime'] ?? '';
//                 String notes = event['notes'] ?? '';
//                 String overtime = event['overtime'] ?? '';
//
//                 return Card(
//                   margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//                   color: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     side: BorderSide(color: Colors.grey, width: 1),
//                   ),
//                   child: ListTile(
//                     selected: false,
//                     leading: const Icon(Icons.event),
//                     title: Text(shiftType),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.edit),
//                           onPressed: () async {
//                             final shift = filteredWork[index];
//                             final result = await Navigator
//                                 .push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     ShiftEdit(
//                                       shift: shift,
//                                       userID: widget.userid,
//                                       email: widget.email,
//                                     ),
//                               ),
//                             );
//
//                             if (result == 'refresh') {
//                               await loadActivities(_selectedDay,
//                                   widget.userid);
//                               setState(() {
//                                 filteredWork =
//                                     getActivitiesForDay(
//                                         monthlyWork,
//                                         _selectedDay);
//                               });
//                             }
//                           },
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.close),
//                           onPressed: () async {
//                             final shiftId = filteredWork[index]['id'];
//                             await showDialog(
//                                 context: context,
//                                 builder: (
//                                     BuildContext context) {
//                                   return AlertDialog(
//                                     title: const Text(
//                                         'Are you sure you want to delete this shift?'),
//                                     actions: <Widget>[
//                                       TextButton(
//                                         style: TextButton
//                                             .styleFrom(
//                                             textStyle: Theme
//                                                 .of(context)
//                                                 .textTheme
//                                                 .labelLarge),
//                                         child: const Text(
//                                             'Cancel'),
//                                         onPressed: () {
//                                           Navigator
//                                               .of(
//                                               context)
//                                               .pop();
//                                         },
//                                       ),
//                                       TextButton(
//                                         style: TextButton
//                                             .styleFrom(
//                                             textStyle: Theme
//                                                 .of(context)
//                                                 .textTheme
//                                                 .labelLarge),
//                                         child: const Text(
//                                             'Confirm'),
//                                         onPressed: () async {
//                                           await deleteActivity(
//                                               monthlyWork,
//                                               shiftId);
//                                           await loadActivities(
//                                               _selectedDay,
//                                               widget
//                                                   .userid);
//                                           setState(() {
//                                             filteredWork =
//                                                 getActivitiesForDay(
//                                                     monthlyWork,
//                                                     _selectedDay);
//                                           });
//                                           Navigator
//                                               .of(
//                                               context)
//                                               .pop();
//                                         },
//                                       ),
//                                     ],
//                                   );
//                                 });
//                           },
//                         ),
//                       ],
//                     ),
//                     subtitle: Text(
//                       [
//                         eventDate,
//                         "$shiftStart - $shiftEnd ${overtime !=
//                             '' ? "+" + overtime : ''}",
//                         if (notes
//                             .trim()
//                             .isNotEmpty) notes
//                       ].join('\n'),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//         ),
//       );
//     }
//
//     if (widget.filteredPersonal.isNotEmpty) {
//       tabs.add(
//         TabData(
//           index: tabs.length + 1,
//           title: Tab(
//               text: "Personal (${widget.filteredPersonal.length})",
//               icon: Icon(Icons.person)),
//           content: Center(child: Text("Personal activities go here")),
//         ),
//       );
//     }
//
//     // // Add other categories similarly
//     // tabs.addAll([
//     //   TabData(
//     //     index: tabs.length + 1,
//     //     title: Tab(text: "Physical", icon: Icon(Icons.directions_bike)),
//     //     content: const Center(child: Text('Physical activities')),
//     //   ),
//     //   TabData(
//     //     index: tabs.length + 2,
//     //     title: Tab(text: "Social", icon: Icon(Icons.groups)),
//     //     content: const Center(child: Text('Social activities')),
//     //   ),
//     //   TabData(
//     //     index: tabs.length + 3,
//     //     title: Tab(text: "Household", icon: Icon(Icons.house)),
//     //     content: const Center(child: Text('Household tasks')),
//     //   ),
//     // ]);
//
//     return tabs;
//   }
//
//
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Example for Dynamic Tab'),
//       ),
//       body: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Wrap(
//               direction: Axis.horizontal,
//               alignment: WrapAlignment.center,
//               children: [
//
//               ],
//             ),
//           ),
//           Expanded(
//             child: DynamicTabBarWidget(
//               dynamicTabs: getTabs(),
//               isScrollable: true,
//               onTabControllerUpdated: (controller) {},
//               onTabChanged: (index) {},
//               onAddTabMoveTo: MoveToTab.last,
//               showBackIcon: true,
//               showNextIcon: true,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
// }