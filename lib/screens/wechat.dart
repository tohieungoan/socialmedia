import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmediaapp/data/Getlistfriendtochat.dart';
import 'package:socialmediaapp/data/getListFriend.dart';
import 'package:socialmediaapp/main.dart';
import 'package:socialmediaapp/models/friendchat.dart';
import 'package:socialmediaapp/models/user_model.dart';
import 'package:socialmediaapp/screens/nav_screen.dart';
import 'package:socialmediaapp/widgets/Listmyfriend.dart';
import 'package:socialmediaapp/widgets/listchat.dart';

class Wechat extends StatefulWidget {
  const Wechat({super.key});

  @override
  State<Wechat> createState() => _WechatState();
}

class _WechatState extends State<Wechat> {
  SharedPreferences? sharedPref;
  String? email;
  String ip = MyApp.ipv4;
  late Future<List<friendchat>> friendsListFuture;
  late int countf = 0;

  @override
  void initState() {
    super.initState();

    friendsListFuture = _getlistfriendchat();

    _getlistfriendchat().then((friendsList) {
      setState(() {
        countf = friendsList.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            // Handle the home icon tap event
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NavScreen()),
            );
          },
          child: Icon(CupertinoIcons.home),
        ),
        centerTitle: true,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        title: const Text(
          'We Chat',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.normal, fontSize: 19),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
            onPressed: () {}, child: const Icon(Icons.add_comment_rounded)),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<friendchat>>(
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
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 5.0),
                    sliver: SliverToBoxAdapter(
                      child: Listchat(ListUsers: friendsList),
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
    );
  }

  Future<List<friendchat>> _getlistfriendchat() async {
    final getlistfriend = Getlistfriendtochat();
    try {
      final friendsList = await getlistfriend.getList();
      countf = friendsList.length;
      return friendsList;
    } catch (error) {
      // Handle the error if needed
      print('Error fetching friends list: $error');
      return []; // Or return an empty list depending on your application logic
    }
  }
}
