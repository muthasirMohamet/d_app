import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config.dart';

class EditDoctorScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  EditDoctorScreen({required this.doctor});

  @override
  _EditDoctorScreenState createState() => _EditDoctorScreenState();
}

class _EditDoctorScreenState extends State<EditDoctorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _specializationController;
  late TextEditingController _ratingController;
  late TextEditingController _passwordController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Initialize controllers with the doctor's data
    _nameController = TextEditingController(text: widget.doctor['name'] ?? '');
    _emailController =
        TextEditingController(text: widget.doctor['email'] ?? '');
    _phoneController =
        TextEditingController(text: widget.doctor['phoneNumber'] ?? '');
    _specializationController =
        TextEditingController(text: widget.doctor['specialization'] ?? '');
    _ratingController =
        TextEditingController(text: widget.doctor['rating']?.toString() ?? '0');
    _passwordController =
        TextEditingController(text: widget.doctor['password'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _ratingController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateDoctor() async {
    final updatedDoctor = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phoneNumber': _phoneController.text,
      'specialization': _specializationController.text,
      'rating': double.tryParse(_ratingController.text) ?? 0,
      'password': _passwordController.text,
      'userId': 'adminUserId123', // Replace this with the actual user ID
    };

    try {
      final response = await http.put(
        Uri.parse('${BASE_URLS}/doctors/${widget.doctor['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedDoctor),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doctor updated successfully!')),
        );
        Navigator.pop(context); // Go back to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update doctor')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Doctor")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter an email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter a phone number'
                    : null,
              ),
              TextFormField(
                controller: _specializationController,
                decoration: InputDecoration(labelText: 'Specialization'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter a specialization'
                    : null,
              ),
              TextFormField(
                controller: _ratingController,
                decoration: InputDecoration(labelText: 'Rating'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                        ? 'Enter a valid rating'
                        : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a password' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateDoctor();
                  }
                },
                child: Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
