import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_application/Moodels/ItemModel.dart';
import 'package:chat_application/Moodels/Items.dart';
import 'package:chat_application/Screens/WelcomeScreen.dart';
import 'package:chat_application/UserStatus/LoginStatus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_application/Moodels/CardModel.dart';
import 'package:chat_application/Moodels/Cards.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For File Upload To Firestore
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:launch_review/launch_review.dart';
import 'package:path/path.dart' as Path;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:chat_application/Screens/ProfileScreen.dart';
import 'package:chat_application/checkConnection.dart';

FirebaseUser loggedInUser;
final _auth = FirebaseAuth.instance;
final _firestore = Firestore.instance;
var size;
double itemHeight;
double itemWidth;
ProgressDialog pr;
bool iSloading = true;
String appBarTitle = 'Home';
List<ItemModel> listSettings = [
  ItemModel('Log Out', Icons.close),
  ItemModel('Rate Applicatio', Icons.rate_review),
  ItemModel('Connect Us or Reported a problem', Icons.report),
];

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int pageNumber = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //Navigation pages
  Widget currentPage = UsersStream();

  Container pageChooser(int pageNum) {
    switch (pageNum) {
      case 0:
        appBarTitle = 'Home';
        return Container(
          child: UsersStream(),
        );
        break;
      case 1:
        appBarTitle = 'Edit Profile';
        return Container(
          child: UserEditInfoStream(),
        );
        break;
      case 2:
        appBarTitle = 'Settings';
        return Container(
          child: Settings(),
        );
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        final QuerySnapshot result = await Firestore.instance
            .collection('Users')
            .where('id', isEqualTo: loggedInUser.uid)
            .getDocuments();
        final List<DocumentSnapshot> documents = result.documents;
        if (documents.length == 0) {
          // Update data to server if new user
          Firestore.instance
              .collection('Users')
              .document(loggedInUser.uid)
              .updateData({'id': loggedInUser.uid})
                ..whenComplete(() {
                  print('Document Updated');
                });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    itemHeight = (size.height) / 2;
    itemWidth = size.width / 2;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            appBarTitle,
            style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),
          ),
          backgroundColor: Color(0xFF13223f),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width * .07,
                ),
                onPressed: () async {
                  checkConnection().then((check) {
                    if (check) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ProfileScreen(loggedInUser.uid)));
                    } else {
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: const Text('Check Your Internet Connection'),
                          action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: _scaffoldKey
                                  .currentState.hideCurrentSnackBar),
                        ),
                      );
                    }
                  });
                })
          ],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          height: 55,
          backgroundColor: Color(0xFF263859),
          buttonBackgroundColor: Colors.lightBlue[900],
          color: Color(0xFF13223f),
          items: <Widget>[
            Icon(Icons.home, size: MediaQuery.of(context).size.width * .07),
            Icon(Icons.edit, size: MediaQuery.of(context).size.width * .07),
            Icon(Icons.settings, size: MediaQuery.of(context).size.width * .07),
          ],
          animationDuration: Duration(milliseconds: 300),
          onTap: (index) {
            //Handle button tap

            checkConnection().then((check) {
              if (check) {
                setState(() {
                  currentPage = pageChooser(index);
                });
              } else {
                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: const Text('Check Your Internet Connection'),
                    action: SnackBarAction(
                        label: 'UNDO',
                        onPressed:
                            _scaffoldKey.currentState.hideCurrentSnackBar),
                  ),
                );
              }
            });
          },
        ),
        backgroundColor: Color(0xFF263859),
        body: currentPage,
      ),
    );
  }
}

class UsersStream extends StatefulWidget {
  @override
  _UsersStreamState createState() => _UsersStreamState();
}

class _UsersStreamState extends State<UsersStream> {
  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('Users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          iSloading = true;
          return Center(
              child: SpinKitCircle(
            color: Colors.white,
            size: 100.0,
          ));
        }
        final users = snapshot.data.documents;
        List<CardModel> cardmodelList = [];
        for (var user in users) {
          final imgurl = user.data['photoUrl'];
          final name = user.data['name'];
          final about = user.data['about'];
          final id = user.data['id'];

          final card = CardModel(imgurl, name, about, id);

          cardmodelList.add(card);
        }
        return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: (itemWidth / itemHeight),
            ),
            itemCount: cardmodelList.length,
            itemBuilder: (context, index) => GestureDetector(
                  child: Cards(cardmodelList[index].imgUrl,
                      cardmodelList[index].name, cardmodelList[index].about),
                  onTap: () {
                    checkConnection().then((check) {
                      if (check) {
                        print('id of tapped ${cardmodelList[index].id}');
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ProfileScreen(cardmodelList[index].id)));
                      } else {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text('Check Your Internet Connection'),
                            action: SnackBarAction(
                                label: 'UNDO',
                                onPressed:
                                    Scaffold.of(context).hideCurrentSnackBar),
                          ),
                        );
                      }
                    });
                  },
                ));
      },
    );
  }
}

class UserEditInfoStream extends StatefulWidget {
  @override
  _UserEditInfoStreamState createState() => _UserEditInfoStreamState();
}

class _UserEditInfoStreamState extends State<UserEditInfoStream> {
  var nameConroler = TextEditingController();
  var aboutConroler = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String name = "", about = "";
  bool showSpinner = false;
  File _image;

  Future uploadFile() async {
    try {
      pr = new ProgressDialog(context);

      await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
        setState(() {
          _image = image;
        });
      });
      await pr.show();

      StorageReference storageReference = FirebaseStorage.instance.ref().child(
          '${loggedInUser.uid}/UserProfille/${Path.basename(_image.path)}');
      StorageUploadTask uploadTask = storageReference.putFile(_image);
      await uploadTask.onComplete;
      print('File Uploaded');
      storageReference.getDownloadURL().then((fileURL) {
        setState(() {
          Firestore.instance.collection('Users').document(loggedInUser.uid);
          Map<String, String> data = {
            'photoUrl': fileURL,
          };

          Firestore.instance
              .collection('Users')
              .document(loggedInUser.uid)
              .updateData(data)
              .whenComplete(() {
            print('Document Updated');
            pr.hide();
          });
        });
      });
    } catch (e) {
      print('bego erorr $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    return StreamBuilder(
      stream: Firestore.instance
          .collection('Users')
          .document(loggedInUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SpinKitCircle(
              color: Colors.white,
              size: 100.0,
            ),
          );
        }

        String url = snapshot.data['photoUrl'];

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Color(0xFF263859),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: url.length == 0
                    ? GestureDetector(
                        onTap: () {
                          // chooseFile();
                          uploadFile();
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * .4,
                          child: Icon(
                            Icons.account_circle,
                            color: Colors.black,
                            size: MediaQuery.of(context).size.width * .4,
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          // chooseFile();
                          uploadFile();
                        },
                        child: CachedNetworkImage(
                            imageBuilder: (context, imageProvider) => Container(
                                  width: MediaQuery.of(context).size.width * .4,
                                  height:
                                      MediaQuery.of(context).size.height * .2,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                            placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFFff6768))),
                                  width: MediaQuery.of(context).size.width * .4,
                                ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error, size: 150),
                            width: MediaQuery.of(context).size.width * .4,
                            fit: BoxFit.cover,
                            imageUrl: url.toString()),
                      ),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * .03,
                      vertical: MediaQuery.of(context).size.width * .03),
                  child: TextField(
                    controller: nameConroler,
                    onChanged: (val) {
                      name = val;
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Enter yout name',
                      labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * .05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.cyan,
                            width: MediaQuery.of(context).size.width * .003),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .03,
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * .03,
                      vertical: MediaQuery.of(context).size.width * .03),
                  child: TextField(
                    controller: aboutConroler,
                    onChanged: (val) {
                      about = val;
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Enter your about',
                      labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * .05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.cyan,
                            width: MediaQuery.of(context).size.width * .003),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .03,
              ),
              Material(
                color: Colors.lightBlue[900],
                borderRadius: BorderRadius.circular(30.0),
                elevation: 10.0,
                child: Builder(builder: (BuildContext context) {
                  return MaterialButton(
                    onPressed: () {
                      try {
                        if (nameConroler.text.isEmpty) {
                          if (aboutConroler.text.isEmpty) {
                            _scaffoldKey.currentState.showSnackBar(
                              SnackBar(
                                content: const Text('Check Your Info.'),
                                action: SnackBarAction(
                                    label: 'UNDO',
                                    onPressed: _scaffoldKey
                                        .currentState.hideCurrentSnackBar),
                              ),
                            );
                          } else {
                            pr.show();

                            Firestore.instance
                                .collection('Users')
                                .document(loggedInUser.uid);
                            Map<String, String> data = {
                              'about': about, // Updating Document Reference
                            };

                            Firestore.instance
                                .collection('Users')
                                .document(loggedInUser.uid)
                                .updateData(data)
                                .whenComplete(() {
                              print('Document Updated');
                              _scaffoldKey.currentState.showSnackBar(
                                SnackBar(
                                  content: const Text('Updated.'),
                                ),
                              );
                              pr.hide();
                              nameConroler.clear();
                              aboutConroler.clear();
                            });
                          }
                        } else if (aboutConroler.text.isEmpty) {
                          if (nameConroler.text.isEmpty) {
                            _scaffoldKey.currentState.showSnackBar(
                              SnackBar(
                                content: const Text('Check Your Info.'),
                                action: SnackBarAction(
                                    label: 'UNDO',
                                    onPressed: _scaffoldKey
                                        .currentState.hideCurrentSnackBar),
                              ),
                            );
                          } else {
                            pr.show();

                            Firestore.instance
                                .collection('Users')
                                .document(loggedInUser.uid);
                            Map<String, String> data = {
                              'name': name, // Updating Document Reference
                            };

                            Firestore.instance
                                .collection('Users')
                                .document(loggedInUser.uid)
                                .updateData(data)
                                .whenComplete(() {
                              print('Document Updated');
                              _scaffoldKey.currentState.showSnackBar(
                                SnackBar(
                                  content: const Text('Updated.'),
                                ),
                              );
                              pr.hide();
                              nameConroler.clear();
                              aboutConroler.clear();
                            });
                          }
                        } else {
                          pr.hide();

                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: const Text('Check Your Info..'),
                            ),
                          );
                          nameConroler.clear();
                          aboutConroler.clear();
                        }
                      } catch (e) {
                        print('bego error  $e');
                      }
                    },
                    minWidth: MediaQuery.of(context).size.height * .4,
                    child: Text(
                      'Update',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * .05),
                    ),
                  );
                }),
              )
            ],
          ),
        );
      },
    );
  }
}

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
            width: MediaQuery.of(context).size.width * .5,
            child: Image.asset('images/settings.png')),
        Expanded(
          child: ListView.builder(
            itemCount: listSettings.length,
            itemBuilder: (context, index) => GestureDetector(
              child: Items(listSettings[index].title, listSettings[index].icon),
              onTap: () async {
                switch (index) {
                  case 0:
                    _auth.signOut();
                    LoginStatus().writeStaus(false);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WelcomeScreen()));

                    break;
                  case 1:
                    LaunchReview.launch(
                        androidAppId: "bego.chat.bagory.chat_application");
                    break;
                  case 2:
                    final Email email = Email(
                      body: '',
                      subject: 'BegoChat',
                      recipients: ['ahmedelbagory63@gmail.com'],
                      isHTML: false,
                    );

                    await FlutterEmailSender.send(email);
                    break;
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
