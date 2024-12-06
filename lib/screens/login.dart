import 'package:appointment_mobile/utils/jwt_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appointment_mobile/screens/view_all_appointments.dart';

class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    final email = emailController.text;
    final password = passwordController.text;

    try {
      print('Attempting to log in with username: $email');
      final response = await http.post(
        Uri.parse('http://localhost:8084/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['data']['token'];

        // Store the token in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);  // Save the token

        // Decode the JWT token
        final decodedToken = _decodeJwt(token);
        print('Decoded Token di login: $decodedToken');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hello, ${decodedToken['sub']}')),
        );

        // Get the email from the JWT token
        String email = decodedToken['sub'];

        // Fetch the role from the JWT token
        String? role = await getRoleFromJwt();  // Directly use your utility method
        print('Current role: $role');

        // Fetch the role from the server (if needed)
        if (role == null) {
          role = await fetchUserRoleByEmail(email);  // Fetch role from server if it's null
          print('Fetched role from server: $role');
        }

        // Navigate to the next screen (AppointmentScreen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AppointmentScreen()),
        );
      } else {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
        print('Login failed with message: ${response.body}');
      }
    } catch (error) {
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    }
  }

  // Decode JWT token to extract useful information
  Map<String, dynamic> _decodeJwt(String token) {
    List<String> parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid JWT token');
    }

    String payload = parts[1];
    String normalized = base64Url.normalize(payload);
    String decoded = utf8.decode(base64Url.decode(normalized));

    Map<String, dynamic> decodedToken = json.decode(decoded);
    return decodedToken;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ApapMedika'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Welcome to ApapMedika!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: emailController,
                    autofocus: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      contentPadding:
                      const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: passwordController,
                    autofocus: false,
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      contentPadding:
                      const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(30.0),
                      shadowColor: Colors.lightBlueAccent.shade100,
                      elevation: 5.0,
                      child: MaterialButton(
                        minWidth: 200.0,
                        height: 42.0,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            login();
                          }
                        },
                        color: Colors.lightBlueAccent,
                        child: const Text('Log In',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}