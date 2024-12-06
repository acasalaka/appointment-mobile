import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

// Get role from JWT by decoding and fetching details from backend
Future<String?> getRoleFromJwt() async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('jwt_token');

  if (token == null) {
    print('No token found');
    return null;
  }

  try {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String? email = decodedToken['sub']; // Assuming 'sub' holds the email

    if (email == null) {
      print('No email found in token');
      return null;
    }

    // Fetch user details using email to get role
    final role = await fetchUserRoleByEmail(email);

    if (role != null) {
      return role;
    } else {
      print('Failed to fetch role for email: $email');
      return null;
    }
  } catch (e) {
    print("Error decoding JWT: $e");
    return null;
  }
}

// Fetch user role by email
Future<String?> fetchUserRoleByEmail(String email) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) {
      print('No token found');
      return null;
    }

    final response = await http.get(
      Uri.parse('http://localhost:8084/api/user/detail/$email'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Extract role from the response data
      String role = data['data']['role'];
      return role;
    } else {
      print('Failed to fetch user details: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching user details: $e');
    return null;
  }
}

// New function to fetch userId from the backend
Future<String?> getIdFromUser() async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('jwt_token');

  if (token == null) {
    print('No token found');
    return null;
  }

  try {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String? email = decodedToken['sub']; // Assuming 'sub' holds the email

    if (email == null) {
      print('No email found in token');
      return null;
    }

    // Fetch user details using email to get userId
    final userId = await fetchUserIdByEmail(email);

    if (userId != null) {
      return userId;
    } else {
      print('Failed to fetch userId for email: $email');
      return null;
    }
  } catch (e) {
    print("Error decoding JWT: $e");
    return null;
  }
}

// Fetch userId by email from backend
Future<String?> fetchUserIdByEmail(String email) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) {
      print('No token found');
      return null;
    }

    final response = await http.get(
      Uri.parse('http://localhost:8084/api/user/detail/$email'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Extract userId from the response data
      String userId = data['data']['id'];
      return userId;
    } else {
      print('Failed to fetch user details: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching user details: $e');
    return null;
  }
}
