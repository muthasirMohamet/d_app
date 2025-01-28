import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import 'addDoctor.dart';
import 'updateDoctor.dart';

class ViewListDoctorsScreen extends StatefulWidget {
  @override
  _ViewListDoctorsScreenState createState() => _ViewListDoctorsScreenState();
}

class _ViewListDoctorsScreenState extends State<ViewListDoctorsScreen> {
  List<dynamic> doctors = [];

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    try {
      final response =
          await http.get(Uri.parse('${BASE_URLS}/doctors'));

      if (response.statusCode == 200) {
        setState(() {
          doctors = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch doctors')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> deleteDoctor(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${BASE_URLS}/doctors/$id'),
      );

      if (response.statusCode == 200) {
        setState(() {
          doctors.removeWhere((doctor) => doctor['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doctor deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete doctor: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> updateDoctor(Map<String, dynamic> doctor) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditDoctorScreen(doctor: doctor), // Navigate to UpdateDoctorScreen
      ),
    ).then((_) {
      fetchDoctors(); // Refresh the list after returning from UpdateDoctorScreen
    });
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Doctor'),
        content: Text('Are you sure you want to delete this doctor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteDoctor(id);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctors'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddDoctorScreen()),
              ).then((_) {
                fetchDoctors(); // Refresh the list after adding a new doctor
              });
            },
          ),
        ],
      ),
      body: doctors.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                final doctorName = doctor['name'] ?? 'Unknown Name';
                final doctorSpecialization =
                    doctor['specialization'] ?? 'No Specialization';
                final doctorId = doctor['id'] ?? 0;

                return ListTile(
                  title: Text(doctorName),
                  subtitle: Text(doctorSpecialization),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed:
                            doctorId > 0 ? () => updateDoctor(doctor) : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: doctorId > 0
                            ? () => _confirmDelete(doctorId)
                            : null,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
