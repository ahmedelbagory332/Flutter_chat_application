import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_application/Screens/ChatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:chat_application/Moodels/ProfileModel.dart';
import 'package:chat_application/Moodels/Profile.dart';
import 'package:chat_application/checkConnection.dart';


FirebaseUser loggedInUser;
final _auth = FirebaseAuth.instance;
final _scaffoldKey = GlobalKey<ScaffoldState>();

class ProfileScreen extends StatefulWidget {
  final String id ;


  ProfileScreen(this.id);



  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name;

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

      }
    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Profile',style: TextStyle(
              fontSize: MediaQuery
                  .of(context)
                  .size
                  .width * .05
          ),),
          backgroundColor: Color(0xFF13223f),
          actions: <Widget>[
        IconButton(
        icon: Icon(Icons.message,size:MediaQuery
            .of(context)
            .size
            .width * .07 ,),
        onPressed: () {

          if(loggedInUser.uid == widget.id)
            {
              _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content: const Text('You can not send message to your self'),
                  action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: _scaffoldKey.currentState.hideCurrentSnackBar),
                ),
              );
            }
            else
            {

              checkConnection().then((check){

                if(check){
                  Firestore.instance
                      .collection('Users')
                      .document(loggedInUser.uid)
                      .updateData({'chatWith': widget.id});
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen(loggedInUser.uid,widget.id,name)));
                }
                else
                {
                  _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: const Text('Check Your Internet Connection'),
                      action: SnackBarAction(
                          label: 'UNDO',
                          onPressed: _scaffoldKey.currentState.hideCurrentSnackBar),
                    ),
                  );
                }

              });




            }

        },
        )],

        ),
          backgroundColor: Color(0xFF263859),
          body: Padding(
            padding: const EdgeInsets.only(top:15.0),
            child: Column(
              children: <Widget>[

                StreamBuilder(
                    stream: Firestore.instance
                        .collection('Users')
                        .document(widget.id)
                        .snapshots(),
                         builder: (context , snapshot){
                           if (!snapshot.hasData) {
                             return Center(
                               child: SpinKitCircle(
                                 color: Colors.white,
                                 size: 100.0,
                               ),
                             );
                           }

                            name = snapshot.data['name'];
                           String email = snapshot.data['email'];
                           String about = snapshot.data['about'];
                           String photo = snapshot.data['photoUrl'];
                           Timestamp time = snapshot.data['timeCreation'];
                           String timeCreation = DateFormat("dd-MM-yyyy").format(time.toDate());

                           List<ProfileModel> User = [
                             ProfileModel('Name',name, Icons.person),
                             ProfileModel('Email',email, Icons.email),
                             ProfileModel('About',about, Icons.report),
                             ProfileModel('Time Creation',timeCreation, Icons.access_time)

                           ];

                           return Column(
                             children: <Widget>[
                               photo.length == 0
                                   ? SizedBox(
                                 width:  MediaQuery
                                     .of(context)
                                     .size
                                     .width * .4,
                                 child: Icon(
                                   Icons.account_circle,
                                   color: Colors.black,
                                   size:  MediaQuery
                                       .of(context)
                                       .size
                                       .width * .4,
                                 ),
                               )
                                   : CachedNetworkImage(
                                   imageBuilder: (context, imageProvider) => Container(
                                     width:  MediaQuery
                                         .of(context)
                                         .size
                                         .width * .4,
                                     height:  MediaQuery
                                         .of(context)
                                         .size
                                         .width * .4,
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
                                     width: 100.0,
                                     height: 100.0,
                                   ),
                                   errorWidget: (context, url, error) =>
                                       Icon(Icons.error, size: 150),
                                   width: 300.0,
                                   height: 200.0,
                                   fit: BoxFit.cover,
                                   imageUrl: photo.toString()
                               ),
                               ListView.builder(
                                   scrollDirection: Axis.vertical,
                                   shrinkWrap: true,
                                   itemCount: User.length,
                                   itemBuilder: (context , index){
                                     return Profile(User[index].title,User[index].subtitle,User[index].icon);
                                   }
                               ),
                             ],
                           );



                         }
                )
              ],
            ),
          )
        ),
    );

  }
}

