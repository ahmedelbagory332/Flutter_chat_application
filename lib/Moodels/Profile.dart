import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  Profile(this.title,this.subtitle ,this.icon);

  @override
  Widget build(BuildContext context) {
    return ListTile(
            title: Text(title,style: TextStyle(fontSize: MediaQuery.of(context).size.width *.05),),
            subtitle: Text(subtitle,style: TextStyle(fontSize: MediaQuery.of(context).size.width *.04),),
            leading: Icon(icon,size: MediaQuery.of(context).size.width *.07),
    );
  }

}
