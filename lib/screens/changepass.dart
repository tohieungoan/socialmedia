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

class Changepass extends StatefulWidget {
  const Changepass({Key? key}) : super(key: key);

  @override
  _Changepass createState() => _Changepass();
}

class _Changepass extends State<Changepass> {
  SharedPreferences? sharedPref;
  String? email;
  final newpassword = TextEditingController();
  final password2 = TextEditingController();
  String ip = MyApp.ipv4;
  @override
  void dispose() {
    super.dispose();
    newpassword.dispose();
    password2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    TextEditingController controller = TextEditingController();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('img/background2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: w * 0.1,
              height: h * 0.06,
              margin: EdgeInsets.only(top: 20, bottom: 0, left: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.grey[600],
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Forgetpassword()),
                  );
                },
                child: Icon(
                  Icons.arrow_back_sharp,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              width: w,
              margin: const EdgeInsets.only(left: 20, right: 20, top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Change your password",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 7,
                          offset: Offset(1, 1),
                          color: Colors.grey.withOpacity(0.7),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 10,
                                      spreadRadius: 7,
                                      offset: Offset(1, 1),
                                      color: Colors.grey.withOpacity(0.7))
                                ]),
                            child: ShowHidePasswordTextField(
                              controller: newpassword,
                              fontStyle: const TextStyle(
                                fontSize: 18,
                              ),
                              hintColor: Colors.black,
                              iconSize: 20,
                              visibleOffIcon: Icons.remove_red_eye_outlined,
                              visibleOnIcon: Icons.remove_red_eye_rounded,
                              decoration: InputDecoration(
                                isDense: true,
                                prefixIcon: Icon(Icons.lock),
                                hintText: 'Enter the password',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                        color: Colors.black38,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.black12, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.black38, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )),
                        Divider(),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 10,
                                      spreadRadius: 7,
                                      offset: Offset(1, 1),
                                      color: Colors.grey.withOpacity(0.7))
                                ]),
                            child: ShowHidePasswordTextField(
                              controller: password2,
                              fontStyle: const TextStyle(
                                fontSize: 18,
                              ),
                              hintColor: Colors.black,
                              iconSize: 20,
                              visibleOffIcon: Icons.remove_red_eye_outlined,
                              visibleOnIcon: Icons.remove_red_eye_rounded,
                              decoration: InputDecoration(
                                isDense: true,
                                prefixIcon: Icon(Icons.lock),
                                hintText: 'Enter the password again',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                        color: Colors.black38,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.black12, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.black38, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.blue[50],
                                ),
                                onPressed: () {
                                  savenewpass();
                                },
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Future<Post2?> savenewpass() async {
    if (newpassword.text != password2.text) {
      thongbao("Mật khẩu xác nhận chưa trùng lập");
    } else if (newpassword.text.length < 9) {
      return thongbao("Password to short");
    } else {
      final url = Uri.parse("$ip/api/changepass");
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
        "password": newpassword.text,
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
      } else if (response.statusCode == 201) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String errorMessage = jsonResponse['message'];
        thongbao(errorMessage);
        return Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomePage()),
        );
      } else if (response.statusCode == 404) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String errorMessage = jsonResponse['message'];
        thongbao(errorMessage);
        return Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomePage()),
        );
      } else {
        print(response.statusCode);
        throw Exception("failed");
      }
    }
  }
}
