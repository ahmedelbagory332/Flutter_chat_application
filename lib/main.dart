import 'dart:async';

import 'package:chat_application/Screens/HomeScreen.dart';
import 'package:chat_application/Screens/LogingScreen.dart';
import 'package:chat_application/Screens/RegisterScreen.dart';
import 'package:flutter/material.dart';
import 'package:chat_application/Screens/WelcomeScreen.dart';
import 'package:chat_application/UserStatus/LoginStatus.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<bool> checkIsLogin() async {

    var status = await LoginStatus().readStaus();
    print('get status from prefs: $status');

    return status;
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

//    checkIsLogin().then((stats)=> isLogin = stats);
//    if(await isLogin)
//      {
//        print('$isLogin');
//      }
//      else
//        {
//          print('$isLogin');
//
//        }


    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
      // ignore: unrelated_type_equality_checks
      home:FutureBuilder(
          future:checkIsLogin() ,
          builder: ( context, snapshot){

            if(snapshot.data == true)
              {
                return HomeScreen();
              }
            else
              {
                return WelcomeScreen();
              }

          }
      )
          ,

    );
  }
}



