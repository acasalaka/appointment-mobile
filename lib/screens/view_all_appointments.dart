import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:appointment_mobile/utils/reusable_widget.dart';
import 'package:appointment_mobile/model/appointment.dart';
import 'package:appointment_mobile/utils/jwt_utils.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  List<Appointment>? appointmentList;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAppointment();
  }

  // Method to fetch appointments
  Future<void> fetchAppointment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        print('Token is null. Please log in.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No valid token found. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
          appointmentList = [];
        });
        return;
      }

      // Decode the token and check the role
      String? role = await getRoleFromJwt();
      print('Current role: $role');

      // If role is admin or hr, restrict access to appointment data
      if (role != "PATIENT") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your role does not have access to Appointment data.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
          appointmentList = [];
        });
        return;
      }

      // Fetch userId using the getIdFromUser() method
      String? userId = await getIdFromUser();
      if (userId == null) {
        print('Failed to fetch user ID');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch user ID.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
          appointmentList = [];
        });
        return;
      }

      // Fetch appointment data if the role is allowed
      final response = await http.get(
        Uri.parse('http://localhost:8081/api/appointment/by-patient?idPatient=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        setState(() {
          appointmentList = data.map((item) => Appointment.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        print('Failed to fetch appointments: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch appointments.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
          appointmentList = [];
        });
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
        appointmentList = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ApapMedika Mobile - Appointment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              showLogoutDialog(context);  // Assuming you have a reusable showLogoutDialog method
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : appointmentList == null || appointmentList!.isEmpty
          ? const Center(child: Text('Your role does not have access to Appointment data.'))
          : ListView.builder(
        itemCount: appointmentList!.length,
        itemBuilder: (context, index) {
          final appointment = appointmentList![index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(appointment.id),
              subtitle: Text(appointment.date.toString()),
              trailing: Text(appointment.status),
            ),
          );
        },
      ),
    );
  }
}
