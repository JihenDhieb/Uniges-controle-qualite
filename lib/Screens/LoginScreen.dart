import 'dart:async';

import 'package:controle_qualite/Global/GlobalVar.dart';
import 'package:controle_qualite/Global/unigesBackend.dart';
import 'package:controle_qualite/Models/Employee.dart';
import 'package:controle_qualite/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  final bool fromHomeScreen;
  LoginScreen({this.fromHomeScreen = false});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoggedIn = false;
  bool isLoading = false;
  bool enableEditing = true;
  TextEditingController usernameTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLoggedIn = (employee != null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Connexion',
                      //style: GoogleFonts.signika(
                      style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                          color: Color.fromRGBO(195, 197, 255, 1),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: isLoggedIn
                        ? Text(
                            "Bienvenu ${employee.toString()}",
                            style: GoogleFonts.signika(
                              textStyle: TextStyle(
                                fontSize: 20,
                                color: myDarkCyan,
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  "Veuillez saisir vos données de connexion",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.signika(
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      color: myDarkCyan,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Center(
                                child: Column(
                                  children: [
                                    TextFormField(
                                      enabled: enableEditing,
                                      onFieldSubmitted: (_) {
                                        login();
                                      },
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.auto,
                                        hintText: "Nom d'utilisateur",
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          fontStyle: FontStyle.italic,
                                          color: myCyan,
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: myCyan,
                                      ),
                                      controller: usernameTextController,
                                      autofocus: false,
                                      keyboardType: TextInputType.name,
                                    ),
                                     TextFormField(
                                      obscureText: true,
                                      enabled: enableEditing,
                                      onFieldSubmitted: (_) {
                                        login();
                                      },
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.auto,
                                        hintText: "Mot de passe",
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          fontStyle: FontStyle.italic,
                                          color: myCyan,
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: myCyan,
                                      ),
                                      controller: passwordTextController,
                                      autofocus: false,
                                      keyboardType: TextInputType.visiblePassword,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                isLoading
                    ? Expanded(
                        flex: 1,
                        child: Center(
                          child: SpinKitRing(
                            color: myDarkCyan,
                            size: 50,
                          ),
                        ),
                      )
                    : isLoggedIn
                        ? Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                "assets/images/buttonGradien.png"),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        child: ButtonTheme(
                                          child: TextButton(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Text(
                                                "Suivant",
                                                style: GoogleFonts.nunito(
                                                  textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              next();
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                "assets/images/gradientRed.jpg"),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        child: ButtonTheme(
                                          child: TextButton(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Text(
                                                "Se déconnecter",
                                                style: GoogleFonts.nunito(
                                                  textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              logOut();
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Expanded(
                            flex: 1,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          "assets/images/buttonGradien.png"),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  child: ButtonTheme(
                                    child: TextButton(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          "Se connecter",
                                          style: GoogleFonts.nunito(
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        login();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    if (usernameTextController.text == "" || passwordTextController.text == "" ) return;
    setState(() {
      isLoading = true;
      isLoggedIn = false;
      enableEditing = false;
    });
    try {
      
      var isLoginSuccess = await UnigesBackend.login(usernameTextController.text, passwordTextController.text);

      if (isLoginSuccess) {
        
          employee = Employee(persoMatricule: usernameTextController.text, persoNom: usernameTextController.text, persoPrenom: usernameTextController.text);

          isLoading = false;
          isLoggedIn = true;
          enableEditing = true;
      } else {
        Fluttertoast.showToast(msg: "Veuillez vérifier le nom d'utilisateur et/ou le mot de passe !");
        isLoading = false;
        isLoggedIn = false;
        enableEditing = true;
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Un problème de connexion est survenu !");
      isLoading = false;
      isLoggedIn = false;
      enableEditing = true;
    }
    setState(() {});
  }

  void logOut() {
    employee = null;
    Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              LoginScreen(),
        ),
        (Route<dynamic> route) => false);
  }

  void next() {
    if (widget.fromHomeScreen) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
            reloadSetting: true,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(0.0, 1.0);
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
    }
  }
}
