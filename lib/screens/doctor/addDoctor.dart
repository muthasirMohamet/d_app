import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';

class AddDoctorScreen extends StatefulWidget {
  @override
  _AddDoctorScreenState createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> addDoctor() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('$BASE_URLS/doctors/add'),
          headers: {
            'Content-Type': 'application/json',
            // No token here, since it's not required by the backend
          },
          body: jsonEncode({
            'name': nameController.text,
            'specialization': specializationController.text,
            'email': emailController.text,
            'phoneNumber': phoneController.text,
            'rating': double.tryParse(ratingController.text) ?? 0.0,
            'password': passwordController.text,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Doctor added successfully')),
          );
          Navigator.pop(context); // Go back after successful addition
        } else {
          print('Response: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add doctor: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Doctor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Name is required' : null,
              ),
              TextFormField(
                controller: specializationController,
                decoration: InputDecoration(labelText: 'Specialization'),
                validator: (value) => value!.isEmpty ? 'Specialization is required' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Email is required' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) => value!.isEmpty ? 'Phone number is required' : null,
              ),
              TextFormField(
                controller: ratingController,
                decoration: InputDecoration(labelText: 'Rating'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Rating is required' : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Password is required' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: addDoctor,
                child: Text('Add Doctor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
