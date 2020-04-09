import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Cards extends StatelessWidget {
  final String imgUrl;
  final String name;
  final String about;

  Cards(this.imgUrl, this.name, this.about);

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(MediaQuery
            .of(context)
            .size
            .width * .04,),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.white,
        elevation: 20,
        child: Column(
          children: <Widget>[
            imgUrl.length==0?SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * .4,


              child: Icon(
                Icons.account_circle,
                color: Colors.black,
                 size: MediaQuery
                     .of(context)
                     .size
                     .width * .4,

              ),
            )
            :
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CachedNetworkImage(
                placeholder: (context, url) => Container(
                  child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFff6768))),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * .4,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * .2,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
                width: MediaQuery
                    .of(context)
                    .size
                    .width * .4,
                fit: BoxFit.cover,
                imageUrl: imgUrl
              ),
            ),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: MediaQuery
                    .of(context)
                    .size
                    .width * .04,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Text(
                about,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: MediaQuery
                      .of(context)
                      .size
                      .width * .04,
                ),
              ),
            )
          ],
        ));
  }
}
