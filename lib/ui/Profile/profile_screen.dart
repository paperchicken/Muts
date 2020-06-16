import 'dart:async';
import 'dart:io';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:morpheus/morpheus.dart';
import 'package:muts/ui/Profile/edit_description.dart';
import 'package:muts/ui/Profile/edit_name.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool isLoading = false;

  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (context) => App()),
        (Route<dynamic> route) => false);
  }

  SharedPreferences prefs;

  String id = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';

  File avatarImageFile;

  final FocusNode focusNodeNickname = FocusNode();
  final FocusNode focusNodeAboutMe = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    nickname = prefs.getString('nickname') ?? '';
    aboutMe = prefs.getString('aboutMe') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';

    // Force refresh input
    setState(() {});
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = id;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          Firestore.instance
              .collection('users')
              .document(id)
              .updateData({'photoUrl': photoUrl}).then((data) async {
            await prefs.setString('photoUrl', photoUrl);
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Changes saved");
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: err.toString());
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: "This file is not an image");
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "This file is not an image");
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void handleUpdateData() {
    setState(() {
      isLoading = true;
    });

    Firestore.instance
        .collection('users')
        .document(id)
        .updateData({'photoUrl': photoUrl}).then((data) async {
      await prefs.setString('photoUrl', photoUrl);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Update success");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    readLocal();
    return CupertinoPageScaffold(
      backgroundColor: Theme.of(context).primaryColor,
      child: SafeArea(
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                "Profile",
                style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 15.0),
                      Material(
                        color: Theme.of(context).primaryColor,
                        child: Container(
                          child: Center(
                            child: Stack(
                              children: <Widget>[
                                (avatarImageFile == null)
                                    ? (photoUrl != ''
                                        ? Material(
                                            child: CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Container(
                                                child:
                                                    CupertinoActivityIndicator(),
                                                width: 90.0,
                                                height: 90.0,
                                                padding: EdgeInsets.all(20.0),
                                              ),
                                              imageUrl: photoUrl,
                                              width: 90.0,
                                              height: 90.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(45.0)),
                                            clipBehavior: Clip.hardEdge,
                                          )
                                        : Icon(
                                            Icons.account_circle,
                                            size: 90.0,
                                            color: Color(0xffaeaeae),
                                          ))
                                    : Material(
                                        child: Image.file(
                                          avatarImageFile,
                                          width: 90.0,
                                          height: 90.0,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(45.0)),
                                        clipBehavior: Clip.hardEdge,
                                      ),
                                IconButton(
                                  icon: Icon(
                                    Icons.camera_alt,
                                    color: Color(0xff203152).withOpacity(0.5),
                                  ),
                                  onPressed: getImage,
                                  padding: EdgeInsets.all(30.0),
                                  splashColor: Colors.transparent,
                                  highlightColor: Color(0xffaeaeae),
                                  iconSize: 30.0,
                                ),
                              ],
                            ),
                          ),
                          width: double.infinity,
                          margin: EdgeInsets.all(20.0),
                        ),
                      ),
                      Material(
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          nickname,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Material(
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          aboutMe,
                          style: GoogleFonts.montserrat(
                            color: Colors.grey[800],
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MorpheusPageRoute(
                              builder: (context) => EditNameScreen(),
                            ),
                          );
                        },
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 10, left: 10, top: 5),
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).primaryColor,
                                    blurRadius: 10.0,
                                  ),
                                ],
                              ),
                              height: 80,
                              child: Card(
                                color: Theme.of(context).accentColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 0,
                                shadowColor: Theme.of(context).primaryColor,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        height: 55,
                                        width: 55,
                                        child: Card(
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          color: Theme.of(context).primaryColor,
                                          child: Icon(
                                            LineAwesomeIcons.user,
                                            size: 30,
                                            color: Color(0xff0062F4),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Change nickname",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MorpheusPageRoute(
                              builder: (context) => EditDesriptionScreen(),
                            ),
                          );
                        },
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 10, left: 10, top: 5),
                            child: Container(
                              decoration: new BoxDecoration(
                                boxShadow: [
                                  new BoxShadow(
                                    color: Theme.of(context).primaryColor,
                                    blurRadius: 10.0,
                                  ),
                                ],
                              ),
                              height: 80,
                              child: Card(
                                color: Theme.of(context).accentColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 0,
                                shadowColor: Colors.white,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        height: 55,
                                        width: 55,
                                        child: Card(
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          color: Theme.of(context).primaryColor,
                                          child: Icon(
                                            LineAwesomeIcons.comment,
                                            size: 30,
                                            color: Color(0xff0062F4),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Change description",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
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
                      GestureDetector(
                        onTap: handleSignOut,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 10, left: 10, top: 5),
                            child: Container(
                              decoration: new BoxDecoration(
                                boxShadow: [
                                  new BoxShadow(
                                    color: Theme.of(context).primaryColor,
                                    blurRadius: 10.0,
                                  ),
                                ],
                              ),
                              height: 80,
                              child: Card(
                                color: Theme.of(context).accentColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 0,
                                shadowColor: Theme.of(context).primaryColor,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        height: 55,
                                        width: 55,
                                        child: Card(
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          color: Theme.of(context).primaryColor,
                                          child: Icon(
                                            LineAwesomeIcons.sign_out,
                                            size: 30,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Sing out",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}