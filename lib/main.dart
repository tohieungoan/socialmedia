import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmediaapp/config/palette.dart';
import 'package:socialmediaapp/data/GetCurrentUser.dart';
import 'package:socialmediaapp/models/Post.dart';
import 'package:socialmediaapp/screens/forgetpassword.dart';
import 'package:socialmediaapp/screens/friends.dart';
import 'package:socialmediaapp/screens/login_page.dart';
import 'package:socialmediaapp/screens/screens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialmediaapp/screens/post.dart';
import 'package:http/http.dart' as http;
import 'package:socialmediaapp/screens/wechat.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: 'AIzaSyBjk1m_-zqb6sRsC-wnqi7hNC4UYqHCBvA',
              appId: '1:518715479465:android:79028a121a7f980d00e0b8',
              messagingSenderId: '518715479465',
              projectId: 'fakebook-4d415',
              storageBucket: 'gs://fakebook-4d415.appspot.com'),
        )
      : await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const String Keylogin = "login";
  static const String ipv4 = "http://192.168.114.140:8000";

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Palette.scaffold,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    navigateToScreen();
  }

  void navigateToScreen() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    var isLoggedIn = sharedPref.getBool(MyApp.Keylogin);
    String? email = sharedPref.getString("email");

    Timer(Duration(seconds: 2), () {
      if (isLoggedIn != null) {
        if (isLoggedIn) {
          if (email != null) {
            getlogingsection(email);
          } else {
            // Handle case where email is null, e.g., navigate to login page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WelcomePage()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomePage()),
        );
      }
    });
  }

  Future<Post2?> getlogingsection(String email) async {
    String ip = MyApp.ipv4;
    final url = Uri.parse("$ip/api/getlogingsection");
    String tokendata = await fetchCsrfToken();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-CSRF-TOKEN': tokendata
    };

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
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavScreen()),
      );
    } else if (response.statusCode == 404) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      String errorMessage = jsonResponse['message'];
      thongbao(errorMessage);
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomePage()),
      );
    } else if (response.statusCode == 400) {
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

  Future<String> fetchCsrfToken() async {
    String ip = MyApp.ipv4;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
