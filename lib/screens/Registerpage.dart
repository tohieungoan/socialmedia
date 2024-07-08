import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialmediaapp/main.dart';
import 'package:socialmediaapp/models/Post.dart';
import 'package:socialmediaapp/models/models.dart';
import 'package:socialmediaapp/screens/LoginGithub.dart';
import 'package:socialmediaapp/screens/hello_login.dart';
import 'package:socialmediaapp/config/palette.dart';
import 'package:show_hide_password/show_hide_password.dart';
import 'package:socialmediaapp/screens/login_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:socialmediaapp/screens/logingoogle.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;

class Registerpage extends StatefulWidget {
  const Registerpage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<Registerpage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String ip = MyApp.ipv4;
  // final _auth = AuthService();
  @override
  void dispose() {
    super.dispose();
    _name.dispose();
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
              margin: EdgeInsets.only(top: 20, bottom: 20, left: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.grey[600],
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
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
                    "Create your account",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  SizedBox(
                    height: 30,
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
                          controller: _name,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelText: 'Name',
                            hintText: 'Enter your name',
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

                        TextFormField(
                          controller: _email,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: 'Email',
                            hintText: 'example@example.com',
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
                        Divider(), // Dòng kẻ ngang

                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            labelText: 'Password',
                            hintText: 'Enter your password',
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
                      ],
                    ),
                  ),
                  SizedBox(height: 36),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: _signup,
                      child: Text('Register',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(
                    height: 30,
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
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150, // Adjust the width as needed
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
                            'Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "  Or  ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        width: 150, // Adjust the width as needed
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
                            'Github',
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
          ],
        ),
      ),
    );
  }

  // _signup() async {
  //   final user =
  //       await _auth.createUserWithEmailandPassword(_email.text, _password.text);
  //   if (user != null) {
  //     CollectionReference collRef =
  //         FirebaseFirestore.instance.collection("users");

  //     collRef.add({
  //       "avatar": null,
  //       "birthday": null,
  //       "email": _email.text,
  //       "name": _name.text,
  //       "password": _password.text,
  //       "phone": _phone.text,
  //       "sociallogin": "",
  //     });

  //     Fluttertoast.showToast(
  //         msg: "The account has been created successfully",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.CENTER,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.blue,
  //         textColor: Colors.white,
  //         fontSize: 16.0);
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => LoginPage()),
  //     );
  //   } else {
  //     Fluttertoast.showToast(
  //         msg: "Maybe the email is exits. Try with another email address",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.CENTER,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.white,
  //         fontSize: 16.0);
  //   }
  // }

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

  Future<Post2?> _signup() async {
    if (_name.text == "" || _password.text == "" || _email.text == "") {
      return thongbao("You need to fill out the entire form");
    } else if (!EmailValidator.validate(_email.text)) {
      return thongbao("Wrong email configuration");
    } else if (_password.text.length < 9) {
      return thongbao("Password to short");
    } else {
      final url = Uri.parse("$ip/api/register");
      String tokendata = await fetchCsrfToken();
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': tokendata
      };

      Map<String, dynamic> request = {
        "name": _name.text,
        "avatar": "https://i.stack.imgur.com/l60Hf.png",
        "birthday": ".",
        "sociallogin": "Register",
        "phone": ".",
        "email": _email.text,
        "password": _password.text,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        // final jsonResponse = json.decode(response.body);
        // final post = Post2.fromJson(jsonResponse);
        // return post;
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String Messagec = jsonResponse['message'];
        return thongbao(Messagec);
      } else if (response.statusCode == 400) {
        // Lỗi: Email đã tồn tại
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
