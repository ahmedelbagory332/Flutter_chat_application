import 'package:chat_application/UserStatus/LoginStatus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'HomeScreen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameConroler = TextEditingController();
  final emailConroler = TextEditingController();
  final aboutConroler = TextEditingController();
  final passwordConroler = TextEditingController();

  String name , email , about , password;
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  FirebaseUser loggedInUser;
  ProgressDialog pr;
  final _scaffoldKey = GlobalKey<ScaffoldState>();


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
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);

    return Scaffold(
      key: _scaffoldKey,
        backgroundColor: Color(0xFF263859),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Hero(
                tag: 'logo',
                child: Container(
                  child: SizedBox(
                    child: Image.asset('images/welcom.png'),
                    width: MediaQuery.of(context).size.width *.5,
                    height: MediaQuery.of(context).size.height *.5,
                  ),
                ),
              ),
            ),

            Flexible(
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width *.03,vertical:MediaQuery.of(context).size.width *.03 ),
                child: TextField(
                  controller: nameConroler,
                  onChanged: (val){
                    name = val;
                  },
                  textAlign: TextAlign.center,
                    decoration: InputDecoration(
                     labelText: 'Enter your name',
                     labelStyle: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.width *.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan, width: MediaQuery.of(context).size.width *.003),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),

                    ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height *.03,
            )
            ,
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: emailConroler,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (val){
                    email = val;
                  },
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Enter your email',
                    labelStyle: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.width *.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan, width: MediaQuery.of(context).size.width *.003 ),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),

                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height *.03,
            )
            ,
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: aboutConroler,
                  onChanged: (val){
                    about = val;
                  },
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Enter your about like(whatsApp)',
                    labelStyle: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.width *.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan, width: MediaQuery.of(context).size.width *.003 ),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),

                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height *.03,
            )
            ,
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: passwordConroler,
                  obscureText: true,

                  onChanged: (val){
                    password = val;

                  },
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Enter your passowrd',
                    labelStyle: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.width *.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan, width: MediaQuery.of(context).size.width *.003 ),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),

                  ),
                ),
              ),
            ),
          SizedBox(
            height: MediaQuery.of(context).size.height *.03 ,
          )
          ,
            Material(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(30.0),
              elevation: 10.0,
              child: Builder(builder: (BuildContext context){
                return MaterialButton(
                  onPressed: () async{

                    pr.show();
                      if (nameConroler.text.isEmpty || emailConroler.text.isEmpty
                      ||aboutConroler.text.isEmpty || passwordConroler.text.isEmpty) {
                        pr.hide();
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            content: const Text('Check Your Info.'),
                            action: SnackBarAction(
                                label: 'UNDO', onPressed: _scaffoldKey.currentState.hideCurrentSnackBar),
                          ),
                        );
                      }
                      else {

                       try {
                         final newUser = await _auth.createUserWithEmailAndPassword(
                             email: email.trim(), password: password);
                         if (newUser != null) {

                             getCurrentUser();
                           _firestore.collection('Users').document(newUser.user.uid).setData({
                             'id': '',
                             'name': name,
                             'email': email,
                             'about': about,
                             'photoUrl': "",
                             'timeCreation': DateTime.now(),
                             'chatWith': "",
                             'Token': "",
                           }).whenComplete((){
                             print('Document Added');
                             pr.hide();


                           });
                             LoginStatus().writeStaus(true);
                             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));


                         }
                        }
                       catch(e)
                       {
                         pr.hide();
                         print('bigo error $e');
                         Scaffold.of(context).showSnackBar(
                           SnackBar(
                             content:  Text('$e'),
                             action: SnackBarAction(
                                 label: 'UNDO', onPressed: Scaffold
                                 .of(context)
                                 .hideCurrentSnackBar),
                           ),
                         );
                       }

                      }

                  },
                  minWidth: MediaQuery.of(context).size.height *.4,
                  child: Text(
                    'Register',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width *.05
                    ),
                  ),
                );
              }

            ),
            )
          ],
        ),
      );

  }
}
