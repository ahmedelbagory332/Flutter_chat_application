import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;
final _auth = FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {
  ChatScreen(this.currentUserId, this.peerUserId, this.name);

  final String currentUserId;
  final String peerUserId;
  final String name;
  int size ;

  String ChatId = '';




  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final messageTextController = TextEditingController();
  String messageText;
  File _image;
  ProgressDialog pr;

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }


  @override
  void initState() {
    getCurrentUser();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    updateStatus('offline');
    Firestore.instance
        .collection('Users')
        .document(widget.currentUserId)
        .updateData({'chatWith': ""});
    super.dispose();
  }

@override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
      switch(state)
      {
        case AppLifecycleState.paused:
          updateStatus('offline');
          break;
        case AppLifecycleState.inactive:
          updateStatus('offline');
          break;
        case AppLifecycleState.detached:
          updateStatus('offline');
          break;
        case AppLifecycleState.resumed:
          updateStatus('online');
          break;
      }

  }





  Future uploadFile(String chat) async {
    try {
      pr = new ProgressDialog(context);

      await ImagePicker.pickImage(source: ImageSource.gallery)
          .then((image) {
        setState(() {
          _image = image;
        });
      });
      await pr.show();

      StorageReference storageReference = FirebaseStorage.instance.ref().child(
          '${widget.currentUserId}/UserProfille/${Path.basename(_image.path)}');
      StorageUploadTask uploadTask = storageReference.putFile(_image);
      await uploadTask.onComplete;
      print('File Uploaded');
      storageReference.getDownloadURL().then((fileURL) {
        setState(() {
          _firestore
              .collection('Messages')
              .document(chat)
              .collection(chat)
              .document('${DateTime.now().millisecondsSinceEpoch}')
              .setData({
            'message': '',
            'sender': loggedInUser.email,
            'photo': fileURL
          }).whenComplete((){
            pr.hide();
          });
        });
      });
    } catch (e) {
      print('bego erorr $e');
    }
  }

  void sendMessage(int type, String mesg, String chat) {
    if (type == 1) {
      _firestore
          .collection('Messages')
          .document(chat)
          .collection(chat)
          .document('${DateTime.now().millisecondsSinceEpoch}')
          .setData(
              {'message': mesg, 'sender': loggedInUser.email, 'photo': ""});
    } else  {
      uploadFile(chat);
    }
  }

void updateStatus(String statues){
  Firestore.instance
      .collection('Users')
      .document(widget.currentUserId)
      .updateData({
    'type': statues,
  });
}


  @override
  Widget build(BuildContext context) {
    if (widget.currentUserId.hashCode <= widget.peerUserId.hashCode) {
      widget.ChatId = '${widget.currentUserId}-${widget.peerUserId}';
    } else {
      widget.ChatId = '${widget.peerUserId}-${widget.currentUserId}';
    }

    updateStatus('online');

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF13223f),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: TextStyle(color: Colors.white, fontSize: MediaQuery
                    .of(context)
                    .size
                    .width * .06),
              ),
              widget.currentUserId==widget.peerUserId?
          StreamBuilder(
            stream: Firestore.instance
                .collection('Users')
                .document(widget.currentUserId)
                .snapshots(),
            builder: (context,  snapshot) {

             String status = snapshot.data['type'];

              return Text('$status',style: TextStyle(color: Colors.white,fontSize: MediaQuery
                  .of(context)
                  .size
                  .width * .04),);

            }
            ,
          )
              :
            StreamBuilder(
            stream: Firestore.instance
                .collection('Users')
            .document(widget.peerUserId)
            .snapshots(),
          builder: (context, snapshot) {

            String status = snapshot.data['type'];
            return new Text(status,style: TextStyle(color: Colors.white,fontSize: MediaQuery
                .of(context)
                .size
                .width * .04),);
          }
      ),
            ],
          ),
        ),
        backgroundColor: Color(0xFF263859),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(widget.ChatId),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.lightBlue[900], width: MediaQuery
                      .of(context)
                      .size
                      .width *.004),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * .1,
                    child: FlatButton(
                      onPressed: () {
                        messageTextController.clear();
                        sendMessage(2, messageText, widget.ChatId);
                      },
                      child: Icon(Icons.photo,size: MediaQuery
                          .of(context)
                          .size
                          .width * .09,),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                          fontSize: MediaQuery
                              .of(context)
                              .size
                              .width * .05
                      ) ,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                        if(messageText.length==0){
                          updateStatus('online');

                        }else {
                          updateStatus('typing...');
                        }

                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: MediaQuery
                                .of(context)
                                .size
                                .width * .02, horizontal: MediaQuery
                            .of(context)
                            .size
                            .width * .05),
                        hintText: 'Type a message',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * .2,
                    child: FlatButton(
                      onPressed: () {
                        messageTextController.clear();


                        if(messageText.length != 0)
                          {
                            updateStatus('online');

                          }


                        if (messageText.isEmpty) {
                        } else {
                          sendMessage(1, messageText, widget.ChatId);
                        }
                      },
                      child: Icon(Icons.send,size: MediaQuery
                          .of(context)
                          .size
                          .width * .09,),
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
}

class MessagesStream extends StatelessWidget {
  MessagesStream(this.chatId);

  final String chatId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Messages')
          .document(chatId)
          .collection(chatId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SpinKitCircle(
            color: Colors.white,
            size: 100.0,
          );
        }
        final messages = snapshot.data.documents.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data['message'];
          final messageSender = message.data['sender'];
          final imageSender = message.data['photo'];

          final currentUser = loggedInUser.email;

          final messageBubble = MessageBubble(
            text: messageText,
            isMe: currentUser == messageSender,
            img : imageSender
          );

          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.text, this.isMe, this.img});

  final String text;
  final String img;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[



          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlue[900] : Colors.white70,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: text.isEmpty
                  ? CachedNetworkImage(
                      imageBuilder: (context, imageProvider) => Container(
                            height: 500.0,
                            decoration: BoxDecoration(
                              borderRadius: isMe
                                  ? BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0))
                                  : BorderRadius.only(
                                bottomLeft: Radius.circular(30.0),
                                bottomRight: Radius.circular(30.0),
                                topRight: Radius.circular(30.0),
                              ),
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                      placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                                strokeWidth: 1.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFff6768))),
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * .4,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * .2,
                          ),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error, size: 150),
                      width: 300.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                      imageUrl: img.toString())
                  : Text(
                      text,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                        fontSize: MediaQuery
                            .of(context)
                            .size
                            .width * .05,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
