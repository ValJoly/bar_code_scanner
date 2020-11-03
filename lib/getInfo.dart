import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:yaml/yaml.dart' as yaml;

class book {

  String name;
  String summary;
  String isbn = '';
  String author;
  String editor;
  String url = 'https://openlibrary.org/isbn/';
  //String url = 'http://openlibrary.org/api/books?bibkeys=ISBN:';


  book(String ISBN) {
    isbn = ISBN;
  }

  void getInfo() async{

    var response = await http.get(url + isbn + '.json');

    if (response.statusCode == 200) {
      print(response.body);
      //Map<String, dynamic> book = convert.jsonDecode(response.body);

      var jsonResponse = convert.jsonDecode(response.body);
      var title = jsonResponse['subtitle'];
      print('Title of this book : $title.');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }
}