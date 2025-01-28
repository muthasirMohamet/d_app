import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddCustomerScreen extends StatefulWidget {
  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _placeOfBirthController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _addCustomer() async {
    const userId = '123'; // Replace this with the actual logged-in user's ID
    final newCustomer = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'dob': _dobController.text,
      'place_of_birth': _placeOfBirthController.text,
      'userId': userId, // Include userId in the request body
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.100.37:3000/customers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newCustomer),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Customer added successfully!')),
        );
        Navigator.pop(context);
      } else {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to add customer: ${responseData['error']}')),
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
      appBar: AppBar(title: Text("Add Customer")),
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
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter an address' : null,
              ),
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(labelText: 'Date of Birth'),
                keyboardType: TextInputType.datetime,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter date of birth'
                    : null,
              ),
              TextFormField(
                controller: _placeOfBirthController,
                decoration: InputDecoration(labelText: 'Place of Birth'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter place of birth'
                    : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addCustomer();
                  }
                },
                child: Text("Add Customer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
