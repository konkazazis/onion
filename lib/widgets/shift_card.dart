import 'package:flutter/material.dart';

class ShiftCard extends StatelessWidget {
  final String title;
  final String hours;
  final String earnings;

  const ShiftCard({
    required this.title,
    required this.hours,
    required this.earnings,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text("Hours Worked: $hours", style: TextStyle(fontSize: 16)),
              SizedBox(height: 5),
              Text("Earnings: $earnings",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
