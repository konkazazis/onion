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
  TextEditingController perHourController = TextEditingController();
  var readOnly = true;
  var company = '';
  var position = '';
  var brakeTime = '';
  var email = '';
  var location = '';
  var perHour = '';

  Future fetchDetails() async {
    try {
      final profileDetails = await _detailsService.fetchDetails(widget.userID);
      log('Email ${widget.email}');

      companyController.text = profileDetails[0]['company'] ?? '';
      positionController.text = profileDetails[0]['position'] ?? '';
      timeController.text = profileDetails[0]['brakeTime']?.toString() ?? '';
      locationController.text = profileDetails[0]['location'] ?? '';
      emailController.text = widget.email;
      perHourController.text = profileDetails[0]['perHour']?.toString() ?? '';

      // Update variables with the fetched values
      setState(() {
        company = companyController.text;
        position = positionController.text;
        brakeTime = timeController.text;
        location = locationController.text;
        email = emailController.text;
        perHour = perHourController.text;
      });
    } catch (e) {
      print("Error fetching details: $e");
    }
  }


  @override
  void initState() {
    fetchDetails();
  }

  void _saveDetails() {
    _detailsService.submitDetails(widget.userID, email, company, location, position, int.parse(brakeTime), int.parse(perHour));
    setState(() {
      readOnly = true;
    });
    log("${widget.userID}, $email, $company, $location, $position, ${int.parse(brakeTime)}, ${int.parse(perHour)}");
  }

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(
                    'Personal Details',
                    style: GoogleFonts.raleway(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),),
                  Expanded(child: SwitchListTile(
                    value: !readOnly,
                    onChanged: (bool value) {
                      setState(() {
                        readOnly = !readOnly;
                      });
                    },
                  ),)
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                enabled: !readOnly,
                readOnly: readOnly,
                controller: companyController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                    labelText: 'Company'
                ),
                onChanged: (value) {
                  setState(() {
                    company = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                enabled: !readOnly,
                readOnly: readOnly,
                controller: positionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                    labelText: 'Position'
                ),
                onChanged: (value) {
                  setState(() {
                    position = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                enabled: !readOnly,
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
                onChanged: (value) {
                  setState(() {
                    brakeTime = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                enabled: !readOnly,
                readOnly: readOnly,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                controller: perHourController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Money per hour (nett)'
                ),
                onChanged: (value) {
                  setState(() {
                    perHour = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                enabled: !readOnly,
                readOnly: readOnly,
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                    labelText: 'Email'
                ),
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                enabled: !readOnly,
                readOnly: readOnly,
                controller: locationController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                    labelText: 'Location'
                ),
                onChanged: (value) {
                  setState(() {
                    location = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: readOnly ? BorderSide(color: Colors.grey, width: 1) : BorderSide(color: Colors.black, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: readOnly ? null : _saveDetails,
                  child: Text(
                    style: readOnly ? TextStyle(color: Colors.grey) : TextStyle(color: Colors.black),
                    'Save',
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
