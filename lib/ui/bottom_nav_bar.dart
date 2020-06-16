import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:morpheus/morpheus.dart';
import 'package:muts/ui/Chats/chat_screen.dart';
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

  final List<Widget> _screens = [
    Scaffold(body: HomeScreen()),
    Scaffold(body: DialogScreen()),
    Scaffold(body: ProfileScreen()),
  ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: openDialog,
      child: Scaffold(
        body: MorpheusTabView(child: _screens[_currentIndex]),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[800],
          backgroundColor: Theme.of(context).primaryColor,
          showUnselectedLabels: false,
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(LineAwesomeIcons.home, size: 28),
              title: Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(LineAwesomeIcons.comments, size: 28),
              title: Text('Chats'),
            ),
            BottomNavigationBarItem(
              icon: Icon(LineAwesomeIcons.user, size: 28),
              title: Text('Profile'),
            ),
          ],
          onTap: (index) {
            if (index != _currentIndex) {
              setState(() => _currentIndex = index);
            }
          },
        ),
      ),
    );
  }
}
