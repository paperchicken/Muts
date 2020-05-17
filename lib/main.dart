import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:muts/ui/sing_in_screen.dart';
void main() => runApp(App());

final auth = FirebaseAuth.instance;

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        backgroundColor: Colors.black,
        primaryColor: Color(0xff000000),
        accentColor: Color(0xff1A1A1A),
      ),
      home: SingInScreen(),
    );
  }
}
