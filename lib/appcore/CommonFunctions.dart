import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

import 'UITheme.dart';

class CommonFunctions {
  
  /// Returns the DateTime variable in a friendly format
  /// Example: Sep 25, 2019
  static String getDateAsFriendlyFormat(DateTime dateTime) {
    return formatDate(dateTime, [M, ' ', dd, ', ', yyyy]);
  }

  /// Returns the DateTime variable in a friendly format
  /// Example: 05:30 pm
  static String getTimeAsFriendlyFormat(DateTime dateTime) {
    return formatDate(dateTime, [hh, ':', nn, ' ', am]);
  }

  /// Confirmation Dialog Box with bool result
  static Future<bool> getConfirmationDialogResult(
      BuildContext context, String message) {
    // flutter defined function
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            "Confirmation Required",
            style: TextStyle(color: UITheme.bodyTxt1Color),
          ),
          content: Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: UITheme.bodyTxt1Color),
              ),
              onPressed: () {
                // Navigator.of(context).pop();
                Navigator.pop(context, false);
              },
            ),
            FlatButton(
              child: Text(
                "OK",
                style: TextStyle(color: UITheme.bodyTxt1Color),
              ),
              onPressed: () {
                // callFunction(context);
                // Navigator.of(context).pop();
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  /// Informattioional Dialog Box with bool result
  static Future<bool> getInformationDialogResult(
      BuildContext context, String message) {
    // flutter defined function
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            "Info",
            style: TextStyle(color: UITheme.bodyTxt1Color),
          ),
          content: Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(
                "OK",
                style: TextStyle(color: UITheme.bodyTxt1Color),
              ),
              onPressed: () {
                // callFunction(context);
                // Navigator.of(context).pop();
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }
}
