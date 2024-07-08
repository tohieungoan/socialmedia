import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmediaapp/main.dart';
import 'package:socialmediaapp/models/friendchat.dart';

class Getlistfriendtochat {
  String ip = MyApp.ipv4;
  Future<String> fetchCsrfToken() async {
    final response = await http.get(Uri.parse('$ip/csrf-token'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['csrf_token'];
    } else {
      throw Exception('Failed to fetch CSRF token');
    }
  }

  Future<List<friendchat>> getList() async {
    final url = Uri.parse("$ip/api/getlistfriendtochat");
    final tokenData = await fetchCsrfToken();
    final sharedPref = await SharedPreferences.getInstance();
    final email = sharedPref.getString("email");

    final headers = {
      'Content-Type': 'application/json',
      'X-CSRF-TOKEN': tokenData,
    };

    final request = {
      "email": email,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(request),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'];

      List<friendchat> userList = [];
      for (var userData in data) {
        final id = userData['id'];
        final idofme = userData['idofme'];
        final name = userData['name'];
        final imageUrl = userData['avatar'];
        final idwechat = userData['idwechat'];
        final lastmessage = userData['lastmessage'];
        userList.add(friendchat(
            name: name,
            avatar: imageUrl,
            id: id,
            idofme: idofme,
            lastmessage: lastmessage,
            idwechat: idwechat));
      }
      return userList;
    } else if (response.statusCode == 404) {
      final jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'];
      final name = data['name'];
      final id = data['id'];
      final idofme = data['idofme'];
      final imageUrl = data['imageUrl'];
      final idwechat = data['idwechat'];
      final lastmessage = data['lastmessage'];
      // var sharedPref = await SharedPreferences.getInstance();
      // sharedPref.setBool(MyApp.Keylogin, true);
      // sharedPref.setString("name", name);
      // sharedPref.setString("imageUrl", imageUrl);
      return [
        friendchat(
            name: name,
            avatar: imageUrl,
            id: id,
            lastmessage: lastmessage,
            idwechat: idwechat,
            idofme: idofme)
      ];
    } else {
      print(response.statusCode);
      throw Exception("Failed to fetch user");
    }
  }

  void thongbao(String msg) {
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
}
