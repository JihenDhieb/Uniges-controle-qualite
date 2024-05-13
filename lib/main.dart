import 'dart:async';
import 'dart:io';

import 'package:controle_qualite/Screens/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:http/http.dart';
import 'Global/GlobalVar.dart';
import 'package:hive/hive.dart';

Box queueBox;
Box settingsBox;

var headersJSON = {
  "Accept": "application/json",
  "content-type": "application/json"
};

int _queueIndex = 0;

void sendData() async {
  if (mutex || queueBox.length == 0) return;
  mutex = true;

  _queueIndex++;
  if (_queueIndex >= queueBox.length) _queueIndex = 0;

  //userSettings = Setting.fromJson(json.decode(settingsBox.getAt(0)));

  try {
    String payload = queueBox.getAt(_queueIndex);

    String apiURL;

    if (payload.contains("xQualFNC_Id"))
      apiURL = "api/msgi/ControleQualite_FNC";
    else
      apiURL = "api/ds/post";

    Response res = await post(Uri.parse("${userSettings.serverURL}$apiURL"),
        body: payload, headers: headersJSON);
    if (res.statusCode == 200) {
      await queueBox.deleteAt(_queueIndex);
      mutex = false;
      sendData();
      return;
    }
  } catch (e) {
    print("**Send method exception** ${e.toString()}");
  }
  mutex = false;
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: darkBlue,
      statusBarBrightness: Brightness.dark,
    ),
  );
  new Timer.periodic(Duration(seconds: 5), (Timer t) => sendData());
  runApp(MyApp());
}

void fixData() async {}

class MyApp extends StatelessWidget {
  Future<void> showAppEvenWhenPhoneIsLocked() async {
    await FlutterWindowManager.addFlags(
        FlutterWindowManager.FLAG_SHOW_WHEN_LOCKED);
  }

  @override
  Widget build(BuildContext context) {
    showAppEvenWhenPhoneIsLocked();
    return MaterialApp(
      title: 'UnigesControleQualite',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        primaryColor: darkBlue,
        scaffoldBackgroundColor: Colors.grey[200],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}
