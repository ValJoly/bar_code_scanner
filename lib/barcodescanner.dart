import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'livre.dart';
import 'widgetsPerso/cardLivre.dart';


class BarCodeScanner extends StatefulWidget {
  @override
  _BarCodeScannerState createState() => _BarCodeScannerState();
}




class _BarCodeScannerState extends State<BarCodeScanner> {
  String _scanBarcode = 'Unknown';
  int selectedIndex = 0;
  // liste des livres
  List<Widget> livreList = [];


  @override
  void initState() {
    super.initState();
    print("hello");
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
        MaterialPageRoute(builder: (context) => Livre(_scanBarcode))
    );

    print("\n\n\n\n\n\n\n\n\n"+"$result");

    setState(() {
      livreList.add(new CardLivre(result["Titre"], "Info", false));
    });

  }



  Future<Null> getHelp() async{
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text("Aide"),
            content: new Text("Parcourez vos livres à travers les trois volets. Pour en ajouter, cliquez sur le bouton en bas à droite. Pour voir les détails ou le supprimer, maintenez appuyé votre doigt sur le livre."),
            actions: <Widget> [
              new FlatButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: new Text("OK")
              ),
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
      new Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: new Center(
          child: ListView.builder(
            itemCount: livreList.length,
            itemBuilder: (context, index){
              return new FocusedMenuHolder(
                menuItemExtent: 60.0,
                onPressed: (){},
                menuItems: <FocusedMenuItem> [
                  new FocusedMenuItem(
                      title: new Text("Voir les détails"),
                      onPressed: (){},
                      trailingIcon: new Icon(Icons.info_outline, color: Colors.green,)
                  ),
                  new FocusedMenuItem(
                      title: new Text("Supprimer"),
                      onPressed: (){
                        setState(() {
                          livreList.removeAt(index);
                        });
                      },
                      trailingIcon: new Icon(Icons.delete_outline, color: Colors.red,),
                  ),
                ],
                child: livreList[index],
              );
            },
          )
        ),
      ),
      new Center(
        child: new Text("Favoris")
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
                new IconButton(icon: new Icon(Icons.help), onPressed: getHelp),
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