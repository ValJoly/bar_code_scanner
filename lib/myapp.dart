import 'package:bar_code_scanner/barcodescanner.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {


    // my app ne sert pas a grand chose en fait?
    // dans home on renvoit carrement une nouvelle
    // material app et pas juste un scaffold


    return new MaterialApp(
      title: 'ISBN Reader',
      theme: new ThemeData(
          primarySwatch: Colors.green
      ),
      debugShowCheckedModeBanner: false,
      home: new BarCodeScanner(),
      routes: <String, WidgetBuilder> {
      },
    );
  }
}
