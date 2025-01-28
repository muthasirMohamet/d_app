import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../config.dart';

class AddAppointmentScreen extends StatefulWidget {
  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController appointmentDateController =
      TextEditingController();
  final TextEditingController statusController = TextEditingController();

  // Variables to store selected values
  String? selectedDoctorId;
  String? selectedPatientId;
  String? selectedStatus = 'Pending'; // Default status set to 'Pending'

  // Lists to hold fetched data
  List<dynamic> doctors = [];
  List<dynamic> patients = [];

  // Fetch doctors and patients from API
  Future<void> fetchDoctors() async {
    try {
      final response = await http.get(Uri.parse('$BASE_URLS/doctors'));
      if (response.statusCode == 200) {
        setState(() {
          doctors = jsonDecode(response.body);
          print("Doctors fetched: $doctors"); // Debug: print fetched doctors
        });
      } else {
        _handleError('Failed to load doctors');
      }
    } catch (e) {
      _handleError('Error fetching doctors: $e');
    }
  }

  Future<void> fetchPatients() async {
    try {
      final response = await http.get(Uri.parse('$BASE_URLS/customers/all'));
      if (response.statusCode == 200) {
        setState(() {
          patients = jsonDecode(response.body);
          print("Patients fetched: $patients"); // Debug: print fetched patients
        });
      } else {
        _handleError('Failed to load patients');
      }
    } catch (e) {
      _handleError('Error fetching patients: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDoctors();
    fetchPatients();
  }

  // Function to handle error and show SnackBar
  void _handleError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Function to open the date picker and select a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Prevent selecting past dates
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      // Format the selected date into the desired format
      appointmentDateController.text =
          DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }

  Future<void> addAppointment() async {
    if (_formKey.currentState!.validate()) {
      if (selectedDoctorId == null || selectedPatientId == null) {
        _handleError('Doctor and Patient are required');
        return;
      }

      // Log the selected IDs
      print('Doctor ID: $selectedDoctorId');
      print('Patient ID: $selectedPatientId');
      print('Appointment Date: ${appointmentDateController.text}');
      print('Appointment Status: $selectedStatus');

      try {
        final response = await http.post(
          Uri.parse('$BASE_URLS/appointments/add'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'doctorId': int.parse(selectedDoctorId!),
            'patientId': int.parse(selectedPatientId!),
            'appointmentDate': appointmentDateController.text,
            'status': selectedStatus,
          }),
        );

        // Log the status code and response body for debugging
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Appointment added successfully')),
          );
          Navigator.pop(context);
        } else {
          _handleError(
              'Failed to add appointment. Status: ${response.statusCode}. Body: ${response.body}');
        }
      } catch (e) {
        // Log the error
        print('Error adding appointment: $e');
        _handleError('Error adding appointment: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Dropdown for selecting Doctor
              doctors.isEmpty
                  ? CircularProgressIndicator() // Show loading indicator while fetching doctors
                  : DropdownButtonFormField<String>(
                      value: selectedDoctorId,
                      decoration: InputDecoration(labelText: 'Doctor'),
                      items: doctors.map((doctor) {
                        return DropdownMenuItem<String>(
                          value: doctor['id']
                              .toString(), // Store the doctor ID as the value
                          child:
                              Text(doctor['name']), // Display the doctor's name
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDoctorId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a doctor' : null,
                    ),

              SizedBox(height: 16),
              // Dropdown for selecting Patient
              patients.isEmpty
                  ? CircularProgressIndicator() // Show loading indicator while fetching patients
                  : DropdownButtonFormField<String>(
                      value: selectedPatientId,
                      decoration: InputDecoration(labelText: 'Patient'),
                      items: patients.map((patient) {
                        return DropdownMenuItem<String>(
                          value: patient['id']
                              .toString(), // Store the patient ID as the value
                          child: Text(
                              patient['name']), // Display the patient's name
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPatientId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a patient' : null,
                    ),

              SizedBox(height: 16),
              // Text Field for Appointment Date with DatePicker
              TextFormField(
                controller: appointmentDateController,
                decoration: InputDecoration(labelText: 'Appointment Date'),
                keyboardType: TextInputType.datetime,
                readOnly:
                    true, // Makes the text field read-only to trigger the date picker
                validator: (value) =>
                    value!.isEmpty ? 'Appointment Date is required' : null,
                onTap: () => _selectDate(context), // Trigger the date picker
              ),
              SizedBox(height: 16),
              // Dropdown for selecting Status (Pending, Cancelling, Confirmed)
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(labelText: 'Status'),
                items: ['Pending', 'Cancelling', 'Confirmed'].map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a status' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: addAppointment,
                child: Text('Add Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
