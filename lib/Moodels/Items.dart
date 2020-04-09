import 'package:flutter/material.dart';

class Items extends StatelessWidget {
  final String title;
  final IconData icon;


  Items(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return ListTile(
            title: Text(title,style: TextStyle(fontSize: MediaQuery.of(context).size.width *.05),),
            leading: Icon(icon,size: MediaQuery.of(context).size.width *.07),
    );
  }

}
