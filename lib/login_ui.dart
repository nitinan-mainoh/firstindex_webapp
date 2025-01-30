// ignore_for_file: prefer_final_fields, sized_box_for_whitespace

import 'package:firstindex_webapp/index.dart';
import 'package:firstindex_webapp/register.dart';
import 'package:firstindex_webapp/sharedata.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginUi extends StatefulWidget {
  const LoginUi({super.key});

  @override
  State<LoginUi> createState() => _LoginUiState();
}

class _LoginUiState extends State<LoginUi> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Map<String, dynamic>? userData;
  String _errorMessage = '';
  bool _isLoading = false; // Loading state
  bool _isLoadingFP = false;
  bool _isObscure = true; // กำหนดสะถานนะเปิดปิดการมองเห็น password

  Future<void> loadUserData() async {
    final datainfo = await fetchUserData(context);
    if (datainfo != null) {
      setState(() {
        userData = datainfo;
      });
    }
  }

  // Show Success Message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.green))),
    );
  }

  // ฟังก์ชั่นส่งอีเมลเพื่อรีเซ็ตรหัสผ่าน
  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorMessage("กรุณากรอกอีเมลเพื่อขอรหัสผ่านใหม่");
      return;
    }

    setState(() {
      _isLoadingFP = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${CallAPI.hostURL}/sendpasswordemail'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        _showSuccessMessage("เราได้ส่งอีเมลสำหรับรีเซ็ตรหัสผ่านไปยัง $email");
      } else if (response.statusCode == 404) {
        _showErrorMessage("ไม่พบอีเมลนี้ในระบบ");
      } else {
        _showErrorMessage("เกิดข้อผิดพลาด: ${response.body}");
      }
    } catch (e) {
      _showErrorMessage("ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์: $e");
    } finally {
      setState(() {
        _isLoadingFP = false;
      });
    }
  }

  void _validateEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@(gmail\.com|hotmail\.com|live\.com|yahoo\.com)$',
    );
    setState(() {
      if (_emailController.text.isEmpty) {
        _errorMessage = "กรุณาใส่ Email ด้วย ";
      } else if (!emailRegExp.hasMatch(email)) {
        _errorMessage = "รูปแบบ Email ไม่ถูกต้อง, เช่น example@gmail.com";
      } else {
        _errorMessage = "";
      }
    });
  }

  Future<void> _login() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true; // Start loading
    });

    try {
      final response = await http.post(
        Uri.parse('${CallAPI.hostURL}/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "email": _emailController.text,
          "password": _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.setString('auth_token', token);

        // ใช้สถานะ 200 สำหรับการล็อกอินสำเร็จ
        // set login state เป็น true เมื่อ Login สำเร็จ
        Provider.of<LoginState>(context, listen: false).logIn();
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Index()),
        );
      } else if (response.statusCode == 401) {
        _showErrorMessage("อีเมลหรือรหัสผ่านไม่ถูกต้อง");
      } else {
        _showErrorMessage("การล็อกอินล้มเหลว โปรดลองอีกครั้ง");
      }
    } catch (e) {
      _showErrorMessage("ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์: $e");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width < 900
        ? MediaQuery.of(context).size.width * 0.7
        : MediaQuery.of(context).size.width * 0.45;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[800],
        title: Center(
          child: Text(
            "FIRST INDEX",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.025,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: MediaQuery.of(context).size.height * 0.075,
        color: Colors.grey[300],
        child: Center(
          child: Text(
            'First Index © 2024',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.02,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: containerWidth,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.035),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/icon/icon.png',
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: MediaQuery.of(context).size.width * 0.15,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Text(
                  'ลงชื่อเข้าสู่ระบบ',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.025,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan[900],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email Address",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                      color: Colors.cyan[800],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                TextField(
                  controller: _emailController,
                  onChanged: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.022,
                    color: Colors.cyan[900],
                  ),
                  decoration: InputDecoration(
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.cyan, width: 3),
                    ),
                    errorText: _errorMessage.isEmpty ? null : _errorMessage,
                    errorStyle: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.018,
                      color: Colors.redAccent,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.cyan, width: 3),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.cyan, width: 3),
                    ),
                    prefixIcon: Icon(
                      Icons.email_rounded,
                      size: MediaQuery.of(context).size.height * 0.030,
                      color: Colors.cyan[900],
                    ),
                    hintText: "example@gmail.com",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Password",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                      color: Colors.cyan[800],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                TextField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.022,
                    color: Colors.cyan[900],
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.cyan, width: 3),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.cyan, width: 3),
                    ),
                    prefixIcon: Icon(
                      Icons.key_rounded,
                      size: MediaQuery.of(context).size.height * 0.030,
                      color: Colors.cyan[900],
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.remove_red_eye_rounded,
                        size: MediaQuery.of(context).size.height * 0.030,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                    hintText: "Password",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.045),
                Row(
                  children: [
                    _isLoading
                        ? Container(
                            width: MediaQuery.of(context).size.width * 0.275,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Colors.cyan[800],
                                  strokeWidth: 2,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  "Logging in...",
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.022,
                                    color: Colors.cyan[800],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan[800],
                              shadowColor: Colors.black,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              fixedSize: Size(
                                MediaQuery.of(context).size.width * 0.275,
                                MediaQuery.of(context).size.height * 0.06,
                              ),
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.022,
                                color: Colors.white,
                              ),
                            ),
                          ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.010),
                    //ปุ่มลืมรหัสผ่าน
                    _isLoadingFP
                        ? Container(
                            width: MediaQuery.of(context).size.width * 0.165,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Colors.cyan[800],
                                  strokeWidth: 2,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  "Sending email...",
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.022,
                                    color: Colors.cyan[800],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              _forgotPassword();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                  color: Colors.cyan[800]!, width: 2),
                              shadowColor: Colors.black,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              fixedSize: Size(
                                MediaQuery.of(context).size.width * 0.165,
                                MediaQuery.of(context).size.height * 0.06,
                              ),
                            ),
                            child: Text(
                              "Forgot Password ?",
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.022,
                                color: Colors.cyan[800],
                              ),
                            ),
                          ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Don't have an Account ?",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.0175,
                      // fontWeight: FontWeight.bold,
                      color: Colors.cyan[800],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterUi(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.cyan[800]!, width: 2),
                    shadowColor: Colors.black,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fixedSize: Size(
                      MediaQuery.of(context).size.width * 0.975,
                      MediaQuery.of(context).size.height * 0.06,
                    ),
                  ),
                  child: Text(
                    "Register",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.022,
                      color: Colors.cyan[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
