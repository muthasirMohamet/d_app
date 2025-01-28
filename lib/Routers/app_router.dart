import 'package:flutter/material.dart';
// login_screen.dart
import '../screens/auth/login_screen.dart';
// register_screen.dart and user_register_screen.dart
import '../screens/Users/UserListScreen.dart';
import '../screens/Users/user_register_screen.dart';
//appointment_screen.dart and new_appointment_screen.dart
import '../screens/appointments/appointment_screen.dart';
import '../screens/appointments/new_appointment_screen.dart';
// customer_screen.dart and add_customer_screen.dart
import '../screens/customers/addCustomer.dart';
import '../screens/customers/customerViewList.dart';
import '../screens/customers/editCustomer.dart';
// doctor_screen.dart and add_doctor_screen.dart
import '../screens/doctor/addDoctor.dart';
import '../screens/doctor/viewListDoctors.dart';
// Admin_Portal.dart and Patient_Portal and Staff_Portal.dart
import '../screens/home/adminPortal.dart';
import '../screens/home/patientPortal.dart';
import '../screens/home/staffPortal.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/user/register':
        return MaterialPageRoute(builder: (_) => UserRegisterScreen());
      case '/user/view':
        return MaterialPageRoute(builder: (_) => UserViewScreen());
      case '/view/doctors':
        return MaterialPageRoute(builder: (_) => ViewListDoctorsScreen());
      case '/doctors/add':
        return MaterialPageRoute(builder: (_) => AddDoctorScreen());
      case '/cutomers/edit':
        return MaterialPageRoute(
            builder: (_) => EditCustomerScreen(
                  customer: {},
                ));
      case '/cutomers/view':
        return MaterialPageRoute(builder: (_) => CustomerManagementScreen());
      case '/customers/add':
        return MaterialPageRoute(
            builder: (_) => AddCustomerScreen()); // Register new doctor
      case '/register/new_appointment':
        return MaterialPageRoute(
          builder: (_) => AddAppointmentScreen(),
        );
      case '/view/appointments':
        return MaterialPageRoute(
          builder: (_) => AppointmentListScreen(),
        );
      case '/adminPortal':
        return MaterialPageRoute(builder: (_) => AdminPortalScreen());
      case '/staffPortal':
        return MaterialPageRoute(builder: (_) => StaffPortalScreen());
      case '/patientPortal':
        return MaterialPageRoute(builder: (_) => PatientPortalScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
