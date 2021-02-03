import 'package:bar_code_scanner/widgetsPerso/textePerso.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'mesObjets/dataLivre.dart';


class Stat extends StatelessWidget {

  // Attributs
  List<DataLivre> data;
  double nbrLivre;
  double nbrEnvie;
  double nbrLu;

  DateTime premierAjout;
  DateTime ajourdhui;

  // pour le circular
  final GlobalKey<AnimatedCircularChartState> _chartKey = new GlobalKey<AnimatedCircularChartState>();
  // data du circular
  List<CircularStackEntry> circular;

  // pour le circular2
  final GlobalKey<AnimatedCircularChartState> key2 = new GlobalKey<AnimatedCircularChartState>();
  // data du circular
  List<CircularStackEntry> circular2;

  // pour la sparkline --> ca c'est les ordonnées
  // celle ci c'est pour la démo
  var sparkline = [2.0, 1.0, 1.5, 2.0, 0.0, 0.0, -0.5, -1.0, -0.5, 0.0, 0.0];
  // celle ci c'est pour le swag
  var sparklineV2 = [0.0];


  // constructeur
  Stat(List<DataLivre> listDataLivre, List<DataLivre> listDataEnvie){
    print("constructeur");
    // on compte les envies, livres, etc...
    nbrLivre = listDataLivre.length.toDouble();
    nbrEnvie = listDataEnvie.length.toDouble();
    nbrLu = 0;
    for(int i = 0; i < listDataLivre.length ; i++){
      if(listDataLivre.elementAt(i).data_lu){
        nbrLu ++;
      }
    }
    // maintenant pour l'historique
    // on check si ya au moins un livre
    if(listDataLivre.isNotEmpty){
      DateTime lePlusVieux = listDataLivre[0].data_dateAjout;
      DateTime lePlusRecent = listDataLivre[0].data_dateAjout;
      // on determine la date du plus vieux ajout et du plus recent
      for(int i = 0; i < listDataLivre.length ; i++){
        if(listDataLivre[i].data_dateAjout.isBefore(lePlusVieux)){
          lePlusVieux = listDataLivre[i].data_dateAjout;
        }
        if(listDataLivre[i].data_dateAjout.isAfter(lePlusRecent)){
          lePlusRecent = listDataLivre[i].data_dateAjout;
        }
      }
      // nombre de jour qui les sépare
      int nbrJour = lePlusVieux.difference(lePlusRecent).inDays + 1;
      print("Nombre de jour entre les deux $nbrJour");
      // maintenant on va construire le tableau pour le graphe
      // autant de données que de jour entre les deux
      // et à chaque jour on associe le nombre de livre qui ont été ajouté ce jour la
      // leplusVieux va nous servir de jour courant pour la compraraison
      DateTime jourEnCour = lePlusVieux;
      for(int i = 0; i<nbrJour; i++){
        double nbrLivreAjouteCeJour = 0.0;
        // on compare tous les livres de la liste au jour en cours et on compte combien ont été ajouté ce jour la
        for (DataLivre livre in listDataLivre) {
          if(jourEnCour.day == livre.data_dateAjout.day && jourEnCour.month == livre.data_dateAjout.month && jourEnCour.year == livre.data_dateAjout.year){
            nbrLivreAjouteCeJour += 1.0;
          }
        }
        sparklineV2.add(nbrLivreAjouteCeJour);
        jourEnCour = jourEnCour.add(new Duration(days: 1));
      }
    }

    // on ajoute au entrée du circular (celui en haut a gauche de la vue)
    circular = <CircularStackEntry>[
      new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(nbrLivre, Colors.green[200], rankKey: 'Livre'),
          new CircularSegmentEntry(nbrEnvie, Colors.amber[200], rankKey: 'Envie'),
          new CircularSegmentEntry(0.001, Colors.white, rankKey: 'vide'),
        ],
        rankKey: 'Ratio',
      ),
    ];
    // on rempli les date
    ajourdhui = DateTime.now();
    DateTime temp = ajourdhui;
    for(int i = 0 ; i < listDataLivre.length ; i++){
        if(data.elementAt(i).data_dateAjout.isBefore(temp)){
          temp = data.elementAt(i).data_dateAjout;
        }
    }
    // circular 2 (en bas de la vue)
    circular2 = <CircularStackEntry>[
      new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(nbrLu, Colors.green[300], rankKey: 'Livre lus'),
          new CircularSegmentEntry(nbrLivre - nbrLu, Colors.deepOrange[200], rankKey: 'livre pas lu'),
          new CircularSegmentEntry(0.001, Colors.white, rankKey: 'vide'),
        ],
        rankKey: 'Ratio',
      ),
    ];

  }


  @override
  Widget build(BuildContext context) {

    double largeur = MediaQuery.of(context).size.width;
    double hauteur =  MediaQuery.of(context).size.height;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Statistiques utilisateur"),
      ),

      body: new ListView(
       children: [
         new Container(
           padding: EdgeInsets.all(largeur * 0.05),
           child: new Center(
             child: new Column(
               children: [
                 new Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     new Card(
                       elevation: 20.0,
                       child: new Container(
                         padding: EdgeInsets.all(17.0),
                         child: new Column(
                           children: [
                             new TextePerso("Tous vos livres:", textScaleFactor: 1.3, fontWeight: FontWeight.bold,),
                             new Container(height: 10,),
                             new AnimatedCircularChart(
                               key: _chartKey,
                               duration: new Duration(seconds: 3),
                               size: new Size(largeur* 0.35, largeur * 0.35),
                               initialChartData: circular,
                               chartType: CircularChartType.Pie,
                             )
                           ],
                         ),
                       ),
                     ),
                     new Column(
                       children: [
                         new Card(
                           elevation: 20.0,
                           child: new Container(
                             width: largeur*0.4,
                             padding: EdgeInsets.all(10.0),
                             child: new Column(
                               children: [
                                 new TextePerso("Ma bibliothèque", fontWeight: FontWeight.bold, textScaleFactor: 1.1, color: Colors.green,),
                                 new Divider(height: 8.0,),
                                 new TextePerso(nbrLivre.toInt().toString()+" livres", textScaleFactor: 2.0,)
                               ],
                             ),
                           ),
                         ),
                         new Container(height: 17.0,),
                         new Card(
                           elevation: 20.0,
                           child: new Container(
                             width: largeur*0.4,
                             padding: EdgeInsets.all(10.0),
                             child: new Column(
                               children: [
                                 new TextePerso("Mes Envies", fontWeight: FontWeight.bold, textScaleFactor: 1.1,  color: Colors.amber),
                                 new Divider(height: 8.0,),
                                 new TextePerso(nbrEnvie.toInt().toString()+" livres", textScaleFactor: 2.0,)
                               ],
                             ),
                           ),
                         )
                       ],
                     )
                   ],
                 ),
                 new Container(height: hauteur*0.02,),
                 new Card(
                   elevation: 20.0,
                   child: new Container(
                     padding: EdgeInsets.all(20.0),
                     child: new Column(
                       children: [
                         new TextePerso("Historique", textScaleFactor: 1.5, fontWeight: FontWeight.bold,),
                         new Divider(height: 20, endIndent: 10.0, indent: 10.0, thickness: 1.5,),
                         new Sparkline(
                           data: sparklineV2,
                           fillMode: FillMode.below,
                           fillGradient: new LinearGradient(
                             begin: Alignment.topCenter,
                             end: Alignment.bottomCenter,
                             colors: [Colors.blue[800], Colors.blue[200]],
                           ),
                         ),
                       ],
                     ),
                   ),
                 ),
                 new Container(height: hauteur*0.02,),
                 new Card(
                   elevation: 20.0,
                   child: new Container(
                     padding: EdgeInsets.all(20.0),
                     child: new Column(
                       children: [
                         new TextePerso("Vos lectures:", textScaleFactor: 1.5, fontWeight: FontWeight.bold,),
                         new Divider(height: 20, endIndent: 10.0, indent: 10.0, thickness: 1.5,),
                         new Row(
                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                           children: [
                             new AnimatedCircularChart(
                               key: key2,
                               duration: new Duration(seconds: 3),
                               size: new Size(largeur* 0.35, largeur * 0.35),
                               initialChartData: circular2,
                               chartType: CircularChartType.Pie,
                             ),
                             new Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 new Row(
                                   children: [
                                     new Icon(Icons.data_usage, color: Colors.green[300],),
                                     new TextePerso("\t"+nbrLu.toInt().toString()+" livres lus"),
                                   ],
                                 ),
                                 new Row(
                                   children: [
                                     new Icon(Icons.data_usage, color: Colors.deepOrange,),
                                     new TextePerso("\t"+(nbrLivre - nbrLu).toInt().toString()+" livres non lus"),
                                   ],
                                 ),
                               ],
                             ),
                           ],
                         ),
                       ],
                     ),
                   ),
                 ),
               ],
             ),
           ),
         ),
       ],
      )
    );
  }


}