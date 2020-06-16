import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditDesriptionScreen extends StatefulWidget {
  @override
  _EditDesriptionScreenState createState() => _EditDesriptionScreenState();
}

class _EditDesriptionScreenState extends State<EditDesriptionScreen> {
  bool isLoading = false;

  TextEditingController controllerAboutMe;

  SharedPreferences prefs;

  String id = '';
  String aboutMe = '';

  final FocusNode focusNodeAboutMe = FocusNode();

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    aboutMe = prefs.getString('aboutMe') ?? '';

    controllerAboutMe = TextEditingController(text: aboutMe);

    setState(() {});
  }

  void handleUpdateData() {
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;
    });

    Firestore.instance.collection('users').document(id).updateData({
      'aboutMe': aboutMe,
    }).then((data) async {
      await prefs.setString('aboutMe', aboutMe);

      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Changes saved");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Builder(
        builder: (context) => SafeArea(
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                centerTitle: true,
                backgroundColor: Theme.of(context).primaryColor,
                title: Text(
                  "Change desription",
                  style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500),
                ),
                leading: IconButton(
                  icon: Icon(LineAwesomeIcons.angle_left),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.white,
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      padding: EdgeInsets.only(left: 25, right: 25, top: 10),
                      alignment: Alignment.center,
                      child: TextField(
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).accentColor,
                          icon: Icon(
                            LineAwesomeIcons.comment,
                            color: Color(0xff0062F4),
                          ),
                        ),
                        controller: controllerAboutMe,
                        onChanged: (value) {
                          aboutMe = value;
                        },
                        focusNode: focusNodeAboutMe,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        autocorrect: true,
                      ),
                    ),
                    GestureDetector(
                      onTap: handleUpdateData,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 20, top: 20, left: 20),
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
                                      "SAVE",
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
