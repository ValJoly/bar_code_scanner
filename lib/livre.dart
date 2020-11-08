import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'widgetsPerso/textePerso.dart';


class Livre extends StatefulWidget{

  // attributs
  String m_isbn = "Inconnu";

  // constructeur
  Livre(String isbn){
    this.m_isbn = isbn;
  }

  // creatState
  @override
  _LivreState createState() => new _LivreState(this.m_isbn);
}



class _LivreState extends State<Livre>{

  bool pageChargee = false;
  bool lu = false;
  bool ajouterEnvie = false;

  // attributs du state
  String s_titre = "Inconnu";
  String s_auteur = "Inconnu";
  String s_datePublication = "Inconnue";
  String s_editeur = "Inconnu";
  String s_ISBN = "Inconnu";
  String s_urlImage = "Inconnue";
  String s_synopsis = "Pas disponible";

  // constructeurs du state
  _LivreState(String isbn){
    this.s_ISBN = isbn;
  }

  // au lancement
  @override
  void initState() {
    super.initState();
    getInfo();
  }

  @override
  Widget build(BuildContext context) {
    double largeur = MediaQuery.of(context).size.width;
    double hauteur = MediaQuery.of(context).size.height;
    print("Début du build de livre");
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: !pageChargee ? null :  new FloatingActionButton.extended(
          label: new Text("Ajouter"),
          splashColor: Colors.white,
          onPressed: terminer,
      ),
      appBar: new AppBar(
        title: new Text("Votre livre : "),
        centerTitle: true,
      ),
      body: !pageChargee? new Center(child: new SizedBox(width: 100.0, height: 100.0, child: new CircularProgressIndicator(strokeWidth: 10.0,),)) : new SingleChildScrollView(
        padding: EdgeInsets.all(largeur*0.05),
        child: new Column(
          children: [
            new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget> [
                new Card(
                  elevation: 10.0,
                  child: new Image.network(
                    this.s_urlImage,
                    scale: 1.3,
                    //height: MediaQuery.of(context).size.height * 0.25,
                  ),
                ),
                new Expanded(
                  child: new Card(
                    child: new Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        margin: EdgeInsets.only(left: 8.0, top: 8.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget> [
                            // les deux "" devant titre et auteur servent juste à éviter un bug
                            // si le titre ou l'auteur ne sont pas trouvé (très rare je suis daccord...)
                            // alors l'appli crash psq le widget Text a besoin de data pour s'instancier
                            new TextePerso(""+this.s_titre, fontWeight: FontWeight.bold),
                            new Container(height: 10.0,),
                            new TextePerso(""+this.s_auteur),
                            new Container(height: 7.0,),
                            new TextePerso("Date de publication: "+this.s_datePublication),
                            new Container(height: 7.0,),
                            new TextePerso("Editeur: "+this.s_editeur),
                            new Container(height: 7.0,),
                            new TextePerso("ISBN: "+this.s_ISBN),
                          ],
                        )
                    ),
                  ),
                )
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget> [
                new TextePerso("Marquer comme Lu", textScaleFactor: 1.3,),
                new Checkbox(value: lu, onChanged: (bool b){
                  setState(() {
                    lu = !lu;
                  });
                })
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget> [
                new TextePerso("Ajouter à la liste des envies", textScaleFactor: 1.3,),
                new Checkbox(value: ajouterEnvie, onChanged: (bool b){
                  setState(() {
                    ajouterEnvie = b;
                  });
                })
              ],
            ),
            new Container(height: 10.0,),
            new Card(
              elevation: 15.0,
              child: new Container(
                padding: EdgeInsets.all(10.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    new TextePerso("Synopsis: ", fontWeight: FontWeight.bold, textScaleFactor: 1.2),
                    new Container(height: 5.0,),
                    new TextePerso(""+this.s_synopsis)
                  ],
                ),
              ),
            )
          ],
        )
      )
    );
  }

  // méthode quand on appuie sur le bouton terminer
  void terminer(){
    var retour = {'Titre': this.s_titre,'Info': this.s_auteur+", paru en "+this.s_datePublication+", "+this.s_editeur};
    Navigator.pop(context, retour);
  }

  // alertDialog si jamais le livre n'est pas trouvé
  Future<Null> pasTrouve() async{
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text("Erreur"),
            content: new Text("Nous sommes désolés, nous ne trouvons pas le livre que vous cherchez."),
            actions: <Widget> [
              new FlatButton(
                  onPressed: (){
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: new Text("Revenir au menu principal")
              ),
            ],
          );
        }
    );
  }

  // méthode récupère les infos du livre via API
  void getInfo() async {
    bool repOpenLibrary = false;
    bool repGoogle = false;

    // API GoggleBooks
    var googleBooks = await http.get("https://www.googleapis.com/books/v1/volumes?q=isbn="+this.s_ISBN);

    // replissage des données si possible
    if(googleBooks.statusCode == 200){
      repGoogle = true;
      var reponse = convert.jsonDecode(googleBooks.body);
      setState(() {
        this.s_titre = (((reponse["items"])[0])["volumeInfo"])["title"].toString() == "null" ? this.s_titre : (((reponse["items"])[0])["volumeInfo"])["title"].toString();
        this.s_auteur = ((((reponse["items"])[0])["volumeInfo"])["authors"])[0].toString() == "null" ? this.s_auteur : ((((reponse["items"])[0])["volumeInfo"])["authors"])[0].toString();
        this.s_datePublication = (((reponse["items"])[0])["volumeInfo"])["publishedDate"].toString().substring(0, 10) == "null" ? this.s_datePublication : (((reponse["items"])[0])["volumeInfo"])["publishedDate"].toString().substring(0, 10);
        this.s_editeur = (((reponse["items"])[0])["volumeInfo"])["publisher"].toString() == "null" ? this.s_editeur : (((reponse["items"])[0])["volumeInfo"])["publisher"].toString();
        this.s_synopsis = (((reponse["items"])[0])["volumeInfo"])["description"].toString() == "null" ? this.s_synopsis : (((reponse["items"])[0])["volumeInfo"])["description"].toString();
      });
    }
    else {
      print('Request failed with status: ${googleBooks.statusCode}.');
    }

    // API OnperLibrary
    var onpenLibrary = await http.get("https://openlibrary.org/isbn/" + this.s_ISBN + '.json');

    // Si complète les données avec une deuxième API au cas ou il en manquerait
    if (onpenLibrary.statusCode == 200) {
      repOpenLibrary = true;
      var jsonResponse = convert.jsonDecode(onpenLibrary.body);
      setState(() {
        this.s_titre = this.s_titre == "Inconnu" ? jsonResponse['title'] : this.s_titre;
        this.s_datePublication = this.s_datePublication == "Inconnue" ?jsonResponse['publish_date'] : this.s_datePublication;
        this.s_editeur = this.s_editeur == "Inconnu" ? (jsonResponse['publishers'])[0] : this.s_editeur;
      });
    }
    else {
      print('Request failed with status: ${onpenLibrary.statusCode}.');
    }

    // si on a au moins une des réponse
    if(repGoogle || repOpenLibrary){
      setState(() {
        this.s_urlImage = "http://covers.openlibrary.org/b/isbn/" + this.s_ISBN + "-M.jpg";
        pageChargee = true;
      });
    }
    // si on a aucune réponse on quitte
    else {
      pasTrouve();
    }

    print("Get info terminé");

  }


}   // _LivreState