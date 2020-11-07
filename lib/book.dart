import 'package:flutter/material.dart';
import 'getInfo.dart';

class Book extends StatefulWidget {

  String _ISBN = "Unknown";
  Book(String isbn) {
    _ISBN = isbn;
  }


  @override
  State<StatefulWidget> createState() {
    return new _Book(_ISBN);
  }
}



class _Book extends State<Book> {

  String _ISBN = "Unknown";
  _Book(String isbn) {
    _ISBN = isbn;
    book currentScan = new book(_ISBN);
    currentScan.getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text('Book'),
          leading: new Icon(Icons.book),
          centerTitle: true,
        ),

      body: Column(
        children: [
          Text('ISBN : ' + _ISBN),
        ],
      ),
    );
  }
}