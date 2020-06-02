import 'package:flutter/material.dart';

class UITheme {
  static Color hdrBgColor = Colors.blueGrey[900]; // lightBlue[900];
  static Color hdrTxtColor = Colors.white;

  static Color bodyTxt1Color = Colors.black;
  static Color bodyTxt2Color = Colors.grey;
  static Color bodyBgColor = Colors.white;

  static Color highlightBgColor = Colors.blueGrey[100];

  /// Returns a centered CircularProgressIndicator
  static Widget getLoadingWidget() {
    return CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(hdrBgColor));
  }
}
