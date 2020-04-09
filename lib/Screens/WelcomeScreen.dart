import 'package:chat_application/Screens/LogingScreen.dart';
import 'package:chat_application/Screens/RegisterScreen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  AnimationController controller;


  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: const Duration(milliseconds: 700)
        , vsync: this
    );
    controller.addListener((){
      setState(() {

      });
    });
    controller.forward(from: 0.0);
  }


  @override
  Widget build(BuildContext context) {



      return SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xFF263859),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(200.0),
                    bottomLeft: Radius.circular(200.0)),
                child: Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * .4,
                  decoration: BoxDecoration(
                      color: Color(0xFF6b778d)
                  ),
                  child: Row (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Hero(
                        tag: 'logo',
                        child: RotationTransition(
                          child: Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * .2,
                            child: SizedBox(
                              child: Image.asset('images/welcom.png'),
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * .3,
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height * .3,
                            ),
                          ),
                          turns: Tween(begin: 0.0, end: 1.0).animate(
                              controller),

                        ),
                      ),
                      Text('Bego Chat',
                        style: TextStyle(
                            fontSize: MediaQuery
                                .of(context)
                                .size
                                .width * .1
                            ,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),

              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery
                      .of(context)
                      .size
                      .width * .2),
                  child: Column(
                    children: <Widget>[
                      Material(
                        color: Color(0xffff6768),
                        borderRadius: BorderRadius.circular(30.0),
                        elevation: 10.0,
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                            },
                          minWidth: MediaQuery
                              .of(context)
                              .size
                              .height * .4,
                          child: Text(
                            'Register',
                            style: TextStyle(
                                fontSize: MediaQuery
                                    .of(context)
                                    .size
                                    .width * .05
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery
                            .of(context)
                            .size
                            .height * .02,
                      ),
                      Material(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(30.0),
                        elevation: 10.0,
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LogingScreen()));
                          },
                          minWidth: MediaQuery
                              .of(context)
                              .size
                              .height * .4,
                          child: Text(
                            'Log In',
                            style: TextStyle(
                                fontSize: MediaQuery
                                    .of(context)
                                    .size
                                    .width * .05
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],

          ),


        ),
      );

  }
}
