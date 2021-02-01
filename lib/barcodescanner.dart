import 'dart:async';

import 'package:bar_code_scanner/stat.dart';
import 'package:bar_code_scanner/widgetsPerso/textePerso.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'livre.dart';
import 'widgetsPerso/cardLivre.dart';
import 'mesObjets/dataLivre.dart';


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

  // liste des livres
  List<DataLivre> listDataLivre =[];  // objet Livre qui stockent les données
  List<Widget> listCardLivre = [];    // widgets contenus dans le liste view de l'onglet BU et fav
  List<Widget> listCardEnvie = [];    // widgets contenus dans le liste view de l'onglet envie


  // liste des string pour la AppBar selon l'onglet selectionné
  List<String> listString = ["Ma Biblihothèque", "Mes Favoris", "Mes Envies"];
  // liste des couleurs pour les différents volets
  List<Color> listColor = [Colors.green, Colors.green, Colors.amber];


  // fonction lancée au lancement de la vue principale
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      // affiche l'aide pour la vue principale
      getHelp2();
    });
  }

  // fonction pour le scanner de code bar
  startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
        "#ff6666", "Cancel", true, ScanMode.BARCODE)
        .listen((barcode) => print(barcode));
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
        MaterialPageRoute(builder: (context) => Livre(_scanBarcode, false))
    );

    print("\n\n\n\n\n\n\n\n\n"+"$result");

    setState(() {
      // Si l'utilisateur appuie sur terminer sur la vue Livre alors on a un resultat
      // on instancie un objet avec les infos
      DataLivre monLivre = new DataLivre(result["Titre"], result["Auteur"], result["DatePublication"], result["Editeur"], result["ISBN"], result["UrlImage"], result["Synopsis"], result["Lu"], result["Envie"]);
      // on l'ajoute aux données
      listDataLivre.add(monLivre);
      // et selon le choix de l'utilisateur on instancie un widget correspondant dans les envies ou dans la bibliothèque
      if(result["Envie"]){
        listCardEnvie.add(new CardLivre(monLivre));
      }
      else {
        listCardLivre.add(new CardLivre(monLivre));
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
    setState(() {
      // ajouter recement
      if(option == 0) {
        this.listCardLivre.sort( ( a, b ) {
          return (a as CardLivre).cl_livre.data_dateAjout.compareTo((b as CardLivre).cl_livre.data_dateAjout);
        });
        print("Trier: Ajouter recement");
        // par titre
      } else if(option == 1){
        this.listCardLivre.sort( ( a, b ) {
          return (a as CardLivre).cl_livre.data_titre.toString().toLowerCase().compareTo((b as CardLivre).cl_livre.data_titre.toString().toLowerCase());
        });
        print("Trier: Par titre");
        // auteur par ordre alphabéthique
      } else if(option == 2){
        this.listCardLivre.sort( ( a, b) {
          return (a as CardLivre).cl_livre.data_auteur.toString().toLowerCase().compareTo((b as CardLivre).cl_livre.data_auteur.toString().toLowerCase());
        });
        print("Trier: Par auteur");
        // livres lus
      } else if(option == 3){
        this.listCardLivre.sort( ( a, b ) {
          if(!(a as CardLivre).cl_livre.data_lu && (b as CardLivre).cl_livre.data_lu){
            return 1;
          }
          if((a as CardLivre).cl_livre.data_lu && !(b as CardLivre).cl_livre.data_lu){
            return -1;
          }
          return 0;
        });
        print("Trier: Si lu ou pas");
        // inverse
      } else if(option == 4){
        this.listCardLivre.sort( ( a, b ) {
          return 1;
        });
        print("Trier: Ordre inverse");
        // met les favoris au dessus
      } else if(option == 5){
        this.listCardLivre.sort( ( a, b ) {
          if(!(a as CardLivre).cl_livre.data_favori && (b as CardLivre).cl_livre.data_favori){
            return 1;
          }
          if((a as CardLivre).cl_livre.data_favori && !(b as CardLivre).cl_livre.data_favori){
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
      return new Stat(listDataLivre);
    }));
  }

  
  @override
  Widget build(BuildContext context) {

    print("Début build barcodeScanner");

    // a chaque début du build on doit recompter le nombre de favoris pour donner la longueur de cette liste au listeView du volet favori
    this.nbrFavoris;


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
                            return new Livre(_scanBarcode, true);
                          }));
                        },
                        trailingIcon: new Icon(Icons.info_outline, color: Colors.green,)
                    ),
                    new FocusedMenuItem(
                      title: new Text("Ajouter / Supprimer comme lu"),
                      onPressed: (){
                        setState(() {
                          (this.listCardLivre[index] as CardLivre).cl_livre.data_lu = !(this.listCardLivre[index] as CardLivre).cl_livre.data_lu;
                        });
                        Scaffold.of(context).showSnackBar(new SnackBar(
                          content: (this.listCardLivre[index] as CardLivre).cl_livre.data_lu ? new Text("Marqué comme lu") : new Text("Marqué comme non lu") ,
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
                          if((this.listCardLivre[index] as CardLivre).cl_livre.data_favori){
                            nbrFavoris --;
                          }
                          // on save l'isbn avant
                          String isbn = (this.listCardLivre[index] as CardLivre).cl_livre.data_ISBN;
                          // on supprime le Card livre
                          listCardLivre.removeAt(index);
                          // on supprimer le dataLivre
                          for(int i = 0; i < this.listDataLivre.length; i ++){
                            if(this.listDataLivre[i].data_ISBN == isbn){
                              this.listDataLivre.removeAt(i);
                            }
                          }
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
      // les favoris
      new Container(
        key: Key(UniqueKey().toString()),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: this.nbrFavoris == 0 ? new Center(child: new TextePerso("Aucun favoris n'a été ajouté pour le moment", textScaleFactor: 1.6, textAlign: TextAlign.center,),): new Center(
            child: ListView.builder(
              itemCount: this.nbrFavoris,
              itemBuilder: (context, index){
                return new Container(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: new FocusedMenuHolder(
                    menuItemExtent: 60.0,
                    onPressed: (){},
                    menuItems: <FocusedMenuItem> [
                      new FocusedMenuItem(
                          title: new Text("Voir les détails"),
                          onPressed: (){
                            Navigator.push(context, new MaterialPageRoute(builder:  (BuildContext context) {
                              return new Livre(_scanBarcode, true);
                            }));
                          },
                          trailingIcon: new Icon(Icons.info_outline, color: Colors.green,)
                      ),
                      new FocusedMenuItem(
                        title: new Text("Supprimer"),
                        onPressed: (){
                          setState(() {
                            nbrFavoris --;
                            String isbn = (this.listCardLivre[index] as CardLivre).cl_livre.data_ISBN;
                            listCardLivre.removeAt(index);
                            for(int i = 0; i < this.listDataLivre.length; i ++){
                              if(this.listDataLivre[i].data_ISBN == isbn){
                                this.listDataLivre.removeAt(i);
                              }
                            }
                          });
                        },
                        trailingIcon: new Icon(Icons.delete_outline, color: Colors.red,),
                      ),
                    ],
                    child: (this.listCardLivre.elementAt(index) as CardLivre).cl_livre.data_favori ? listCardLivre[index] : null,
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
                                return new Livre(_scanBarcode, true);
                              }));
                            },
                            trailingIcon: new Icon(Icons.info_outline, color: Colors.green,)
                        ),
                        new FocusedMenuItem(
                          title: new Text("Supprimer"),
                          onPressed: (){
                            setState(() {
                              String isbn = (this.listCardEnvie[index] as CardLivre).cl_livre.data_ISBN;
                              listCardEnvie.removeAt(index);
                              for(int i = 0; i < this.listDataLivre.length; i ++){
                                if(this.listDataLivre[i].data_ISBN == isbn){
                                  this.listDataLivre.removeAt(i);
                                }
                              }
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
                  else if(index == 1) {
                    // on met les favoris au dessus
                    trier(5);
                    this.nbrFavoris = 0;
                    for( int i = 0; i < this.listCardLivre.length; i++){
                      if((this.listCardLivre.elementAt(i) as CardLivre).cl_livre.data_favori){
                        this.nbrFavoris++;
                      }
                    }
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
                  icon: Icon(Icons.favorite),
                  label: 'Favoris',
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
                new PopupMenuButton <int> (
                  onSelected: (int selected){ trier(selected);},
                  icon: new Icon(Icons.sort), // Icons.toc
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<int>> [
                    PopupMenuItem(child: new Text("Trier les livre par:       ")),
                    PopupMenuItem( value: 0, child: new Row(mainAxisAlignment: MainAxisAlignment.start ,children: [new Icon(Icons.timer_outlined, color: Colors.green,),  new Container(width: 15), new Text("Dernier ajout")],)),
                    PopupMenuItem(value: 1, child: new Row(mainAxisAlignment: MainAxisAlignment.start ,children: [new Icon(Icons.edit, color: Colors.green,), new Container(width: 15), new Text("Par titre")],)),
                    PopupMenuItem(value: 2, child: new Row(mainAxisAlignment: MainAxisAlignment.start ,children: [new Icon(Icons.people, color: Colors.green,), new Container(width: 15), new Text("Par auteur")],)),
                    PopupMenuItem(value: 3, child: new Row(mainAxisAlignment: MainAxisAlignment.start ,children: [new Icon(Icons.book, color: Colors.green,), new Container(width: 15), new Text("Les livres lus")],)),
                    PopupMenuItem(value: 4, child: new Row(mainAxisAlignment: MainAxisAlignment.start ,children: [new Icon(Icons.autorenew_rounded, color: Colors.green,), new Container(width: 15), new Text("Inverser")],)),
                  ],
                )
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // pourquoi pas changer sa position
            floatingActionButton: new FloatingActionButton(
              onPressed: () => scanBarcodeNormal(),
              elevation: 20.0,
              tooltip: "Chercher un nouveau livre",
              child: new Icon(Icons.add, color: Colors.white,),
            ),
            body: new Builder(builder: (BuildContext context) {
              return widgetList.elementAt(selectedIndex);
            })
        )
    );
  }


}