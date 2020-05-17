import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:muts/ui/Home/add_feed.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _HomeScreenState({Key key});
  final ScrollController listScrollController = new ScrollController();

  String id;
  var listMessage;

  @override
  void initState() {
    super.initState();
    id = '';
    readLocal();
  }

  readLocal() async {
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    id = (await _firebaseAuth.currentUser()).uid;
    Firestore.instance.collection('users').document(id).updateData({'id': id});

    setState(() {});
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {},
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 0, right: 0),
            child: Card(
              color: Theme.of(context).accentColor,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CupertinoActivityIndicator(),
                              width: 40.0,
                              height: 40.0,
                              padding: EdgeInsets.all(20.0),
                            ),
                            imageUrl: document['photoUrl'],
                            width: 40.0,
                            height: 40.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(45.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              document['nickname'],
                              style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            Text(
                              DateFormat('dd MMM kk:mm').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(document['timestamp']))),
                              style: GoogleFonts.montserrat(
                                color: Colors.blueGrey,
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        document['content'],
                        style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Home",
          style: GoogleFonts.montserrat(
              color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w500),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => AddFeed(text: ""),
            ),
          );
        },
        child: Icon(LineAwesomeIcons.plus),
        backgroundColor: Color(0xff0062F4),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        child: id == ''
            ? Center(child: CupertinoActivityIndicator())
            : StreamBuilder(
                stream: Firestore.instance
                    .collection('feed')
                    .orderBy('timestamp', descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CupertinoActivityIndicator());
                  } else {
                    listMessage = snapshot.data.documents;
                    return Material(
                      color: Theme.of(context).primaryColor,
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) =>
                            buildItem(index, snapshot.data.documents[index]),
                        itemCount: snapshot.data.documents.length,
                        controller: listScrollController,
                      ),
                    );
                  }
                },
              ),
      ),
    );
  }
}
