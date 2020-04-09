import 'package:chat_application/UserStatus/LoginStatus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'HomeScreen.dart';

class LogingScreen extends StatefulWidget {
  @override
  _LogingScreenState createState() => _LogingScreenState();
}

class _LogingScreenState extends State<LogingScreen> {

  final emailConroler = TextEditingController();
  final passwordConroler = TextEditingController();

  String  email  , password;
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  ProgressDialog pr;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
            child: MaterialButton(
              onPressed: () async{

                if (emailConroler.text.isEmpty || passwordConroler.text.isEmpty) {

                  _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: const Text('Check Your Info.'),
                      action: SnackBarAction(
                          label: 'UNDO', onPressed: _scaffoldKey.currentState.hideCurrentSnackBar),
                    ),
                  );
                }
                else
                  {
                    pr.show();
                    try {
                      final newUser = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
                      if (newUser != null) {
                        pr.hide();
                        LoginStatus().writeStaus(true);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));

                      }

                    }
                    catch(e)
                    {
                      pr.hide();
                      print('bigo error $e');
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content:  Text('$e'),
                          action: SnackBarAction(
                              label: 'UNDO', onPressed:  _scaffoldKey.currentState
                              .hideCurrentSnackBar),
                        ),
                      );

                    }

                  }


              },
              minWidth: MediaQuery.of(context).size.height *.4,
              child: Text(
                'Log In',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width *.05
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
