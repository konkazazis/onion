import 'dart:developer';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/details_service.dart';

class PersonalDetails extends StatefulWidget {
  final String userID;
  final String email;
  const PersonalDetails({super.key, required this.userID, required this.email});

  @override
  State<PersonalDetails> createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends State<PersonalDetails> {
  final detailsService _detailsService = detailsService();
  TextEditingController companyController = TextEditingController();
  TextEditingController positionController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  var readOnly = true;


  Future fetchDetails() async {
    try {
      final profileDetails = await _detailsService.fetchDetails(widget.userID);
      log('Email ${widget.email}');
      companyController.text = profileDetails[0]['company'] ?? '';
      positionController.text = profileDetails[0]['position'] ?? '';
      timeController.text = profileDetails[0]['brakeTime']?.toString() ?? '';
      locationController.text = profileDetails[0]['location'] ?? '';
      emailController.text = widget.email;
    } catch (e) {
      print("Error fetching details");
    }
  }

  @override
  void initState() {
    fetchDetails();
  }

  void _saveDetails() {}

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Personal Details',
                style: GoogleFonts.raleway(
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
              SwitchListTile(
                value: !readOnly,
                onChanged: (bool value) {
                  setState(() {
                    readOnly = !readOnly;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                readOnly: readOnly,
                controller: companyController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                    labelText: 'Company'
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                readOnly: readOnly,
                controller: positionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                    labelText: 'Position'
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                readOnly: readOnly,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                controller: timeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                    labelText: 'Brake time (minutes)'
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                readOnly: readOnly,
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                    labelText: 'Email'
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                readOnly: readOnly,
                controller: locationController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                    labelText: 'Location'
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: _saveDetails,
                  child: const Text(
                    style: TextStyle(color: Colors.black),
                    'Save Shift',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(15.0),
                      elevation: 6.0,
                      shadowColor: Colors.black54,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 25.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
