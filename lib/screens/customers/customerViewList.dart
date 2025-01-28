import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'editCustomer.dart';

class CustomerManagementScreen extends StatefulWidget {
  @override
  _CustomerManagementScreenState createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  List<dynamic> customers = []; // Stores customer data
  bool isLoading = true; // Loading indicator

  @override
  void initState() {
    super.initState();
    fetchCustomers(); // Fetch customer data when the screen loads
  }

  Future<void> fetchCustomers() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.100.37:3000/customers/all'), // API endpoint for customers
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          customers = data;
          isLoading = false;
        });
      } else {
        print('Failed to fetch customers');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching customers: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteCustomer(String customerId, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'http://192.168.100.37:3000/customers/$customerId?userId=$userId'), // Include userId as a query parameter
      );

      if (response.statusCode == 200) {
        setState(() {
          customers.removeWhere(
              (customer) => customer['id'].toString() == customerId);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Customer deleted successfully'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to delete customer'),
        ));
      }
    } catch (e) {
      print('Error deleting customer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(
                  context, '/customers/add'); // Navigate to add customer screen
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // Loading indicator
            : customers.isEmpty
                ? Center(child: Text('No customers found'))
                : ListView.builder(
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return ListTile(
                        title: Text(customer['name']),
                        subtitle: Text(customer['email']),
                        leading: Icon(Icons.person),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            final customerId = customer['id'];
                            const userId =
                                '123'; // Replace with the actual logged-in user's ID

                            if (customerId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Invalid customer ID')),
                              );
                            } else {
                              deleteCustomer(
                                  customerId.toString(), userId); // Pass userId
                            }
                          },
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditCustomerScreen(customer: customer),
                            ),
                          );
                          if (result == true) {
                            fetchCustomers(); // Refresh the list after editing
                          }
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
