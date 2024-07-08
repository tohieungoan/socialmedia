import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmediaapp/main.dart';
import 'package:socialmediaapp/models/Post.dart';
import 'package:socialmediaapp/models/models.dart';
import 'package:socialmediaapp/screens/LoginGithub.dart';
import 'package:socialmediaapp/screens/changepass.dart';
import 'package:socialmediaapp/screens/hello_login.dart';
import 'package:socialmediaapp/config/palette.dart';
import 'package:show_hide_password/show_hide_password.dart';
import 'package:socialmediaapp/screens/login_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:socialmediaapp/screens/logingoogle.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:email_validator/email_validator.dart';
import 'package:socialmediaapp/screens/nav_screen.dart';
import 'package:socialmediaapp/widgets/profile_avatar.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:socialmediaapp/config/palette.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Forgetpassword extends StatefulWidget {
  const Forgetpassword({Key? key}) : super(key: key);

  @override
  _Forgetpassword createState() => _Forgetpassword();
}

class _Forgetpassword extends State<Forgetpassword> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  bool _isButtonDisabled = false;
  int _countdownSeconds = 60;
  late Timer _countdownTimer;
  String ip = MyApp.ipv4;
  @override
  void dispose() {
    super.dispose();
    _countdownTimer.cancel(); // Hủy bỏ hẹn giờ trong quá trình dispose()
    _email.dispose();
  }

  String? email;
  @override
  Widget build(BuildContext context) {
    String buttonLabel =
        _isButtonDisabled ? '$_countdownSeconds s' : 'Get Code';
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
                    MaterialPageRoute(builder: (context) => WelcomePage()),
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
                    "Forgot my password",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.all(10.0),
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
                        TextFormField(
                          controller: _email,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.mail),
                            labelText: 'Email',
                            hintText: 'Enter your email address',
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                            ),
                          ),
                        ),
                        Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _code,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.check_circle_outlined),
                                  labelText: 'OTP Code',
                                  hintText: 'Enter your code',
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.green, width: 1.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            RawMaterialButton(
                              onPressed:
                                  _isButtonDisabled ? null : startCountdown,
                              elevation: 2.0,
                              fillColor: _isButtonDisabled
                                  ? Colors.blue[50]
                                  : Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  buttonLabel,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () {
                            SendOtp();
                          },
                          child: Text(
                            'Next',
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

  Future<Post2?> sendcode() async {
    if (_email.text == "") {
      setState(() {
        _isButtonDisabled = true;
        _countdownSeconds = 3;
      });
      return thongbao("Email cannt be empty");
    } else if (!EmailValidator.validate(_email.text)) {
      setState(() {
        _isButtonDisabled = true;
        _countdownSeconds = 3;
      });
      return thongbao("Wrong email configuration");
    } else {
      final url = Uri.parse("$ip/api/forgotpassword");
      String tokendata = await fetchCsrfToken();
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': tokendata
      };
      Map<String, dynamic> request = {
        "email": _email.text,
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
      } else if (response.statusCode == 404) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String errorMessage = jsonResponse['message'];
        return thongbao(errorMessage);
      } else {
        print(response.statusCode);
        throw Exception("failed");
      }
    }
  }

  Future<Post2?> SendOtp() async {
    if (_code.text == "") {
      return thongbao("Otp cannt be empty");
    } else if (!EmailValidator.validate(_email.text)) {
      return thongbao("Wrong email configuration");
    } else {
      final url = Uri.parse("$ip/api/checkchangepass");
      String tokendata = await fetchCsrfToken();
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': tokendata
      };
      Map<String, dynamic> request = {
        "email": _email.text,
        "otp": _code.text,
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
          MaterialPageRoute(builder: (context) => Changepass()),
        );
      } else if (response.statusCode == 201) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String errorMessage = jsonResponse['message'];
        return thongbao(errorMessage);
      } else if (response.statusCode == 404) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String errorMessage = jsonResponse['message'];
        return thongbao(errorMessage);
      } else {
        print(response.statusCode);
        throw Exception("failed");
      }
    }
  }

  void startCountdown() {
    if (!_isButtonDisabled) {
      setState(() {
        _isButtonDisabled = true;
      });

      // Đặt thời gian chờ 60 giây
      _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (mounted) {
          // Kiểm tra nếu widget vẫn còn trong cây
          if (_countdownSeconds > 0) {
            setState(() {
              _countdownSeconds--;
            });
          } else {
            setState(() {
              _isButtonDisabled = false;
              _countdownSeconds = 60;
            });
            _countdownTimer.cancel();
          }
        }
      });

      sendcode();
    }
  }
}
