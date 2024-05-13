import 'package:controle_qualite/Global/GlobalVar.dart';
import 'package:controle_qualite/Models/Setting.dart';
import 'package:controle_qualite/Screens/HomeScreen.dart';
import 'package:controle_qualite/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingScreen extends StatefulWidget {
  bool firstTime;
  SettingScreen({this.firstTime = false});
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool enableManualCodeController;
  TextEditingController serverURLFieldController = new TextEditingController();
  TextEditingController passwordFieldController = new TextEditingController();

  void getSettings() {
    serverURLFieldController.text = userSettings.serverURL;
    enableManualCodeController = userSettings.enableManualCode;
    setState(() {});
  }

  @override
  void initState() {
    getSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // if (!widget.firstTime) {
        //   changeCompleted();
        //   return false;
        // }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            "Paramétres",
            style: GoogleFonts.signika(
              textStyle: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 20,
                              bottom: 10,
                              right: 10,
                              left: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Adresse du serveur",
                                  style: GoogleFonts.signika(
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "URL",
                                    prefixIcon:
                                        Icon(Icons.settings_remote_rounded),
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
                                  keyboardType: TextInputType.url,
                                  controller: serverURLFieldController,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 20,
                              bottom: 10,
                              right: 10,
                              left: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Mot de passe",
                                  style: GoogleFonts.signika(
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.lock),
                                    hintText: "Tapez le nouveau mot de passe",
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
                                  controller: passwordFieldController,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 20,
                              bottom: 20,
                              right: 10,
                              left: 10,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Entrée manuelle du code à barre",
                                    style: GoogleFonts.signika(
                                      textStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: enableManualCodeController,
                                  onChanged: (value) {
                                    setState(() {
                                      enableManualCodeController = value;
                                    });
                                  },
                                  //activeTrackColor: Colors.blueAccent,
                                  activeColor: darkBlue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.only(
                      top: 5,
                      bottom: 20,
                    ),
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 50,
                    child: ElevatedButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.save,
                            size: 26,
                            color: darkBlue,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            child: Text(
                              "Enregistrer",
                              style: TextStyle(
                                fontSize: 18,
                                color: darkBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        if (!widget.firstTime) {
                          //changeCompleted();
                          return;
                        }
                        //createFirstUser();
                      },
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

  void changeCompleted() async {
    if (serverURLFieldController.text != userSettings.serverURL ||
        enableManualCodeController != userSettings.enableManualCode ||
        passwordFieldController.text != "") {
      userSettings = Setting(
        password: passwordFieldController.text == ""
            ? userSettings.password
            : passwordFieldController.text,
        serverURL: serverURLFieldController.text,
        enableManualCode: enableManualCodeController == null
            ? false
            : enableManualCodeController,
      );

      settingsBox.clear();
      settingsBox.put("serverURL", userSettings.serverURL);
      settingsBox.put("password", userSettings.password);
      settingsBox.put("enableManualCode", userSettings.enableManualCode);

      Fluttertoast.showToast(
        msg: "Nouvelles paramétres enregistrés !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              reloadSetting: true,
            ),
          ),
          (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pop();
    }
  }

  /*void createFirstUser() {
    /*if (serverURLFieldController.text != userSettings.serverURL ||
            enableManualCodeController != userSettings.enableManualCode
        //||passwordFieldController.text != ""
        ) {*/
    userSettings = Setting(
      password: passwordFieldController.text,
      serverURL: serverURLFieldController.text,
      enableManualCode: enableManualCodeController,
    );
    settingsBox.clear();
    settingsBox.add(userSettings.settingToJson());
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            reloadSetting: true,
          ),
        ),
        (Route<dynamic> route) => false);
    //}
  }*/
}
