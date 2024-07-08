import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmediaapp/main.dart';
import 'package:socialmediaapp/models/friendchat.dart';
import 'package:socialmediaapp/models/getcontentmessage.dart';
import 'package:socialmediaapp/widgets/profile_avatar2.dart';
import 'package:http/http.dart' as http;
import 'message_screen.dart'; // Import the new message screen

class Listchat extends StatefulWidget {
  final List<friendchat> ListUsers;

  const Listchat({
    Key? key,
    required this.ListUsers,
  }) : super(key: key);

  @override
  _Listchat createState() => _Listchat();
}

class _Listchat extends State<Listchat> {
  @override
  Widget build(BuildContext context) {
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
        itemCount: 1 + widget.ListUsers.length,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return SizedBox.shrink();
          }
          final friendchat user = widget.ListUsers[index - 1];
          return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
              child: InkWell(
                onTap: () {
                  // Handle row tap here
                  gotochat(user.idwechat.toString(), user.id.toString(),
                      user.idofme.toString());
                },
                child: Row(
                  children: [
                    ProfileAvatar2(
                      imageUrl: user.avatar.toString(),
                      isActive: true,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align text to the start
                      children: [
                        Text(
                          user.name.toString(),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: 5, // Reduced height for closer spacing
                        ),
                        Text(user.lastmessage.toString()),
                      ],
                    ),
                  ],
                ),
              ));
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

  Future<void> gotochat(String idwechat, String idfriend, String idofme) async {
    String ip = MyApp.ipv4;
    final url = Uri.parse('$ip/api/getlistmessage');
    String tokenData = await fetchCsrfToken();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-CSRF-TOKEN': tokenData,
    };
    SharedPreferences? sharedPref = await SharedPreferences.getInstance();
    String? email = sharedPref.getString('email');

    Map<String, dynamic> request = {
      "email": email,
      "idfriend": idfriend,
      "idofme": idofme,
      "idwechat": idwechat,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(request),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'];
      final message = jsonResponse['messages']; // Corrected key access
      String name = data['name'];
      String avatar = data['avatar'];
      String myname = data['myname'];
      String chatkey = data['chatkey'];
      List<Getcontentmessage> contentlist = [];
      for (var contentData in message) {
        final idofme = contentData['idofme'];
        final timecreate = contentData['timecreate'];
        final linkmedia = contentData['linkmedia'];
        final content = contentData['content'];
        contentlist.add(Getcontentmessage(
          idofme: idofme,
          timecreate: timecreate,
          linkmedia: linkmedia,
          content: content,
        ));
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessageScreen(
            friendName: name,
            friendAvatar: avatar,
            token: tokenData,
            chatkey: chatkey,
            idofme: idofme,
            myname: myname,
            idfriend: idfriend,
            idwechat: idwechat,
            messages: contentlist, // Truyền danh sách tin nhắn
          ),
        ),
      );
    } else if (response.statusCode == 202) {
      final jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'];
      String name = data['name'];
      String myname = data['myname'];
      String avatar = data['avatar'];
      String chatkey = data['chatkey'];
      List<Getcontentmessage> contentlist = [];

      // Navigate to the MessageScreen and pass necessary data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessageScreen(
            friendName: name,
            token: tokenData,
            friendAvatar: avatar,
            idofme: idofme,
            chatkey: chatkey,
            idfriend: idfriend,
            myname: myname,
            idwechat: idwechat,
            messages: contentlist, // Truyền danh sách tin nhắn
          ),
        ),
      );
    } else {
      throw Exception("Failed to perform action");
    }
  }
}
