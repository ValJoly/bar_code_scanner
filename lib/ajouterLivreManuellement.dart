import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'widgetsPerso/textePerso.dart';


// classe qui correspond à la vue qui permet d'ajouter un livre en entrant manuellement les données d'un livre
class AjouterLivreManuellement extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new _AjouterLivreManuellement();
  }
}



// state coorespondant
class _AjouterLivreManuellement extends State<AjouterLivreManuellement> {

  // attributs pour le futur livre
  String titre = "Inconnu";
  String auteur = "Inconnu";
  String datePublication = "Iconnue";
  String editeur = "Inconnu";
  String isbn = "Inconnu";
  // dans quelle catégorie on va ajouter le livre
  // bibliothèque = false
  // envie = true
  bool ajouterA = false;
  // savoir si on veut marquer le livre comme lu ou non
  bool lu = false;
  String synopsis = "vide";

  // méthode quand on appuie sur le bouton terminer --> ajouter le livre
  void terminer(){
    var retour = {'Titre': titre,'Auteur': auteur, 'DatePublication': datePublication, 'Editeur': this.editeur, 'ISBN': isbn, "UrlImage": "vide", "Synopsis": synopsis, "Lu": lu, "Envie": ajouterA };
    Navigator.pop(context, retour);
  }


  @override
  Widget build(BuildContext context) {
    double largeur = MediaQuery.of(context).size.width;
    double hauteur = MediaQuery.of(context).size.height;
    print("\nDébut du build ajouter livre manuellement\n");
    return new Scaffold(

      // bouton pour valider et ajouter le livre
      resizeToAvoidBottomPadding: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: new FloatingActionButton.extended(
          label: new Text("Ajouter"),
          backgroundColor: ajouterA ? Colors.amber : Colors.green,
          splashColor: Colors.white,
          onPressed: terminer,
      ),

      // appbar de notre vue
      appBar: new AppBar(
        title: ajouterA ? new Text("Votre envie : ") : new Text("Votre livre : "),
        backgroundColor: ajouterA ? Colors.amber : Colors.green,
        centerTitle: true,
      ),

      // corps de notre vue
      body: new SingleChildScrollView(
        padding: EdgeInsets.all(largeur*0.05),
        child: new Column(
          children: [

            // row du titre
            new Row(
              children: [
                new TextePerso("Titre : ", textScaleFactor: 1.3, fontWeight: FontWeight.bold,),
                new Container(width: 10,),
                Expanded(child: new TextField(onChanged: (texte){titre = texte; print(titre);}, decoration: InputDecoration(border: OutlineInputBorder(), labelText: "entrer titre", isDense: true),)),
              ],
            ),

            new Container(height: 5),

            // row du l'auteur
            new Row(
              children: [
                new TextePerso("Auteur : ", textScaleFactor: 1.3, fontWeight: FontWeight.bold,),
                new Container(width: 10,),
                Expanded(child: new TextField(onChanged: (texte){auteur = texte;}, decoration: InputDecoration(border: OutlineInputBorder(), labelText: "entrer le nom de l'auteur", isDense: true,),)),
              ],
            ),

            new Container(height: 5),

            // row de la date de publication
            new Row(
              children: [
                new TextePerso("Année de publication : ", textScaleFactor: 1.3, fontWeight: FontWeight.bold,),
                new Container(width: 10,),
                Expanded(child: new TextField(onChanged: (texte){datePublication = texte;}, keyboardType: TextInputType.number, inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),], decoration: InputDecoration(border: OutlineInputBorder(), labelText: "entrer date", isDense: true),)),
              ],
            ),

            new Container(height: 5),

            // row de l'éditeur
            new Row(
              children: [
                new TextePerso("Editeur : ", textScaleFactor: 1.3, fontWeight: FontWeight.bold,),
                new Container(width: 10,),
                Expanded(child: new TextField(onChanged: (texte){editeur = texte;}, decoration: InputDecoration(border: OutlineInputBorder(), labelText: "entrer l'éditeur", isDense: true),)),
              ],
            ),

            new Container(height: 5),

            // row ISBN
            new Row(
              children: [
                new TextePerso("ISBN : ", textScaleFactor: 1.3, fontWeight: FontWeight.bold,),
                new Container(width: 10,),
                Expanded(child: new TextField(onChanged: (texte){isbn = texte;}, keyboardType: TextInputType.number, inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),], decoration: InputDecoration(border: OutlineInputBorder(), labelText: "entrer ISBN", isDense: true),)),
              ],
            ),

            new Container(height: 5),

            // row pour ajouter ou non comme lu
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget> [
                new TextePerso("Marquer comme Lu", textScaleFactor: 1.3, fontWeight: FontWeight.bold,),
                new Checkbox(value: lu, onChanged: (bool b){
                  setState(() {
                    if(!ajouterA) { // une envie de ne peut pas être déjà lue
                      lu = b;
                    }
                  });
                })
              ],
            ),

            new Container(height: 5),

            // deux rows pour savoir si on ajoute à la bibiothèque ou au envie
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget> [
                new TextePerso("Ajouter :", textScaleFactor: 1.3, fontWeight: FontWeight.bold,),
                new Container()
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                new TextePerso("A La Bibliothèque", textScaleFactor: 1.1,),
                new Switch(value: ajouterA, onChanged: (bool b){ setState(() { ajouterA = b; if(b) { lu  = false; } });}, // un livre des envies n'est a priori pas encore lu ?
                  activeColor: Colors.amber,
                  inactiveThumbColor: Colors.lightGreen,
                  inactiveTrackColor: Colors.lightGreen[300],
                ),
                new TextePerso("Aux Envies", textScaleFactor: 1.1, )
              ],
            ),

            new Container(height: 5),

            // row du synopsis
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new TextePerso("Synopsis : ", textScaleFactor: 1.3, fontWeight: FontWeight.bold,),
                new Container(height: 3),
                new TextField(
                    onChanged: (texte){synopsis = texte;},
                    maxLines: 7,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "synopsis du livre"
                    )
                )
              ],
            )

          ],
        ),
      ),

    );
  } //  build du state


} // classe du state