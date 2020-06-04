import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:mime/mime.dart';

class ShareLib {  
  /// Shares text
  Future<bool> shareMessagesAsText(String messageData) async {
    // debugPrint("Attempting to share as text");
    try {
      //esys
      // works for sharing text
      Share.text('Share Messages', messageData, 'text/plain');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Shares a file (Now working fully)
  Future<void> shareMessagesAsFile(File fileToShare) async {
    List<int> bytesList = fileToShare.readAsBytesSync().toList();
    String mimeType = lookupMimeType(fileToShare.path);
  
    await Share.file(
        "file title!", fileToShare.path.split('/').last, bytesList, mimeType);
  }
}
  