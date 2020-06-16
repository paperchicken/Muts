import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFeed extends StatefulWidget {
  final String text;

  AddFeed({Key key, @required this.text}) : super(key: key);

  @override
  State createState() => AddFeedState(text: text);
}

class AddFeedState extends State<AddFeed> {
  final TextEditingController textEditingController = TextEditingController();

  AddFeedState({Key key, @required this.text, String currentUserId});

  final String text;
  String id = '';
  String nickname = '';
  String photoUrl = '';
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    id = (await _firebaseAuth.currentUser()).uid;
    nickname = prefs.getString('nickname') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';
    setState(() {});
  }

  void onSendMessage(String content) {
    if (content.trim() != '') {
      textEditingController.clear();

      String time = DateTime.now().millisecondsSinceEpoch.toString();

      var documentReference = Firestore.instance
          .collection('feed')
          .document(time);

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'id': id,
            'nickname': nickname,
            'user': Firestore.instance.collection("users").document((await FirebaseAuth.instance.currentUser()).uid),
            'photoUrl': photoUrl,
            'timestamp': time,
            'content': content,
          },
        );
      });
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Posted");
    } else {
      Fluttertoast.showToast(msg: 'Please enter message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Create Post",
          style: GoogleFonts.montserrat(
              color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            LineAwesomeIcons.times,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Material(
        color: Theme.of(context).primaryColor,
        child: Column(
          children: <Widget>[
            Container(
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.only(left: 5, right: 5),
              child: TextField(
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      style: BorderStyle.solid,
                    ),
                  ),
                  fillColor: Theme.of(context).accentColor,
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.newline,
                autocorrect: true,
                controller: textEditingController,
              ),
              width: double.infinity,
              height: 60.0,
              margin: EdgeInsets.only(bottom: 5, right: 0, left: 0),
            ),
            GestureDetector(
              onTap: () => onSendMessage(textEditingController.text),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20, top: 20, left: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor,
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    height: 60,
                    child: Card(
                      color: Color(0xff0062F4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 0,
                      shadowColor: Colors.white,
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "ADD POST",
                              style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
