import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditCustomerScreen extends StatefulWidget {
  final Map<String, dynamic> customer;

  EditCustomerScreen({required this.customer});

  @override
  _EditCustomerScreenState createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String email;
  late String phone;
  late String address;
  late String dateOfBirth;
  late String placeOfBirth;

  @override
  void initState() {
    super.initState();
    // Initialize fields with existing customer data
    name = widget.customer['name'] ?? '';
    email = widget.customer['email'] ?? '';
    phone = widget.customer['phone'] ?? '';
    address = widget.customer['address'] ?? '';
    dateOfBirth = widget.customer['date_of_birth'] ?? '';
    placeOfBirth = widget.customer['place_of_birth'] ?? '';
  }

  Future<void> updateCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final customerId = widget.customer['id'];
    try {
      final response = await http.put(
        Uri.parse('http://192.168.100.37:3000/customers/$customerId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'date_of_birth': dateOfBirth,
          'place_of_birth': placeOfBirth,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Customer updated successfully')),
        );
        Navigator.pop(context, true); // Pass true to refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update customer')),
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
      appBar: AppBar(
        title: Text('Edit Customer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
                onSaved: (value) => email = value!,
              ),
              TextFormField(
                initialValue: phone,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
                onSaved: (value) => phone = value!,
              ),
              TextFormField(
                initialValue: address,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
                onSaved: (value) => address = value!,
              ),
              TextFormField(
                initialValue: dateOfBirth,
                decoration: InputDecoration(labelText: 'Date of Birth'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date of birth';
                  }
                  return null;
                },
                onSaved: (value) => dateOfBirth = value!,
              ),
              TextFormField(
                initialValue: placeOfBirth,
                decoration: InputDecoration(labelText: 'Place of Birth'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a place of birth';
                  }
                  return null;
                },
                onSaved: (value) => placeOfBirth = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateCustomer,
                child: Text('Update Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
