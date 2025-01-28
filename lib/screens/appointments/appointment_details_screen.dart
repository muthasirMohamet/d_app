import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';
import '../../models/appointment_model.dart';

void main() {
  runApp(AppointmentApp());
}

class AppointmentApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appointments',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AppointmentListScreen(),
    );
  }
}

class AppointmentListScreen extends StatefulWidget {
  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  late Future<List<Appointment>> futureAppointments;

  @override
  void initState() {
    super.initState();
    futureAppointments = fetchAppointments();
  }

  Future<List<Appointment>> fetchAppointments() async {
    final response = await http.get(Uri.parse('$BASE_URLS/appointments'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((appointment) => Appointment.fromJson(appointment)).toList();
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  Future<void> updateAppointment(
    String appointmentId,
    String doctorId,
    String patientId,
    String appointmentDate,
    String status,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$BASE_URLS/appointments/$appointmentId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'doctor_id': doctorId,
          'patient_id': patientId,
          'appointment_date': appointmentDate,
          'status': status,
          'userId': 'yourUserId', // Replace with actual user ID
        }),
      );

      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment updated successfully')),
        );

        // Re-fetch and refresh the state after update
        setState(() {
          futureAppointments = fetchAppointments(); // Re-fetch appointments
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update appointment')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    try {
      final response = await http.delete(Uri.parse('$BASE_URLS/appointments/$appointmentId'));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment deleted successfully')),
        );
        setState(() {
          futureAppointments = fetchAppointments(); // Re-fetch appointments
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Failed to delete appointment')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Appointment'),
          content: Text('Are you sure you want to delete this appointment?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
      ),
      body: FutureBuilder<List<Appointment>>(
        future: futureAppointments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No appointments found.'));
          }

          final appointments = snapshot.data!;
          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return ListTile(
                title: Text('Doctor: ${appointment.doctorId ?? 'No doctor assigned'}'),
                subtitle: Text(
                  'Patient: ${appointment.patientId ?? 'No patient assigned'}\n'
                  'Date: ${appointment.appointmentDate ?? 'No date available'}\n'
                  'Status: ${appointment.status ?? 'No status available'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            // Form controllers
                            TextEditingController _doctorIdController = TextEditingController(text: appointment.doctorId);
                            TextEditingController _patientIdController = TextEditingController(text: appointment.patientId);
                            TextEditingController _appointmentDateController = TextEditingController(text: appointment.appointmentDate);
                            TextEditingController _statusController = TextEditingController(text: appointment.status);

                            return AlertDialog(
                              title: Text('Edit Appointment'),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    TextField(controller: _doctorIdController, decoration: InputDecoration(labelText: 'Doctor ID')),
                                    TextField(controller: _patientIdController, decoration: InputDecoration(labelText: 'Patient ID')),
                                    TextField(controller: _appointmentDateController, decoration: InputDecoration(labelText: 'Appointment Date')),
                                    TextField(controller: _statusController, decoration: InputDecoration(labelText: 'Status')),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog without saving
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    updateAppointment(
                                      appointment.id.toString(),
                                      _doctorIdController.text,
                                      _patientIdController.text,
                                      _appointmentDateController.text,
                                      _statusController.text,
                                    );
                                    Navigator.pop(context); // Close dialog after saving
                                  },
                                  child: Text('Save Changes'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        bool confirmed = await _showDeleteConfirmationDialog(context);
                        if (confirmed) {
                          deleteAppointment(appointment.id.toString());
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
