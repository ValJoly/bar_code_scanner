import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:bar_code_scanner/mesObjets/dataLivre.dart';

class CardLivre extends StatelessWidget{
  final ui.VoidCallback ajouterFavori;

  DataLivre cl_livre = null;

  CardLivre (DataLivre livre, this.ajouterFavori) {
    this.cl_livre = livre;
  }

  @override
  Widget build(BuildContext context) {
    return
      new Card(elevation: 10.0,
        color: Colors.white,
        child: new Container(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    new Container(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: new Text(this.cl_livre.data_titre,
                          style: new TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    new Text(this.cl_livre.data_auteur + ", paru en " +
                        this.cl_livre.data_datePublication + ", " + this.cl_livre.data_editeur),
                  ],
                ),
              ),
              new IconButton(
                icon: new Icon(
                  this.cl_livre.data_favori ? Icons.favorite : Icons.favorite_border),
                  color: Colors.redAccent,
                  onPressed: this.ajouterFavori,
              ),
            ],
          ),
        )
    );
  }
}