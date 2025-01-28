import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';
import '../../models/appointment_model.dart';
import 'appointment_details_screen.dart';
import 'new_appointment_screen.dart';

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
    try {
      final response = await http.get(Uri.parse('$BASE_URLS/appointments'));
      if (response.statusCode == 200) {
        print('Response body: ${response.body}'); // Log the raw API response
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Appointment.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load appointments, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    try {
      final response = await http
          .delete(Uri.parse('$BASE_URLS/appointments/$appointmentId'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment deleted successfully')),
        );
        setState(() {
          futureAppointments = fetchAppointments();
        });
      } else {
        throw Exception('Failed to delete appointment');
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
              title: Text('Confirm Deletion'),
              content:
                  Text('Are you sure you want to delete this appointment?'),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Delete')),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddAppointmentScreen()),
              ).then((_) =>
                  setState(() => futureAppointments = fetchAppointments()));
            },
          ),
        ],
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
                title: Text(
                    'Doctor: ${appointment.doctorId ?? 'No doctor assigned'}'),
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
                        // Show the dialog for editing the appointment
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Edit Appointment'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Doctor: ${appointment.doctorId ?? 'No doctor assigned'}'),
                                    Text(
                                        'Patient: ${appointment.patientId ?? 'No patient assigned'}'),
                                    Text(
                                        'Date: ${appointment.appointmentDate ?? 'No date available'}'),
                                    Text(
                                        'Status: ${appointment.status ?? 'No status available'}'),
                                    // Add text fields or dropdowns for editing details
                                    TextField(
                                      controller: TextEditingController(
                                          text: appointment.status),
                                      decoration: InputDecoration(
                                          labelText: 'Edit Status'),
                                    ),
                                    // You can add other input fields here for editing other appointment details
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    // Close the dialog without making changes
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Submit the changes (you can make API calls here)
                                    // For now, close the dialog
                                    Navigator.pop(context);
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
                        bool confirmed =
                            await _showDeleteConfirmationDialog(context);
                        if (confirmed) {
                          await deleteAppointment(appointment.id.toString());
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
