import 'dart:async';
import 'dart:convert';

import 'package:bar_code_scanner/ajouterLivreManuellement.dart';
import 'package:bar_code_scanner/stat.dart';
import 'package:bar_code_scanner/widgetsPerso/textePerso.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'livre.dart';
import 'ajouterLivreManuellement.dart';
import 'widgetsPerso/cardLivre.dart';
import 'mesObjets/dataLivre.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BarCodeScanner extends StatefulWidget {
  @override
  _BarCodeScannerState createState() => _BarCodeScannerState();
}


class _BarCodeScannerState extends State<BarCodeScanner> {
  String _scanBarcode = 'Unknown';

  // ne plus afficher l'aide au lancement de l'appli
  bool nePlusAfficher = false;

  // indice du volet selectioné parmis les 3 (bibliothèque, favoris ou envies
  int selectedIndex = 0;

  // nombre de favoris --> utile pour build la liste dans l'onglet fav
  int nbrFavoris;

  //Unique Key for Shared Preferences usage
  final String uniqueKey = 'myBooks';
  final String uniqueKeyWishlist = 'myWishlist';

  // liste des livres
  List<DataLivre> listDataLivre =[];  // objet Livre qui stockent les données
  List<DataLivre> listDataEnvie =[];  // objet Livre (envie) qui stockent les données
  List<Widget> listCardLivre = [];    // widgets contenus dans le liste view de l'onglet BU et fav
  List<Widget> listCardEnvie = [];    // widgets contenus dans le liste view de l'onglet envie


  // liste des string pour la AppBar selon l'onglet selectionné
  List<String> listString = ["Ma Bibliothèque", "Mes Envies"];
  // liste des couleurs pour les différents volets
  List<Color> listColor = [Colors.green, Colors.amber];


  // fonction lancée au lancement de la vue principale
  @override
  void initState(){
    super.initState();

      readBooks();
      print('longueur de la list de livre');
      print(listDataLivre.length);

    WidgetsBinding.instance.addPostFrameCallback((_){
      // affiche l'aide pour la vue principale
      if (listDataLivre.length + listDataEnvie.length > 0) {
        getHelp2();
      }

    });
  }

  // fonction pour le scanner de code bar
  startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
        "#ff6666", "Cancel", true, ScanMode.BARCODE)
        .listen((barcode) => print("\nISBN du livre: "+barcode+"\n"));
  }


  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // on se déplace dans le widget "livre"
    _scanBarcode = barcodeScanRes;
    final result = await Navigator.push(
        context,
        // on affiche la page du livre
        // info = false --> on affiche le livre pour potentiellement l'ajouter à sa biblihothèque
        // info = true --> on affiche juste les détails du livre
        MaterialPageRoute(builder: (context) => Livre(_scanBarcode, false, null))
    );

    print("\n\n\n\n\n\n\n\n\n"+"$result");

    setState(() {
      // Si l'utilisateur appuie sur terminer sur la vue Livre alors on a un resultat
      // on instancie un objet avec les infos
      DataLivre monLivre = new DataLivre(result["Titre"], result["Auteur"], result["DatePublication"], result["Editeur"], result["ISBN"], result["UrlImage"], result["Synopsis"], result["Lu"], result["Envie"], DateTime.now());
      // et selon le choix de l'utilisateur on instancie un widget correspondant dans les envies ou dans la bibliothèque
      // on check avant qu'il n'y est pas de doublon
      if(!estUnDoublou(monLivre)){
        // on check qu'il fasse pas partis de l'autre liste
        if(!faitPartisDeLautreListe(monLivre)){
          if(result["Envie"]){
            listCardEnvie.add(new CardLivre(monLivre));
            listDataEnvie.add(monLivre);
            saveBooks();
          }
          else {
            listCardLivre.add(new CardLivre(monLivre));
            listDataLivre.add(monLivre);
            saveBooks();
          }
        }
      }
    });

  }

// affiche l'aide
  Future<Null> getHelp2() async{
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new SimpleDialog(
            title: new Text("Aide"),
            children: [
              new Container(
                padding: EdgeInsets.all(12.0),
                child: new Column(
                  children: [
                    new TextePerso("Vous pouvez naviguer entre les 3 volets pour voir les livres que vous avez ajoutés.", textAlign: TextAlign.justify,),
                    new Divider(height: 10),
                    new Container(height: 20.0,),
                    new TextePerso("Pour scanner des livres, appuyez sur le bouton + ou restez appuyé dessus pour ajouter un livre manuellement.", textAlign: TextAlign.justify,),
                    new Divider(height: 10),
                    new Row(children: [ new Container(width: 10.0,),new Icon(Icons.add, color: Colors.green,), new TextePerso("    Ajouter un livre")],),
                    new Container(height: 20.0,),
                    new TextePerso("Une fois que vous aurez ajouté des livres, maintenez votre doigt appuyé sur celui qui vous interesse pour plus d'option.", textAlign: TextAlign.justify,),
                    new Divider(height: 10),
                    new Row(children: [ new Container(width: 10.0,),new Icon(Icons.info_outline, color: Colors.green,), new TextePerso("    Détails du livre")],),
                    new Row(children: [ new Container(width: 10.0,),new Icon(Icons.delete_outline, color: Colors.redAccent,), new TextePerso("    Supprimer le livre")],),
                    new Container(height: 20.0,),
                    new TextePerso("Vous pouvez ajouter des livres à vos favoris en cliquant sur le coeur à coté d'eux.", textAlign: TextAlign.justify,),
                    new Divider(height: 10),
                    new Row(children: [ new Container(width: 10.0,),new Icon(Icons.favorite, color: Colors.redAccent,), new TextePerso("    Ajouter aux favoris")],),
                  ],
                ),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  new Container(),
                  new FlatButton(onPressed: (){Navigator.pop(context);},child: new TextePerso("Go", textScaleFactor: 1.1, fontWeight: FontWeight.bold,)),
                ],
              )
            ],
          );
        }
    );
  }

  // fonction de trie pour l'onglet bibliothèque
  void trier(int option){
    // le tableau a trier selon le volet selectionné
    List<Widget> card;
    List<DataLivre> livre;
    if(selectedIndex == 0){
      card = this.listCardLivre;
      livre = this.listDataLivre;
    }
    else {
      card = this.listCardEnvie;
      livre = this.listDataEnvie;
    }
    // lancement du tri
    setState(() {
      // ajouter recement
      if(option == 0) {
        card.sort( ( a, b ) {
          return -(a as CardLivre).cl_livre.data_dateAjout.compareTo((b as CardLivre).cl_livre.data_dateAjout);
        });
        livre.sort( ( a, b ) {
          return -(a.data_dateAjout.compareTo(b.data_dateAjout));
        });
        print("Trier: Ajouter recement");
        // par titre
      } else if(option == 1){
          card.sort( ( a, b ) {
          return (a as CardLivre).cl_livre.data_titre.toString().toLowerCase().compareTo((b as CardLivre).cl_livre.data_titre.toString().toLowerCase());
        });
        livre.sort( ( a, b ) {
          return a.data_titre.toString().toLowerCase().compareTo(b.data_titre.toString().toLowerCase());
        });
        print("Trier: Par titre");
        // auteur par ordre alphabéthique
      } else if(option == 2){
        card.sort( ( a, b) {
          return (a as CardLivre).cl_livre.data_auteur.toString().toLowerCase().compareTo((b as CardLivre).cl_livre.data_auteur.toString().toLowerCase());
        });
        livre.sort( ( a, b) {
          return a.data_auteur.toString().toLowerCase().compareTo(b.data_auteur.toString().toLowerCase());
        });
        print("Trier: Par auteur");
        // livres lus
      } else if(option == 3){
        card.sort( ( a, b ) {
          if(!(a as CardLivre).cl_livre.data_lu && (b as CardLivre).cl_livre.data_lu){
            return 1;
          }
          if((a as CardLivre).cl_livre.data_lu && !(b as CardLivre).cl_livre.data_lu){
            return -1;
          }
          return 0;
        });
        livre.sort( ( a, b ) {
          if(!a.data_lu && b.data_lu){
            return 1;
          }
          if(a.data_lu && !b.data_lu){
            return -1;
          }
          return 0;
        });
        print("Trier: Si lu ou pas");
        // inverse
      } else if(option == 4){
        card.sort( ( a, b ) {
          return 1;
        });
        livre.sort( ( a, b ) {
          return 1;
        });
        print("Trier: Ordre inverse");
        // met les favoris au dessus
      } else if(option == 5){
        card.sort( ( a, b ) {
          if(!(a as CardLivre).cl_livre.data_favori && (b as CardLivre).cl_livre.data_favori){
            return 1;
          }
          if((a as CardLivre).cl_livre.data_favori && !(b as CardLivre).cl_livre.data_favori){
            return -1;
          }
          return 0;
        });
        livre.sort( ( a, b ) {
          if(!a.data_favori && b.data_favori){
            return 1;
          }
          if(a.data_favori && !b.data_favori){
            return -1;
          }
          return 0;
        });
        print("Trier: Favoris au dessus");
      }
    });   // fin du setstate
    print("\n\n\n liste triée");
  }


  // fonction pour lancer la vue des stats de l'utilisateur
  void voirStat(){
    Navigator.push(context, new MaterialPageRoute(builder:  (BuildContext context) {
      return new Stat(listDataLivre, listDataEnvie);
    }));
  }

  Future<void> saveBooks() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(uniqueKey        , json.encode(listDataLivre));
    sp.setString(uniqueKeyWishlist, json.encode(listDataEnvie));
  }

  Future<void> readBooks() async {

      SharedPreferences sp = await SharedPreferences.getInstance();
      json.decode(sp.getString(uniqueKey)).forEach((map) => listDataLivre.add(new DataLivre.fromJson(map)));
      json.decode(sp.getString(uniqueKeyWishlist)).forEach((map) => listDataEnvie.add(new DataLivre.fromJson(map)));

      setState(() {
        for(int i = 0; i < this.listDataLivre.length; i++) {
          listCardLivre.add(new CardLivre(listDataLivre[i]));
        }
        for(int i = 0; i < this.listDataEnvie.length; i++) {
          listCardEnvie.add(new CardLivre(listDataEnvie[i]));
        }
      });

  }

  // check si un livre est en doublon ou non avant de l'ajouter
  bool estUnDoublou(DataLivre livre){
    bool envie = livre.data_envie;
    // on part du principe que ya pas de doublon
    bool doublon  = false;
    // on regarde dans quelle liste on va checker (envie ou livre)
    List<DataLivre> aChecker;
    if(envie){
      aChecker = listDataEnvie;
    }
    else {
      aChecker = listDataLivre;
    }
    // si isbn = -1 <=> le livre à été ajouté à la main
    if(livre.data_ISBN == "-1"){
      for(DataLivre dataLivre in aChecker){
        // meme titre, meme auteur, meme editeur
        if(dataLivre.data_titre == livre.data_titre && dataLivre.data_auteur == livre.data_auteur && dataLivre.data_editeur == livre.data_editeur){
          doublon = true;
        }
      }
    }
    // sinon <=> livre scanné
    else {
      for(DataLivre dataLivre in aChecker){
        // meme isbn
        if(dataLivre.data_ISBN == livre.data_ISBN){
          doublon = true;
        }
      }
    }
    // on affiche un message d'erreur si doublon
    if(doublon) {
      String message;
      // si on voulait l'ajouter aux envies
      if(envie){
        message = "Nous somme désolés mais il semblerait que ce livre fasse déjà partis de votre liste d'envie.";
      }
      // sinon si on souhaitait l'ajouter à la bibliothèque
      else {
        message = "Nous somme désolés mais il semblerait que ce livre fasse déjà partis de votre bibliothèque.";
      }
      messageAlert(message);
    }
    // retour
    return doublon;
    }

    // chack si un livre qu'on veut ajouter au envie fait pas déjà partis de la bibliothèque ou des envies
    bool faitPartisDeLautreListe(DataLivre livre){
      // on part du principe que non
      bool faitPartisDeLautreListe = false;
      List<DataLivre> lautreListe;
      // si on veut ajouter le livre aux envie <=> lautre liste c'est la bibliothèque
      if(livre.data_envie){
        lautreListe = listDataLivre;
      }
      // inversement si on souhaite ajouter un livre à la bibliothèque alors l'autre c'est les envies
      else {
        lautreListe = listDataEnvie;
      }
      // pour un livre ajouter à la main
      if(livre.data_ISBN == "-1"){
        for(DataLivre dataLivre in lautreListe){
          // meme titre, meme auteur, meme editeur
          if(dataLivre.data_titre == livre.data_titre && dataLivre.data_auteur == livre.data_auteur && dataLivre.data_editeur == livre.data_editeur){
            faitPartisDeLautreListe = true;
          }
        }
      }
      // pour les livres scannés
      else {
        for(DataLivre dataLivre in lautreListe){
          // meme isbn
          if(dataLivre.data_ISBN == livre.data_ISBN){
            faitPartisDeLautreListe = true;
          }
        }
      }
      // si le livre qu'on souhaite ajouter fait partis de l'autre liste
      if(faitPartisDeLautreListe){
        String message;
        // si on souhaitait l'ajouter aux envies
        if(livre.data_envie){
          message = "Nous somme désolés mais il semblerait que ce livre fasse déjà partis de votre bibliothèque.";
        }
        // sinon si on souhaitait l'ajouter à la bibliothèque
        else {
          message = "Nous somme désolés mais il semblerait que ce livre fasse déjà partis de vos envies. Pour le basculer de vos envies vers votre bibliothèque, rendez vous simplement dans l'onglet des envies, maintenez votre doigts sur le livre en question et cliquez sur Basculer";
        }
        messageAlert(message);
      }
      return faitPartisDeLautreListe;
    }



  // affiche l'aide
  Future<Null> messageAlert(String message) async{
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new SimpleDialog(
            title: new TextePerso("Erreur", textScaleFactor: 1.5, fontWeight: FontWeight.bold,),
            children: [
              new Container(
                padding: EdgeInsets.all(12.0),
                child: new TextePerso(message, textAlign: TextAlign.justify,),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  new Container(),
                  new FlatButton(onPressed: (){Navigator.pop(context);},child: new TextePerso("Retour", textScaleFactor: 1.1)),
                ],
              )
            ],
          );
        }
    );
  }




  @override
  Widget build(BuildContext context) {


    print("Début build barcodeScanner");


    // listes des widgets de la bottomBar
    List<Widget> widgetList = <Widget>[
      // les livres
      new Container(
        key: Key(UniqueKey().toString()),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: listCardLivre.length == 0 ? new Center(child: new TextePerso("Aucun livre dans votre biblihothèque pour le moment", textScaleFactor: 1.6, textAlign: TextAlign.center,),): new Center(
          child: ListView.builder(
            itemCount: listCardLivre.length,
            itemBuilder: (context, index){
              return new Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: new FocusedMenuHolder(
                  menuItemExtent: 60.0,
                  onPressed: (){},
                  menuItems: <FocusedMenuItem> [
                    new FocusedMenuItem(
                        title: new Text("Voir les détails"),
                        onPressed: (){
                          Navigator.push(context, new MaterialPageRoute(builder:  (BuildContext context) {
                            Livre retour;
                            // isbn = -1 <=> livre ajouter à la main
                            if (listDataLivre[index].data_ISBN == "-1") {
                              retour = new Livre.livreAjouterManuellement(listDataLivre[index]);
                            }
                            // sinon on relance les détails
                            else {
                              retour = new Livre(listDataLivre[index].data_ISBN, true, listDataLivre[index].data_dateAjout);
                            }
                            return retour;
                          }));
                        },
                        trailingIcon: new Icon(Icons.info_outline, color: Colors.green,)
                    ),
                    new FocusedMenuItem(
                      title: listDataLivre[index].data_lu ? new Text("Supprimer des lus") : new Text("Ajouter aux lus"),
                      onPressed: (){
                        setState(() {
                          listDataLivre[index].data_lu = !listDataLivre[index].data_lu;
                        });
                        saveBooks();
                        Scaffold.of(context).showSnackBar(new SnackBar(
                          content: listDataLivre[index].data_lu ? new Text("Marqué comme lu") : new Text("Marqué comme non lu") ,
                          backgroundColor: Colors.green,
                          // behavior: SnackBarBehavior.floating,
                          elevation: 10.0,
                        ));
                      },
                      trailingIcon: new Icon((this.listCardLivre[index] as CardLivre).cl_livre.data_lu ? Icons.book_rounded : Icons.book_outlined, color: Colors.green,),
                    ),
                    new FocusedMenuItem(
                      title: new Text("Supprimer"),
                      onPressed: (){
                        setState(() {
                          // on supprime le Card livre
                          listCardLivre.removeAt(index);
                          listDataLivre.removeAt(index);
                          saveBooks();
                        });
                      },
                      trailingIcon: new Icon(Icons.delete_outline, color: Colors.red,),
                    ),
                  ],
                  child: listCardLivre[index],
                )
              );
            },
          )
        ),
      ),
      // les envies
      new Container(
        key: Key(UniqueKey().toString()),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: listCardEnvie.length == 0 ? new Center(child: new TextePerso("Aucun livre dans vos envies pour le moment", textScaleFactor: 1.6, textAlign: TextAlign.center,),): new Center(
            child: ListView.builder(
              itemCount: listCardEnvie.length,
              itemBuilder: (context, index){
                return new Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: new FocusedMenuHolder(
                      menuItemExtent: 60.0,
                      onPressed: (){},
                      menuItems: <FocusedMenuItem> [
                        new FocusedMenuItem(
                            title: new Text("Voir les détails"),
                            onPressed: (){
                              Navigator.push(context, new MaterialPageRoute(builder:  (BuildContext context) {
                                Livre retour;
                                // isbn = -1 <=> livre ajouter à la main
                                if ((listCardEnvie[index] as CardLivre).cl_livre.data_ISBN == "-1") {
                                  retour = new Livre.livreAjouterManuellement(listDataEnvie[index]);
                                }
                                // sinon on relance les détails
                                else {
                                  retour = new Livre((listCardEnvie[index] as CardLivre).cl_livre.data_ISBN, true, (listCardEnvie[index] as CardLivre).cl_livre.data_dateAjout);
                                }
                                return retour;
                              }));
                            },
                            trailingIcon: new Icon(Icons.info_outline, color: Colors.amber,)
                        ),
                        new FocusedMenuItem(
                            title: new Text("Basculer vers la bibliothèque"),
                            onPressed: (){
                              setState(() {
                                listDataLivre.add(listDataEnvie.elementAt(index));
                                listCardLivre.add(listCardEnvie.elementAt(index));
                                listCardEnvie.removeAt(index);
                                listDataEnvie.removeAt(index);
                                saveBooks();
                              });
                            },
                            trailingIcon: new Icon(Icons.subdirectory_arrow_left, color: Colors.amber,)
                        ),
                        new FocusedMenuItem(
                          title: new Text("Supprimer"),
                          onPressed: (){
                            setState(() {
                              listCardEnvie.removeAt(index);
                              listDataEnvie.removeAt(index);
                              saveBooks();
                            });
                          },
                          trailingIcon: new Icon(Icons.delete_outline, color: Colors.red,),
                        ),
                      ],
                      child: listCardEnvie[index],
                    )
                );
              },
            )
        ),
      ),
    ];


    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
            primarySwatch: this.listColor[selectedIndex],
            floatingActionButtonTheme: new FloatingActionButtonThemeData(
              foregroundColor:  this.listColor[selectedIndex],
            )
        ),
      home: new Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (int index) {
                setState(() {
                  // si on veut les favoris
                  if(index == 0){
                    trier(0);
                  }
                  selectedIndex = index;
                });
              },
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Bibliothèque',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star),
                  label: 'Envies',
                ),
              ],
            ),
            appBar: AppBar(
              title: new Text(this.listString[this.selectedIndex], style: new TextStyle(color: Colors.white),),
              elevation: 10,
              actions: [
                new IconButton(icon: new Icon(Icons.assessment_outlined), onPressed: voirStat, color: Colors.white),
                new IconButton(icon: new Icon(Icons.help), onPressed: getHelp2, color: Colors.white),
                // popup menu pour trier
                new PopupMenuButton <int> (
                  onSelected: (int selected){ trier(selected);},
                  icon: new Icon(Icons.sort, color: Colors.white,), // Icons.toc
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<int>> [
                    PopupMenuItem(child: new Text("Trier les livre par:       ")),
                    PopupMenuItem( value: 0, child: new Row(mainAxisAlignment: MainAxisAlignment.start ,children: [new Icon(Icons.timer_outlined, color: this.listColor[selectedIndex],),  new Container(width: 15), new Text("Dernier ajout")],)),
                    PopupMenuItem(value: 1, child: new Row(mainAxisAlignment: MainAxisAlignment.start ,children: [new Icon(Icons.edit, color: this.listColor[selectedIndex],), new Container(width: 15), new Text("Par titre")],)),
                    PopupMenuItem(value: 2, child: new Row(mainAxisAlignment: MainAxisAlignment.start ,children: [new Icon(Icons.people, color: this.listColor[selectedIndex],), new Container(width: 15), new Text("Par auteur")],)),
                    PopupMenuItem(value: 3, child: new Row(mainAxisAlignment: MainAxisAlignment.start ,children: [new Icon(Icons.book, color: this.listColor[selectedIndex],), new Container(width: 15), new Text("Les livres lus")],)),
                    PopupMenuItem(value: 5, child: new Row(mainAxisAlignment: MainAxisAlignment.start ,children: [new Icon(Icons.favorite, color: this.listColor[selectedIndex],), new Container(width: 15), new Text("Les favoris")],)),
                    PopupMenuItem(value: 4, child: new Row(mainAxisAlignment: MainAxisAlignment.start ,children: [new Icon(Icons.autorenew_rounded, color: this.listColor[selectedIndex],), new Container(width: 15), new Text("Inverser")],)),
                  ],
                )
              ],
            ),
            floatingActionButton: FloatingActionButton(
              elevation: 20.0,
              child: new FocusedMenuHolder(
                  child: new Icon(Icons.add, color: Colors.white,),
                  onPressed: () => scanBarcodeNormal(),
                  menuItemExtent: 60.0,
                  menuItems: <FocusedMenuItem> [
                    new FocusedMenuItem(
                        title: new TextePerso("Scanner Livre", textScaleFactor: 1.2,),
                        trailingIcon: new Icon(Icons.qr_code_scanner, color: this.listColor[selectedIndex],),
                        onPressed: () => scanBarcodeNormal(),
                    ),
                    new FocusedMenuItem(
                      title: new TextePerso("Ajouter à la main", textScaleFactor: 1.2,),
                      trailingIcon: new Icon(Icons.assignment_rounded, color: this.listColor[selectedIndex],),
                      onPressed: () async {
                        final result = await Navigator.push(
                            context,
                            // on affiche la page pour ajouter manuellement un livre
                            MaterialPageRoute(builder: (context) => AjouterLivreManuellement())
                        );
                        print("result de livre manuellement ${result["Titre"]}");
                        // on instancie un objet avec les infos
                        DataLivre monLivre = new DataLivre(result["Titre"], result["Auteur"], result["DatePublication"], result["Editeur"], result["ISBN"], result["UrlImage"], result["Synopsis"], result["Lu"], result["Envie"], DateTime.now());
                        setState(() {
                          // on l'ajoute aux données
                          // et selon le choix de l'utilisateur on instancie un widget correspondant dans les envies ou dans la bibliothèque
                          if(!estUnDoublou(monLivre)){
                            // on check qu'il fasse pas partis de l'autre liste
                            if(!faitPartisDeLautreListe(monLivre)){
                              if(result["Envie"]){
                                listCardEnvie.add(new CardLivre(monLivre));
                                listDataEnvie.add(monLivre);
                                saveBooks();
                              }
                              else {
                                listCardLivre.add(new CardLivre(monLivre));
                                listDataLivre.add(monLivre);
                                saveBooks();
                              }
                            }
                          }
                        });
                      },
                    ),
                  ]
              ),
            ),
            body: new Builder(builder: (BuildContext context) {
              return widgetList.elementAt(selectedIndex);
            })
        )
    );
  }


}