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
  String s_titre = "";
  String s_auteur = "";
  String s_datePublication = "";
  String s_editeur = "";
  String s_ISBN = "";
  String s_urlImage = "";
  String s_synopsis = "efzuzqqqqqqqqqqqqqqqqôi ôfuo fffffffffffffffffff  efzfreqgreqkgkslqnvz vlezhvozehvouzev ezfoihzeofhezb foezhfjzefkjze ezfkjzbefkjzFUE EZFKJEBFK EFJEBFKJEZB EFKEJBFKEJBFE EJFBFKEJBFêizjffffff oeajfpufpEAJFOIJJJJJJJJJJJJJJJJJJ 3PRFPEJFO%EIJF%O¨ZE%OFIJEZÖIJF";

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
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: !pageChargee ? null :  new FloatingActionButton.extended(
          label: new Text("Terminer"),
          splashColor: Colors.white,
          onPressed: terminer,
      ),
      appBar: new AppBar(
        title: new Text("Votre livre : "),
        centerTitle: true,
      ),
      body: !pageChargee? new Center(child: new SizedBox(width: 100.0, height: 100.0, child: new CircularProgressIndicator(strokeWidth: 10.0,),)) : new Container(
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
                            new TextePerso(this.s_titre, fontWeight: FontWeight.bold),
                            new Container(height: 10.0,),
                            new TextePerso("Auteur"),
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
                    new TextePerso(this.s_synopsis)
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
    Navigator.pop(context);
  }

  // méthode récupère les infos du livre via API
  void getInfo() async {
    //bool repOpenLibrary = false;
    bool repGoogle = false;
    //var onpenLibrary = await http.get("https://openlibrary.org/isbn/" + this.s_ISBN + '.json');
    var googleBooks = await http.get("https://www.googleapis.com/books/v1/volumes?q=isbn="+this.s_ISBN);

    // print("\n\n\n\n\n" + googleBooks.body);

    if(googleBooks.statusCode == 200){
      var reponse = convert.jsonDecode(googleBooks.body);
      setState(() {
        this.s_titre = (((reponse["items"])[0])["volumeInfo"])["title"];
        this.s_auteur = ((((reponse["items"])[0])["volumeInfo"])["authors"])[0];
        this.s_datePublication = (((reponse["items"])[0])["volumeInfo"])["publishedDate"];
        this.s_synopsis = (((reponse["items"])[0])["volumeInfo"])["description"];
        pageChargee = true;
      });
    }
    else {
      print('Request failed with status: ${googleBooks.statusCode}.');
    }



    /*
    // si la réponse est bonne
    if (onpenLibrary.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(onpenLibrary.body);
      setState(() {
        this.s_titre = jsonResponse['title'];
        this.s_datePublication = jsonResponse['publish_date'];
        this.s_editeur = (jsonResponse['publishers'])[0];
        this.s_urlImage = "http://covers.openlibrary.org/b/isbn/" + this.s_ISBN + "-M.jpg";
        pageChargee = true;
      });
    }
    else {
      print('Request failed with status: ${onpenLibrary.statusCode}.');
    }
     */
  }


}   // _LivreState