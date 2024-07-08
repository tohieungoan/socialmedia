import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:socialmediaapp/main.dart';
import 'package:socialmediaapp/models/user_model.dart';
import 'package:socialmediaapp/widgets/profile_avatar2.dart';

class Listfriend extends StatefulWidget {
  final List<User> ListUsers;

  const Listfriend({
    Key? key,
    required this.ListUsers,
  }) : super(key: key);

  @override
  _ListfriendState createState() => _ListfriendState();
}

class _ListfriendState extends State<Listfriend> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Container(
      height: h,
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          vertical: 0.0,
          horizontal: 4.0,
        ),
        scrollDirection: Axis.vertical,
        itemCount: widget.ListUsers.length,
        itemBuilder: (BuildContext context, int index) {
          final User user = widget.ListUsers[index];
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Row(
              children: [
                ProfileAvatar2(
                  imageUrl: user.imageUrl,
                  isActive: true,
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 120, // Adjust the width as needed
                          height: 40, // Adjust the height as needed
                          child: TextButton.icon(
                            onPressed: () => requestFriend("accept", user.id),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.grey.shade300,
                              ),
                            ),
                            icon: Icon(Icons.person_add_alt_1),
                            label: Text(
                              'Accept',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        SizedBox(
                          width: 120, // Adjust the width as needed
                          height: 40, // Adjust the height as needed
                          child: TextButton.icon(
                            onPressed: () => requestFriend("delete", user.id),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.grey.shade300,
                              ),
                            ),
                            icon: Icon(Icons.delete),
                            label: Text(
                              'Delete',
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
              ],
            ),
          );
        },
      ),
    );
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

  void showToast(String msg) {
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

  Future<void> requestFriend(String action, String id) async {
    String ip = MyApp.ipv4;
    final url = Uri.parse('$ip/api/acceptOrdelete');
    String tokenData = await fetchCsrfToken();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-CSRF-TOKEN': tokenData,
    };
    SharedPreferences? sharedPref;
    String? email;

    sharedPref = await SharedPreferences.getInstance();
    setState(() {
      email = sharedPref?.getString('email');
    });

    Map<String, dynamic> request = {
      "email": email,
      "friends": id,
      "action": action
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

      // Update ListUsers to remove the user with matching id
      setState(() {
        widget.ListUsers.removeWhere((user) => user.id == id);
      });
    } else if (response.statusCode == 202 || response.statusCode == 404) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      String errorMessage = jsonResponse['message'];
      thongbao(errorMessage);
    } else {
      print(response.statusCode);
      throw Exception("Failed to $action friend");
    }
  }
}
