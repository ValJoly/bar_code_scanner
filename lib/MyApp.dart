import 'package:bar_code_scanner/barcodescanner.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
      title: 'ISBN Reader',
      theme: new ThemeData(
          primarySwatch: Colors.amber
      ),
      debugShowCheckedModeBanner: false,
      home: new BarCodeScanner(),
      routes: <String, WidgetBuilder> {
      },
    );
  }
}
