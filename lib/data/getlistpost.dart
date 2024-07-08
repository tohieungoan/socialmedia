import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmediaapp/main.dart';
import 'package:socialmediaapp/models/models.dart';

class Getlistpost {
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

  Future<List<Post>> getList() async {
    final url = Uri.parse("$ip/api/getlistpost");
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

      List<Post> postList = [];
      for (var userData in data) {
        if (userData['id'] != "") {
          final idpost = userData['id'];
          final nameuser = userData['nameuser'];
          final avatar = userData['avatar'];
          final content = userData['content'];
          final commentcount = userData['commentcount'];
          final idcomment = userData['idcomment'];
          final like = userData['like'];
          final linkmedia = userData['linkmedia'];
          final timecreate = userData['timecreate'];
          postList.add(Post(
              idpost: idpost,
              nameuser: nameuser,
              avatar: avatar,
              content: content,
              commentcount: commentcount,
              idcomment: idcomment,
              like: like,
              linkmedia: linkmedia,
              timecreate: timecreate));
        }
      }
      return postList;
    } else if (response.statusCode == 404) {
      final jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'];

      List<Post> postList = [];
      final idpost = data['id'] ?? '';
      final nameuser = data['name'] ?? '';
      final avatar = data['imageUrl'] ?? '';
      final content = ''; // Assuming there's no content in 404 response
      final commentcount = 0; // Assuming no comments in 404 response
      final idcomment = ''; // Assuming no idcomment in 404 response
      final like = 0; // Assuming no likes in 404 response
      final linkmedia = ''; // Assuming no media in 404 response
      final timecreate = ''; // Assuming no timecreate in 404 response
      postList.add(Post(
          idpost: idpost,
          nameuser: nameuser,
          avatar: avatar,
          content: content,
          commentcount: commentcount,
          idcomment: idcomment,
          like: like,
          linkmedia: linkmedia,
          timecreate: timecreate));

      return postList;
    } else {
      print(response.statusCode);
      throw Exception("Failed to fetch posts");
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
