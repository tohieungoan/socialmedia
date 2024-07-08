import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmediaapp/main.dart';
import 'package:socialmediaapp/models/Post.dart';
import 'package:socialmediaapp/screens/LoginGithub.dart';
import 'package:socialmediaapp/screens/forgetpassword.dart';
import 'package:socialmediaapp/screens/hello_login.dart';
import 'package:socialmediaapp/config/palette.dart';
import 'package:show_hide_password/show_hide_password.dart';
import 'package:socialmediaapp/screens/logingoogle.dart';
import 'package:socialmediaapp/screens/screens.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:socialmediaapp/screens/logingoogle.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String ip = MyApp.ipv4;
  // final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
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
            image: AssetImage('img/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: w * 0.1,
              height: h * 0.06,
              margin: EdgeInsets.only(top: 25, bottom: 20, left: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.grey[600],
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomePage()),
                  );
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              width: w,
              margin: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sign into your account",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                spreadRadius: 7,
                                offset: Offset(1, 1),
                                color: Colors.grey.withOpacity(0.7))
                          ]),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          controller: _email,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              labelText: "Email",
                              labelStyle: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                              hintText: "example@example.com",
                              hintStyle: TextStyle(color: Colors.black),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      )),
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
                        controller: _password,
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
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Forgetpassword()),
                          );
                        },
                        child: Text(
                          "Forgot your Password?",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: _login,
                      child: Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "You can also login with",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 310, // Adjust the width as needed
                        height: 50, // Adjust the height as needed
                        child: TextButton.icon(
                          onPressed: () {
                            Logingoogle loginGoogle = Logingoogle();
                            loginGoogle.signWithGoogle(context);
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          icon: Image.asset(
                            'img/google_logo.png',
                            width: 24,
                            height: 24,
                          ),
                          label: Text(
                            'Sign in with Google',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Or",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 310, // Adjust the width as needed
                        height: 50, // Adjust the height as needed
                        child: TextButton.icon(
                          onPressed: () {
                            LoginGithub loginGithub = LoginGithub();
                            loginGithub.signInWithGithub(context);
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          icon: Image.asset(
                            'img/github-mark.png',
                            width: 24,
                            height: 24,
                          ),
                          label: Text(
                            'Sign in with Github',
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
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "haven't an account ?",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Registerpage()),
                            );
                          },
                          child: Text(
                            "Register now",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ))
                    ],
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

  Future<Post2?> _login() async {
    if (_email.text == "" || _password.text == "") {
      return thongbao("Email and Password cannt be empty");
    } else if (!EmailValidator.validate(_email.text)) {
      return thongbao("Wrong email configuration");
    } else {
      final url = Uri.parse("$ip/api/login");
      String tokendata = await fetchCsrfToken();
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': tokendata
      };

      Map<String, dynamic> request = {
        "email": _email.text,
        "password": _password.text,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String Messagec = jsonResponse['message'];

        var sharedPref = await SharedPreferences.getInstance();
        sharedPref.setBool(MyApp.Keylogin, true);
        sharedPref.setString("email", _email.text);
        thongbao(Messagec);

        return Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NavScreen()),
        );
      }
      if (response.statusCode == 201) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String Messagec = jsonResponse['message'];

        var sharedPref = await SharedPreferences.getInstance();
        sharedPref.setBool(MyApp.Keylogin, true);
        sharedPref.setString("email", _email.text);
        thongbao(Messagec);

        return Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditProfilePreviousRegister()),
        );
      } else if (response.statusCode == 400) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String errorMessage = jsonResponse['message'];
        return thongbao(errorMessage);
      } else if (response.statusCode == 401) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String errorMessage = jsonResponse['message'];
        return thongbao(errorMessage);
      } else {
        print(response.statusCode);
        throw Exception("Registration failed");
      }
    }
  }
}
