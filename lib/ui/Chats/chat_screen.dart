import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morpheus/morpheus.dart';
import 'package:muts/ui/Chats/full_photo.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:intl/intl.dart';
import 'package:muts/ui/Profile/other_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;
  final String peerAboutMe;

  ChatScreen({
    Key key,
    @required this.peerId,
    @required this.peerAvatar,
    @required this.peerNickname,
    @required this.peerAboutMe,
  }) : super(key: key);

  @override
  State createState() => ChatScreenState(
        peerId: peerId,
        peerAvatar: peerAvatar,
        peerNickname: peerNickname,
        peerAboutMe: peerAboutMe,
      );
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({
    Key key,
    @required this.peerId,
    @required this.peerAvatar,
    @required this.peerNickname,
    @required this.peerAboutMe,
  });

  String peerId;
  String peerAvatar;
  String peerNickname;
  String peerAboutMe;
  String id;

  var listMessage;
  String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);

    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';

    readLocal();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    id = (await _firebaseAuth.currentUser()).uid;
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }
    Firestore.instance
        .collection('users')
        .document(id)
        .updateData({'chattingWith': peerId});
    setState(() {});
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  void onSendMessage(String content, int type) {
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Please enter message');
    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == id) {
      // Right (my message)
      return SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  document['type'] == 0
                      // Text
                      ? Container(
                          child: Text(
                            document['content'],
                            style: GoogleFonts.montserrat(color: Colors.white),
                          ),
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          width: 200.0,
                          decoration: BoxDecoration(
                            color: Theme.of(context).accentColor,
                            boxShadow: [
                              new BoxShadow(
                                color: Theme.of(context).primaryColor,
                                blurRadius: 10.0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: EdgeInsets.only(
                              bottom: isLastMessageRight(index) ? 5.0 : 10.0,
                              right: 10.0),
                        )
                      : Container(
                          decoration: new BoxDecoration(
                            boxShadow: [
                              new BoxShadow(
                                color: Theme.of(context).primaryColor,
                                blurRadius: 10.0,
                              ),
                            ],
                          ),
                          child: FlatButton(
                            child: Material(
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CupertinoActivityIndicator(),
                                  width: 200.0,
                                  height: 200.0,
                                  padding: EdgeInsets.all(70.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).accentColor,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Material(
                                  child: Text("not available"),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                imageUrl: document['content'],
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MorpheusPageRoute(
                                  builder: (context) =>
                                      FullPhoto(url: document['content']),
                                ),
                              );
                            },
                            padding: EdgeInsets.all(0),
                          ),
                          margin: EdgeInsets.only(
                              bottom: isLastMessageRight(index) ? 5.0 : 10.0,
                              right: 10.0),
                        )
                ],
                mainAxisAlignment: MainAxisAlignment.end,
              ),
              isLastMessageRight(index)
                  ? Container(
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(document['timestamp']))),
                        style: GoogleFonts.montserrat(
                          color: Colors.blueGrey,
                          fontSize: 12.0,
                        ),
                      ),
                      margin:
                          EdgeInsets.only(left: 50.0, top: 0.0, bottom: 5.0),
                    )
                  : Container()
            ],
            crossAxisAlignment: CrossAxisAlignment.end,
          ),
        ),
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CupertinoActivityIndicator(),
                            width: 35.0,
                            height: 35.0,
                            padding: EdgeInsets.all(10.0),
                          ),
                          imageUrl: peerAvatar,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(width: 35.0),
                document['type'] == 0
                    ? Container(
                        decoration: BoxDecoration(
                          color: Color(0xff0063F5),
                          boxShadow: [
                            new BoxShadow(
                              color: Theme.of(context).primaryColor,
                              blurRadius: 10.0,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          document['content'],
                          style: GoogleFonts.montserrat(color: Colors.white),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : document['type'] == 1
                        ? Container(
                            decoration: new BoxDecoration(
                              boxShadow: [
                                new BoxShadow(
                                  color: Theme.of(context).primaryColor,
                                  blurRadius: 10.0,
                                ),
                              ],
                            ),
                            child: FlatButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CupertinoActivityIndicator(),
                                    width: 200.0,
                                    height: 200.0,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF212121),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.asset(
                                      'images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document['content'],
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FullPhoto(
                                            url: document['content'])));
                              },
                              padding: EdgeInsets.all(0),
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
                        : Container(
                            decoration: new BoxDecoration(
                              boxShadow: [
                                new BoxShadow(
                                  color: Theme.of(context).primaryColor,
                                  blurRadius: 10.0,
                                ),
                              ],
                            ),
                            child: new Image.asset(
                              'images/${document['content']}.gif',
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          ),
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document['timestamp']))),
                      style: GoogleFonts.montserrat(
                        color: Colors.blueGrey,
                        fontSize: 12.0,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Firestore.instance
          .collection('users')
          .document(id)
          .updateData({'chattingWith': null});
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          children: <Widget>[
            Material(
              child: CachedNetworkImage(
                placeholder: (context, url) => Container(
                  child: CupertinoActivityIndicator(),
                  width: 35.0,
                  height: 35.0,
                  padding: EdgeInsets.all(10.0),
                ),
                imageUrl: peerAvatar,
                width: 35.0,
                height: 35.0,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(18.0),
              ),
              clipBehavior: Clip.hardEdge,
            ),
            SizedBox(width: 10),
            Text(
              peerNickname,
              style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(LineAwesomeIcons.info_circle),
            onPressed: () {
              Navigator.push(
                context,
                MorpheusPageRoute(
                  builder: (context) => OtherProfileScreen(
                      peerAvatar: peerAvatar,
                      peerId: peerId,
                      peerAboutMe: peerAboutMe,
                      peerNickname: peerNickname),
                ),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(LineAwesomeIcons.angle_left),
          onPressed: () {
            Navigator.pop(context, groupChatId);
          },
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                buildListMessage(),
                buildInput(),
              ],
            ),
            buildLoading()
          ],
        ),
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
              color: Theme.of(context).primaryColor,
            )
          : Container(),
    );
  }

  Widget buildInput() {
    return Material(
      color: Theme.of(context).primaryColor,
      child: Container(
        color: Theme.of(context).primaryColor,
        padding: EdgeInsets.only(left: 5, right: 5),
        child: Row(
          children: <Widget>[
            Container(
              decoration: new BoxDecoration(
                boxShadow: [
                  new BoxShadow(
                    color: Theme.of(context).primaryColor,
                    blurRadius: 10.0,
                  ),
                ],
              ),
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: Container(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 0,
                  color: Theme.of(context).accentColor,
                  child: IconButton(
                    icon: Icon(Ionicons.ios_image),
                    onPressed: getImage,
                    color: Color(0xff0061F5),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Container(
                decoration: new BoxDecoration(
                  boxShadow: [
                    new BoxShadow(
                      color: Theme.of(context).primaryColor,
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Card(
                    color: Theme.of(context).accentColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: TextField(
                        style: GoogleFonts.montserrat(
                            color: Colors.white, fontSize: 15.0),
                        controller: textEditingController,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Enter message...',
                          hintStyle: GoogleFonts.montserrat(
                              color: Colors.grey, fontSize: 14),
                        ),
                        focusNode: focusNode,
                      ),
                    )),
              ),
            ),
            Container(
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  new BoxShadow(
                    color: Theme.of(context).primaryColor,
                    blurRadius: 10.0,
                  ),
                ],
              ),
              margin: EdgeInsets.symmetric(horizontal: 0.0),
              child: Container(
                height: 50,
                width: 50,
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60.0),
                  ),
                  color: Color(0xff0063F5),
                  child: IconButton(
                    highlightColor: Theme.of(context).primaryColor,
                    color: Colors.white,
                    icon: Icon(Ionicons.ios_send),
                    focusColor: Theme.of(context).primaryColor,
                    onPressed: () =>
                        onSendMessage(textEditingController.text, 0),
                  ),
                ),
              ),
            ),
          ],
        ),
        width: double.infinity,
        height: 60.0,
        margin: EdgeInsets.only(bottom: 5, right: 0, left: 0),
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(child: CupertinoActivityIndicator())
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .document(groupChatId)
                  .collection(groupChatId)
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
                      reverse: true,
                      controller: listScrollController,
                    ),
                  );
                }
              },
            ),
    );
  }
}
