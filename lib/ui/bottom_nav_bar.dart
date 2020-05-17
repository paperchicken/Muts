import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:muts/ui/Chats/dialogs_screen.dart';
import 'package:muts/ui/Profile/profile_screen.dart';
import 'package:muts/ui/Home/home_screen.dart';

class BottomNavBar extends StatefulWidget {
  final String currentUserId;

  BottomNavBar({Key key, @required this.currentUserId}) : super(key: key);

  @override
  _BottomNavBarState createState() =>
      _BottomNavBarState(currentUserId: currentUserId);
}

class _BottomNavBarState extends State<BottomNavBar> {
  _BottomNavBarState({Key key, @required this.currentUserId});

  final String currentUserId;

  DateTime backbuttonpressedTime;

  Future<bool> openDialog() async {
    DateTime currentTime = DateTime.now();

    bool backButton = backbuttonpressedTime == null ||
        currentTime.difference(backbuttonpressedTime) > Duration(seconds: 3);

    if (backButton) {
      backbuttonpressedTime = currentTime;
      Fluttertoast.showToast(
        fontSize: 14,
        msg: "Сlick again to exit",
        backgroundColor: Color(0xff0062F4),
        textColor: Colors.white,
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: openDialog,
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          inactiveColor: Colors.grey[800],
          activeColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(
                icon: Icon(LineAwesomeIcons.home, size: 28)),
            BottomNavigationBarItem(
                icon: Icon(LineAwesomeIcons.comments, size: 28)),
            BottomNavigationBarItem(
                icon: Icon(LineAwesomeIcons.user, size: 28)),
          ],
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return HomeScreen();
            case 1:
              return DialogScreen(currentUserId: currentUserId);
            case 2:
              return ProfileScreen();
            default:
              return HomeScreen();
          }
        },
      ),
    );
  }
}
