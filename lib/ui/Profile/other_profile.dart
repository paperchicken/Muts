import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class OtherProfileScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;
  final String peerAboutMe;

  OtherProfileScreen({
    Key key,
    @required this.peerId,
    @required this.peerAvatar,
    @required this.peerNickname,
    @required this.peerAboutMe,
  }) : super(key: key);

  @override
  State createState() => _OtherProfileScreenState(
        peerId: peerId,
        peerAvatar: peerAvatar,
        peerNickname: peerNickname,
        peerAboutMe: peerAboutMe,
      );
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  _OtherProfileScreenState({
    Key key,
    @required this.peerId,
    @required this.peerAvatar,
    @required this.peerNickname,
    @required this.peerAboutMe,
  });

  File avatarImageFile;

  String peerId;
  String peerAvatar;
  String peerNickname;
  String peerAboutMe;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              leading: IconButton(
                icon: Icon(LineAwesomeIcons.angle_left),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.white,
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
                                    ? (peerAvatar != ''
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
                                              imageUrl: peerAvatar,
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
                          peerNickname,
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
                          peerAboutMe,
                          style: GoogleFonts.montserrat(
                            color: Colors.grey[800],
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
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
