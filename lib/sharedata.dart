// ignore_for_file: unused_element

import 'package:firstindex_webapp/login_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginState extends ChangeNotifier {
  bool _userLogin = false;

  bool get userLogin => _userLogin;

  void logIn() {
    _userLogin = true;
    notifyListeners();
  }

  void logOut() {
    _userLogin = false;
    notifyListeners();
  }
}

class CallAPI {
  static String hostURL = 'http://192.168.56.1:3000'; // Work PC
  // static String hostURL = 'http://192.168.1.10:3000'; // Home PC
  // static String hostURL = 'http://192.168.1.15:3000'; // Home Notbook
}

Future<Map<String, dynamic>?> fetchUserData(BuildContext context) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  final token = preferences.getString('auth_token');
  if (token == null) {
    return {"error": "User is not logged in"};
  }

  try {
    final response = await http.get(
      Uri.parse('${CallAPI.hostURL}/userinfo'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      await logout(context);
      return null;
    } else {
      return {"error": "Failed to load user data"};
    }
  } catch (e) {
    return {"error": "Error fetching user data: $e"};
  }
}

Future<void> logout(BuildContext context) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.remove('auth_token');

  // อัพเดตสถานะการล็อกอินใน LoginState
  Provider.of<LoginState>(context, listen: false).logOut();

  // นำทางไปยังหน้าล็อกอิน
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => LoginUi(),
    ),
  );
}

/// ฟังก์ชันสำหรับแปลง Base64 เป็น Widget ของรูปภาพ
Widget buildImageFromBase64(String base64Image, {BoxFit fit = BoxFit.cover}) {
  try {
    final cleanedBase64 =
        base64Image.contains(',') ? base64Image.split(',').last : base64Image;

    String paddedBase64 = cleanedBase64;
    while (paddedBase64.length % 4 != 0) {
      paddedBase64 += '=';
    }

    final decodedBytes = base64Decode(paddedBase64);
    return Image.memory(decodedBytes, fit: fit);
  } catch (e) {
    print("Error decoding base64 image: $e");
    return Image.asset('assets/images/cover/novel1.jpg', fit: fit);
  }
}
