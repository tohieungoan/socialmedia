import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmediaapp/data/GetCurrentUser.dart';
import 'package:socialmediaapp/data/GetListRequest.dart';
import 'package:socialmediaapp/data/getListSuggest.dart';
import 'package:socialmediaapp/main.dart';
import 'package:socialmediaapp/models/Post.dart';
import 'package:socialmediaapp/models/user_model.dart';
import 'package:socialmediaapp/screens/forgetpassword.dart';
import 'package:show_hide_password/show_hide_password.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:socialmediaapp/screens/friends.dart';
import 'package:socialmediaapp/screens/hello_login.dart';
import 'package:socialmediaapp/screens/home_screen.dart';
import 'package:socialmediaapp/screens/myfriend.dart';
import 'package:socialmediaapp/screens/suggest.dart';
import 'package:socialmediaapp/widgets/Listrequestfriend.dart';
import 'package:socialmediaapp/widgets/circle_button.dart';
import 'package:socialmediaapp/widgets/createpostcontainer.dart';
import 'package:socialmediaapp/widgets/listsuggestfriend.dart';
import 'package:socialmediaapp/widgets/rooms.dart';

class Suggest extends StatefulWidget {
  const Suggest({Key? key}) : super(key: key);

  @override
  _Suggest createState() => _Suggest();
}

class _Suggest extends State<Suggest> {
  SharedPreferences? sharedPref;
  String? email;
  String ip = MyApp.ipv4;
  late Future<List<User>> friendsListFuture;
  late int countf = 0;

  @override
  void initState() {
    super.initState();

    friendsListFuture = _getFriendsList();

    _getFriendsList().then((friendsList) {
      setState(() {
        countf = friendsList.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: w,
              margin: const EdgeInsets.only(left: 0, right: 0, top: 0),
              child: AppBar(
                backgroundColor: Colors.white,
                title: Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Suggest friend",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CircleButton(
                        icon: Icons.search,
                        iconSize: 30.0,
                        onPressed: () => print('search'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: w,
              margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80, // Adjust the width as needed
                    height: 35, // Adjust the height as needed
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => friends()),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.grey.shade300),
                      ),
                      label: Text(
                        'Request',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  SizedBox(
                    width: 90, // Adjust the width as needed
                    height: 35, // Adjust the height as needed
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Myfriend()),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.grey.shade300),
                      ),
                      label: Text(
                        'List friends',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 0, top: 0),
            ),
            Expanded(
              child: Container(
                child: Scaffold(
                  body: FutureBuilder<List<User>>(
                    future: friendsListFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        final friendsList = snapshot.data;
                        if (friendsList != null && friendsList.isNotEmpty) {
                          final currentUser = friendsList[
                              0]; // Assuming you want to access the first user in the list
                          return CustomScrollView(
                            slivers: [
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 10.0, 0.0, 5.0),
                                sliver: SliverToBoxAdapter(
                                  child: ListSuggest(
                                    listUsers: friendsList,
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Center(
                            child: Text('No friends found.'),
                          );
                        }
                      }
                    },
                  ),
                ),
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

  Future<List<User>> _getFriendsList() async {
    final getlistfriend = Getlistsuggest();
    try {
      final friendsList = await getlistfriend.getList();
      countf = friendsList.length;
      return friendsList;
    } catch (error) {
      // Handle the error if needed
      print('Error fetching friends list: $error');
      return []; // Or return null depending on your application logic
    }
  }
}
