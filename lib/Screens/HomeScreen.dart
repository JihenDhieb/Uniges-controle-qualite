import 'dart:async';

import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:controle_qualite/Animation/FadeAnimation.dart';
import 'package:controle_qualite/Global/GlobalVar.dart';
import 'package:controle_qualite/Screens/ControleTypeSelectionScreen.dart';
import 'package:controle_qualite/Screens/LoginScreen.dart';
import 'package:controle_qualite/Screens/SettingsScreen.dart';
import 'package:controle_qualite/Views/statusBar.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class HomeScreen extends StatefulWidget {
  final bool reloadSetting;
  HomeScreen({this.reloadSetting = false});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool isLoading = true;
  final myController = TextEditingController();
  static const channel =
      const MethodChannel('com.example.controle_qualite/PDAscan');

  bool _isInForeground = true;

  TextEditingController passwordTextFieldController =
      new TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    isLoading = false;

    try {
      channel.setMethodCallHandler((call) {
        String code = call.arguments;
        onQRCodeScan(code);
        return;
      });
    } catch (e) {}

    ClipboardListenerObj.listeners.clear();
    ClipboardListener.addListener(() async {
      if (_isInForeground)
        onQRCodeScan((await Clipboard.getData(Clipboard.kTextPlain)).text);
    });

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String decodeQRCode(String encryptedQRCode) {
    try {
      final key = encrypt.Key.fromUtf8('Q#w)m2Fgc*(&KkA8');
      final iv = encrypt.IV.fromSecureRandom(16);

      final encrypter = encrypt.Encrypter(
          encrypt.AES(key, mode: encrypt.AESMode.ecb, padding: null));

      String temp = encrypter.decrypt64(encryptedQRCode, iv: iv);

      String res = "";
      for (int i = 0; i < temp.length; i++) {
        if (temp.codeUnits[i] >= 32) {
          res += temp[i];
        }
      }

      return res;
    } catch (e) {
      print(e);
      return null;
    }
  }

  onQRCodeScan(input) {
    String code = decodeQRCode(input) ?? input;

    try {
      if (code.split(";").length >= 2 && code.split(";")[1] != "") {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ControleTypeSelectionScreen(code: code),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Veuillez entrer un code valide",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  LoginScreen(
                fromHomeScreen: true,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                var begin = Offset(0.0, -1.0);
                var end = Offset.zero;
                var curve = Curves.ease;
                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(
                  CurveTween(curve: curve),
                );
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
          return false;
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              color: darkBlue,
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: FadeAnimation(
                              0.6,
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Color.fromRGBO(195, 197, 255, 1),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              LoginScreen(
                                            fromHomeScreen: true,
                                          ),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            var begin = Offset(0.0, -1.0);
                                            var end = Offset.zero;
                                            var curve = Curves.ease;
                                            var tween = Tween(
                                              begin: begin,
                                              end: end,
                                            ).chain(
                                              CurveTween(curve: curve),
                                            );
                                            return SlideTransition(
                                              position: animation.drive(tween),
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  Text(
                                    'Bienvenu ${employee.persoNom}',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunito(
                                      textStyle: TextStyle(
                                        color: Color.fromRGBO(195, 197, 255, 1),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: FadeAnimation(
                            0.4,
                            StatusBar(),
                          ),
                        ),
                      ],
                    ),
                    flex: 1, //Flex1
                  ),
                  Expanded(
                    child: FadeAnimation(
                      1.4,
                      Container(
                        child: Image(
                          image: AssetImage('assets/images/HomePageLogo.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    flex: 2, //flex2
                  ),
                  Expanded(
                    child: FadeAnimation(
                      1.6,
                      Container(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "Scannez code à barre",
                                  style: GoogleFonts.signika(
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      color: myDarkCyan,
                                    ),
                                  ),
                                ),
                              ),
                              if (userSettings.enableManualCode)
                                Container(
                                  width: 140,
                                  child: TextFormField(
                                    onFieldSubmitted: (_) {
                                      nextButtonPressed();
                                    },
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Entrez code à barre",
                                      hintStyle: TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: myCyan,
                                    ),
                                    controller: myController,
                                    autofocus: false,
                                  ),
                                ),
                              if (userSettings.enableManualCode)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "assets/images/buttonGradien.png"),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    width: 150,
                                    height: 50,
                                    child: ButtonTheme(
                                      child: TextButton(
                                        child: Text(
                                          "Next",
                                          style: GoogleFonts.nunito(
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          nextButtonPressed();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    flex: 1, //Flex3
                  ),
                  Text(
                    androidId,
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void nextButtonPressed() {
    if (myController.text.split(";").length >= 2 &&
        myController.text.split(";")[1] != "") {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ControleTypeSelectionScreen(
            code: myController.text,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: "Veuillez entrer un code valide",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    }
  }

  Future<void> showProvidePasswordDialog(BuildContext context) {
    passwordTextFieldController.text = "";
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Veuillez saisir le mot de passe',
            style: TextStyle(
              color: darkBlue,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "mot de passe",
                    hintStyle: GoogleFonts.signika(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  style: GoogleFonts.signika(
                    textStyle: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  autofocus: true,
                  controller: passwordTextFieldController,
                  onFieldSubmitted: (_) {
                    checkPassword();
                  },
                ),
                ElevatedButton(
                  onPressed: () => checkPassword(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Suivant",
                        style: TextStyle(
                          color: darkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  checkPassword() {
    if (passwordTextFieldController.text == userSettings.password) {
      Navigator.of(context).pop();
      passwordTextFieldController.text = "";
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SettingScreen(),
        ),
      );
    }
  }
}
