import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmediaapp/main.dart';
import 'package:socialmediaapp/models/Post.dart';
import 'package:socialmediaapp/screens/forgetpassword.dart';
import 'package:show_hide_password/show_hide_password.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:socialmediaapp/screens/hello_login.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreen createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  SharedPreferences? sharedPref;
  String? email;
  String ip = MyApp.ipv4;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: w,
              margin: const EdgeInsets.only(left: 20, right: 20, top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Menu",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 350, // Adjust the width as needed
                  height: 50, // Adjust the height as needed
                  child: TextButton.icon(
                    onPressed: () {
                      _logout();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.grey.shade300),
                    ),
                    label: Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String> fetchCsrfToken() async {
    final response = await http.get(Uri.parse('$ip/csrf-token'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['csrf_token'];
    } else {
      throw Exception('Failed to fetch CSRF token');
    }
  }

  thongbao(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<Post2?> _logout() async {
    final url = Uri.parse("$ip/api/logout");
    String tokendata = await fetchCsrfToken();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-CSRF-TOKEN': tokendata
    };
    sharedPref = await SharedPreferences.getInstance();

    setState(() {
      email = sharedPref?.getString("email");
    });
    Map<String, dynamic> request = {
      "email": email,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(request),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      String Messagec = jsonResponse['message'];
      thongbao(Messagec);
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomePage()),
      );
    } else if (response.statusCode == 404) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      String errorMessage = jsonResponse['message'];
      thongbao(errorMessage);
    } else {
      print(response.statusCode);
      throw Exception("failed");
    }
  }
}
