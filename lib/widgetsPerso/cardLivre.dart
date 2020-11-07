import 'package:flutter/material.dart';

class CardLivre extends Card{

  CardLivre (String titre, String info, bool favori):
      super(
          elevation: 10.0,
          color: Colors.white,
          child: new Container(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: <Widget> [
                new Expanded(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Container(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: new Text(titre, style: new TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      new Text(info),
                    ],
                  ),
                ),
                new IconButton(
                  icon: new Icon(!favori ? Icons.favorite_border : Icons.favorite),
                  color: Colors.redAccent,
                  onPressed: (){

                },),
              ],
            ),
          )
      );
}