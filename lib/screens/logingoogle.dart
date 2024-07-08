import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmediaapp/main.dart';
import 'package:socialmediaapp/models/Post.dart';
import 'package:socialmediaapp/screens/screens.dart';
import 'package:http/http.dart' as http;

class Logingoogle {
  String ip = MyApp.ipv4;
  Future<Post2?> signWithGoogle(BuildContext context) async {
    try {
      var sharedPref = await SharedPreferences.getInstance();
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final url = Uri.parse("$ip/api/loginsocial");
      String tokendata = await fetchCsrfToken();
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': tokendata
      };
      String password = generateRandomPassword();
      Map<String, dynamic> request = {
        "name": userCredential.user!.displayName,
        "avatar": userCredential.user!.photoURL,
        "birthday": ".",
        "sociallogin": "google",
        "phone": ".",
        "email": userCredential.user!.email.toString(),
        "password": password,
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
        sharedPref.setBool(MyApp.Keylogin, true);
        sharedPref.setString("email", userCredential.user!.email.toString());

        return Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditProfilePreviousRegister()),
        );
      }
      if (response.statusCode == 400) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String Messagec = jsonResponse['message'];
        thongbao(Messagec);
        sharedPref.setBool(MyApp.Keylogin, true);
        sharedPref.setString("email", userCredential.user!.email.toString());

        return Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NavScreen()),
        );
      } else {
        print(response.statusCode);
        throw Exception("Registration failed");
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Something went wrong",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  thongbao(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
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

  String generateRandomPassword({int length = 8}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()-_=+';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }
}
