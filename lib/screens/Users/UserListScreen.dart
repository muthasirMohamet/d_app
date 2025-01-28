import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';

// Replace with your actual server URL

class UserViewScreen extends StatefulWidget {
  const UserViewScreen({super.key});

  @override
  _UserViewScreenState createState() => _UserViewScreenState();
}

class _UserViewScreenState extends State<UserViewScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  final String url = "$BASE_URLS/users";

  // Fetch all users from the server
  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(json.decode(response.body));
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch users");
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $e')),
      );
    }
  }

  Future<void> _deleteUser(int userId) async {
    try {
      final response = await http.delete(Uri.parse("$BASE_URLS/users/$userId"));
      if (response.statusCode == 200) {
        setState(() {
          _users.removeWhere((user) => user['id'] == userId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User deleted successfully!')),
        );
      } else {
        throw Exception("Failed to delete user");
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }

  // Navigate to the Edit User screen
  void _goToEditUserScreen(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserScreen(user: user),
      ),
    ).then((_) => _fetchUsers());
  }

  void _confirmDelete(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete ${user['name']}?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deleteUser(user['id']);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Users")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _users.map((user) {
                  return DataRow(
                    cells: [
                      DataCell(Text(user['id'].toString())),
                      DataCell(Text(user['name'])),
                      DataCell(Text(user['email'])),
                      DataCell(Text(user['role'])),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _goToEditUserScreen(user),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _confirmDelete(user);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}

class EditUserScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  EditUserScreen({required this.user});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late String name;
  late String email;
  late String phoneNumber;
  late String role;
  late String password;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    name = widget.user['name'];
    email = widget.user['email'];
    phoneNumber = widget.user['phoneNumber'];
    role = widget.user['role'];
    password = widget.user['password'];
  }

  Future<void> _updateUser() async {
    final updatedUser = {
      'id': widget.user['id'],
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'password': password,
    };

    try {
      final response = await http.put(
        Uri.parse("$BASE_URLS/users/${widget.user['id']}"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedUser),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User updated successfully!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Failed to update user");
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit User")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (value) => name = value!,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a name' : null,
              ),
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(labelText: 'Email'),
                onSaved: (value) => email = value!,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter an email' : null,
              ),
              TextFormField(
                initialValue: phoneNumber,
                decoration: InputDecoration(labelText: 'Phone Number'),
                onSaved: (value) => phoneNumber = value!,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter a phone number'
                    : null,
              ),
              DropdownButtonFormField(
                value: role,
                decoration: InputDecoration(labelText: 'Role'),
                items: ['Patient', 'Doctor', 'Staff', 'Admin'].map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (value) => role = value!,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Select a role' : null,
              ),
              TextFormField(
                initialValue: password,
                decoration: InputDecoration(labelText: 'Password'),
                onSaved: (value) => password = value!,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a password' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _updateUser();
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
