import 'package:flutter/material.dart';

class ShiftCard extends StatelessWidget {
  final String title;
  final String hours;
  final String earnings;

  const ShiftCard({
    required this.title,
    required this.hours,
    this.earnings = '',
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text("$hours", style: TextStyle(fontSize: 16)),
              SizedBox(height: 5),
              Text(earnings != '' ? "Earnings: $earnings" : '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
