import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmediaapp/config/palette.dart';
import 'package:socialmediaapp/data/GetCurrentUser.dart';
import 'package:socialmediaapp/data/getlistpost.dart';
import 'package:socialmediaapp/data/getmypost.dart';
import 'package:socialmediaapp/models/models.dart';
import 'package:socialmediaapp/screens/wechat.dart';
import 'package:socialmediaapp/widgets/circle_button.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:socialmediaapp/widgets/personal.dart';
import 'package:socialmediaapp/widgets/widgets.dart';

class Mypage extends StatefulWidget {
  @override
  _Mypage createState() => _Mypage();
}

class _Mypage extends State<Mypage> {
  late Future<User> currentUserFuture;
  late Future<List<Post>> listPostFuture;
  late String email;
  @override
  void initState() {
    super.initState();
    currentUserFuture = getCurrentUser();
    listPostFuture = getListPost();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      body: FutureBuilder<User>(
        future: currentUserFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final currentUser = snapshot.data!;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.white,
                  title: Text(
                    'Facebook',
                    style: TextStyle(
                      color: Palette.facebookBlue,
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.2,
                    ),
                  ),
                  centerTitle: false,
                  floating: true,
                  actions: [
                    CircleButton(
                      icon: Icons.search,
                      iconSize: 30.0,
                      onPressed: () => print('Search'),
                    ),
                    CircleButton(
                      icon: MdiIcons.facebookMessenger,
                      iconSize: 30.0,
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Wechat()),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Personal(currentUser: currentUser),
                ),
                FutureBuilder<List<Post>>(
                  future: listPostFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(child: Text('Error: ${snapshot.error}')),
                      );
                    } else {
                      final listPost = snapshot.data!;
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final post = listPost[index];

                            return PostContainer(
                              post: post,
                              email: email,
                            );
                          },
                          childCount: listPost.length,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<List<Post>> getListPost() async {
    final getlistpost = Getmypost();
    SharedPreferences? sharedPref;

    sharedPref = await SharedPreferences.getInstance();
    setState(() {
      email = sharedPref!.getString('email')!;
    });
    try {
      final listPost = await getlistpost.getList();
      return listPost;
    } catch (error) {
      // Handle the error if needed
      print('Error fetching posts list: $error');
      return []; // Return an empty list in case of error
    }
  }

  Future<User> getCurrentUser() async {
    final getCurrentUser = GetCurrentUser();
    final user = await getCurrentUser.getUser();
    return User(
      name: user.name,
      imageUrl: user.imageUrl,
      id: user.id,
    );
  }
}
