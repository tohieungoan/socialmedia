import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmediaapp/data/GetCurrentUser.dart';
import 'package:socialmediaapp/models/models.dart';
import 'package:socialmediaapp/models/user_model.dart';
import 'package:socialmediaapp/screens/SettingsScreen.dart';
import 'package:socialmediaapp/screens/friends.dart';
import 'package:socialmediaapp/screens/home_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:socialmediaapp/screens/mypage.dart';
import 'package:socialmediaapp/widgets/widgets.dart';

class NavScreen extends StatefulWidget {
  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  SharedPreferences? sharedPref;

  final List<Widget> _screens = [
    HomeScreen(),
    Scaffold(),
    Mypage(),
    friends(),
    Scaffold(),
    SettingsScreen(),
  ];
  final List<IconData> _icons = [
    Icons.home,
    Icons.ondemand_video,
    MdiIcons.accountCircleOutline,
    MdiIcons.accountGroupOutline,
    MdiIcons.bellOutline,
    Icons.menu,
  ];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // getEmailFromSharedPreferences();
  }

  // Future<void> getEmailFromSharedPreferences() async {
  //   sharedPref = await SharedPreferences.getInstance();

  //   setState(() {
  //     email = sharedPref?.getString("email");
  //     name = sharedPref?.getString("name");
  //     url = sharedPref?.getString("imageUrl");
  //   });
  // }

  void getCurrentUser() async {
    final getCurrentUser = GetCurrentUser();
    final user = await getCurrentUser.getUser();
    print('Name: ${user.name}');
    print('Image URL: ${user.imageUrl}');
  }

  @override
  Widget build(BuildContext context) {
    // Fluttertoast.showToast(
    //   msg: "Email is $email with $name and $url",
    //   toastLength: Toast.LENGTH_SHORT,
    //   gravity: ToastGravity.CENTER,
    //   timeInSecForIosWeb: 1,
    //   backgroundColor: Colors.blue,
    //   textColor: Colors.white,
    //   fontSize: 16.0,
    // );

    return DefaultTabController(
      length: _icons.length,
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: CustomTabBar(
            icons: _icons,
            selectedIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
          ),
        ),
      ),
    );
  }
}
