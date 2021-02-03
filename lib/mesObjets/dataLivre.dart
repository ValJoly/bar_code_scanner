import 'dart:math';

//import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class DataLivre {

  // attributs du dataLivre
  String data_titre;
  String data_auteur;
  String data_datePublication;
  String data_editeur;
  String data_ISBN;
  String data_urlImage;
  String data_synopsis;
  bool data_favori;
  bool data_lu;
  bool data_envie;
  DateTime data_dateAjout;

  // constructeur
  DataLivre(String titre, String auteur, String datePublication, String editeur, String isbn, String urlImage, String synopsis, bool lu, bool envie, DateTime dateAjout){
    this.data_titre = titre;
    this.data_auteur = auteur;
    this.data_datePublication = datePublication;
    this.data_editeur = editeur;
    this.data_ISBN = isbn;
    this.data_urlImage = urlImage;
    this.data_synopsis = synopsis;
    this.data_favori = false;
    this.data_lu = lu;
    this.data_envie = envie;
    this.data_dateAjout = dateAjout;


  }

  Map<String, dynamic> toJson() =>
      {
        'ISBN': data_ISBN,
        'title': data_titre,
        'author': data_auteur,
        'publish_date' : data_datePublication,
        'editor' : data_editeur,
        'imgUrl' : data_urlImage,
        'description' : data_synopsis,
        'add_date' : DateFormat('yyyy-MM-dd HH:mm:ss').format(data_dateAjout),
        'favorite' : data_favori,
        'read' : data_lu,
        'wishlist' : data_envie
      };

  DataLivre.fromJson(Map<String, dynamic> json)
      : data_ISBN = json['ISBN'],
        data_titre = json['title'],
        data_auteur = json['author'],
        data_datePublication = json['publish_date'],
        data_editeur = json['editor'],
        data_urlImage = json['imgUrl'],
        data_synopsis = json['description'],
        data_dateAjout = DateTime.parse(json['add_date']),
        data_favori = json['favorite'],
        data_lu = json['read'],
        data_envie = json['wishlist'];

}