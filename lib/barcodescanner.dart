import 'dart:async';

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

  // ne plus afficher
  bool nePlusAfficher = false;

  // volet selectioné parmis les 3
  int selectedIndex = 0;

  // nombre de favoris
  int nbrFavoris;

  // liste des livres
  List<DataLivre> listDataLivre =[];
  List<Widget> listCardLivre = [];


  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      getHelp2();
    });
  }



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
        MaterialPageRoute(builder: (context) => Livre(_scanBarcode, false))
    );

    print("\n\n\n\n\n\n\n\n\n"+"$result");

    setState(() {
      DataLivre monLivre = new DataLivre(result["Titre"], result["Auteur"], result["DatePublication"], result["Editeur"], result["ISBN"], result["UrlImage"], result["Synopsis"], result["Lu"], result["Envie"]);
      listDataLivre.add(monLivre);
      listCardLivre.add(new CardLivre(monLivre));
    });

  }

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
                  new FlatButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: new TextePerso("Go", textScaleFactor: 1.1, fontWeight: FontWeight.bold,)
                  ),
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

    // a chaque début du build on doit recompter le nombre de favoris pour donner la longueur de cette liste au listeView du volet favori
    this.nbrFavoris = 0;
    for( int i = 0; i < this.listDataLivre.length; i++){
      if(this.listDataLivre[i].data_favori){
        this.nbrFavoris++;
      }
    }

    // listes des widgets de la bottomBar
    List<Widget> widgetList = <Widget>[
      new Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: listCardLivre.length == 0 ? new Center(child: new TextePerso("Aucun livre dans votre biblihothèque pour le moment", textScaleFactor: 1.6, textAlign: TextAlign.center,),): new Center(
          child: ListView.builder(
            itemCount: listCardLivre.length,
            itemBuilder: (context, index){
              return new FocusedMenuHolder(
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
                          if(listDataLivre[index].data_favori){
                            nbrFavoris --;
                          }
                          listDataLivre.removeAt(index);
                          listCardLivre.removeAt(index);
                        });
                      },
                      trailingIcon: new Icon(Icons.delete_outline, color: Colors.red,),
                  ),
                ],
                child: listCardLivre[index],
              );
            },
          )
        ),
      ),
      new Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: this.nbrFavoris == 0 ? new Center(child: new TextePerso("Aucun favoris n'a été ajouté pour le moment", textScaleFactor: 1.6, textAlign: TextAlign.center,),): new Center(
            child: ListView.builder(
              itemCount: this.nbrFavoris,
              itemBuilder: (context, index){
                return new FocusedMenuHolder(
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
                          listDataLivre.removeAt(index);
                          listCardLivre.removeAt(index);
                          nbrFavoris --;
                        });
                      },
                      trailingIcon: new Icon(Icons.delete_outline, color: Colors.red,),
                    ),
                  ],
                  child: listDataLivre[index].data_favori ? listCardLivre[index] : null,
                );
              },
            )
        ),
      ),
      new Center(
          child: new Text("Envies")
      ),
    ];


    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
            primarySwatch: Colors.green
        ),
        home: new Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (int index) {
                setState(() {
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
              title: const Text('Ma Bibliothèque'),
              elevation: 10,
              actions: [
                new IconButton(icon: new Icon(Icons.help), onPressed: getHelp2),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // pourquoi pas changer sa position
            floatingActionButton: new FloatingActionButton(
              onPressed: () => scanBarcodeNormal(),
              elevation: 20.0,
              tooltip: "Chercher un nouveau livre",
              child: new Icon(Icons.add),
            ),
            body: Builder(builder: (BuildContext context) {
              return widgetList.elementAt(selectedIndex);
            })
        )
    );
  }


}