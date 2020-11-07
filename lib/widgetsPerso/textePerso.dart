import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class TextePerso extends Text {

  TextePerso (String texte, {color: Colors.black, textAlign: TextAlign.start, textScaleFactor: 1.0, fontWeight: FontWeight.normal, fontStyle: FontStyle.normal, backgroundColor: null}):
      super(
        texte,
        textScaleFactor: textScaleFactor,
        textAlign: textAlign,
        style: new TextStyle(
          color: color,
          fontSize: 15.0,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          backgroundColor: backgroundColor,
        )
      );

}