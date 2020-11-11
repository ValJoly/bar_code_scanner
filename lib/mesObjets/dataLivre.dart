import 'package:flutter/cupertino.dart';

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

  // constructeur
  DataLivre(String titre, String auteur, String datePublication, String editeur, String isbn, String urlImage, String synopsis, bool lu, bool envie){
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
  }

  // méthode pour trier
  int comparerA(DataLivre other){
    // si les deux sont fav ou les deux non
    if((this.data_favori && other.data_favori) || (!this.data_favori && !other.data_favori)){
      return 0;
    }
    // si le b est fav et pas le 1
    if(!this.data_favori && other.data_favori){
      return 1;
    }
    // si le 1 est fav mais pas le b
    if(this.data_favori && !other.data_favori){
      return -1;
    }
    return null;
  }



}