import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_download/pages/ThreadListUI.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new ThreadListUI());
  });
}
  