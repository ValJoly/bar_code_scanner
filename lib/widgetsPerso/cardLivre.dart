import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:bar_code_scanner/mesObjets/dataLivre.dart';

class CardLivre extends StatefulWidget {

  // attributs
  DataLivre cl_livre = null;

  // constructeur
  CardLivre(DataLivre livre) {
    this.cl_livre = livre;
  }

  @override
  State<CardLivre> createState() {
    return _CardLivreState(this.cl_livre);
  }

} // classe CardLivre






class _CardLivreState extends State<CardLivre>{

  // attributs du state
  DataLivre s_livre;

  // constructeur
  _CardLivreState(DataLivre livre) {
    this.s_livre  = livre;
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
                      child: new Text(this.s_livre.data_titre,
                          style: new TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    new Text("Auteur: "+this.s_livre.data_auteur + ", date de publication: " +
                        this.s_livre.data_datePublication + ", éditeur: " + this.s_livre.data_editeur),
                  ],
                ),
              ),
              new IconButton(
                icon: new Icon(
                  this.s_livre.data_favori ? Icons.favorite : Icons.favorite_border),
                  color: Colors.redAccent,
                  onPressed: (){
                  setState(() {
                    this.s_livre.data_favori = !this.s_livre.data_favori;
                  });
                  },
              ),
            ],
          ),
        )
    );
  }

}