import 'package:flutter/material.dart';
import 'package:appointment_mobile/screens/login.dart';

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Confirm Log Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                    const LoginFormScreen()),
              );
            },
            child: const Text(
              'Log out',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      );
    },
  );
}
