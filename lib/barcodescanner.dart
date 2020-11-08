import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'livre.dart';
import 'widgetsPerso/cardLivre.dart';


class BarCodeScanner extends StatefulWidget {
  @override
  _BarCodeScannerState createState() => _BarCodeScannerState();
}




class _BarCodeScannerState extends State<BarCodeScanner> {
  String _scanBarcode = 'Unknown';
  int selectedIndex = 0;

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

    setState(() {
      _scanBarcode = barcodeScanRes;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return Livre(_scanBarcode);
          },
        ),
        //'/GamePage'
      );
    });
  }

  Future<Null> getHelp() async{
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text("Aide"),
            content: new Text("Parcourez vos livres à travers les trois volets. Pour en ajouter, cliquez sur le bouton en bas à droite"),
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

    List<Widget> widgetList = <Widget>[
      new Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: new Center(
          child: new ListView(
            children: <Widget>[
              new CardLivre("Oscar et la dame rose", "Eric-Emmanuel Schmitt, paru en 2002, Albin Michel", true),
              new Container(height: 7.0,),
              new CardLivre("Oscar et la dame rose", "Eric-Emmanuel Schmitt, paru en 2002, Albin Michel", false),
              new Container(height: 7.0,),
              new CardLivre("Oscar et la dame rose", "Eric-Emmanuel Schmitt, paru en 2002, Albin Michel", false),
              new Container(height: 7.0,),
            ]
          )
        )
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