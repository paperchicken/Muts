import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muts/ui/Chats/chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DialogScreen extends StatefulWidget {
  final String currentUserId;
  DialogScreen({Key key, @required this.currentUserId}) : super(key: key);
  @override
  State createState() => _DialogScreenState(currentUserId: currentUserId);
}

class _DialogScreenState extends State<DialogScreen> {
  _DialogScreenState({Key key, @required this.currentUserId});
  final String currentUserId;
  SharedPreferences prefs;
  String id = '';

@override
  void initState() {
    super.initState();
    readLocal();
  }
  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';

    setState(() {});
  }

  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(10.0),
    topRight: Radius.circular(10.0),
  );

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Theme.of(context).primaryColor,
      child: SafeArea(
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                "Chats",
                style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500),
              ),
            ),
            CupertinoSliverRefreshControl(
              refreshIndicatorExtent: 70.0,
              onRefresh: () {
                return Future<void>.delayed(const Duration(seconds: 1));
              },
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    child: StreamBuilder(
                      stream:
                          Firestore.instance.collection('users').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CupertinoActivityIndicator(),
                          );
                        } else {
                          return ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.all(0.0),
                            itemBuilder: (context, index) => buildItem(
                                context, snapshot.data.documents[index]),
                            itemCount: snapshot.data.documents.length,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['id'] == id) {
      return Container();
    } else {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ChatScreen(
                peerNickname: document['nickname'],
                peerId: document.documentID,
                peerAvatar: document['photoUrl'],
              ),
            ),
          );
        },
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(right: 15, left: 15),
            child: Container(
              child: Card(
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 0,
                child: ListTile(
                  leading: Material(
                    child: document['photoUrl'] != null
                        ? CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CupertinoActivityIndicator(),
                              width: 50.0,
                              height: 50.0,
                              padding: EdgeInsets.all(15.0),
                            ),
                            imageUrl: document['photoUrl'],
                            width: 50.0,
                            height: 50.0,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.account_circle,
                            size: 50.0,
                            color: Colors.white,
                          ),
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  title: Text(
                    '${document['nickname']}',
                    style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                  subtitle: Text(
                    '${document['aboutMe']}',
                    style: GoogleFonts.montserrat(
                        color: Color(0xff0062F4),
                        fontWeight: FontWeight.w400,
                        fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}
