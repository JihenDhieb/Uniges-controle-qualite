import 'dart:convert';
import 'dart:io';
import 'package:controle_qualite/Global/GlobalVar.dart';
import 'package:controle_qualite/Global/unigesBackend.dart';
import 'package:controle_qualite/Models/aspect.dart';
import 'package:controle_qualite/Screens/HomeScreen.dart';
import 'package:controle_qualite/Views/AspectView.dart';
import 'package:controle_qualite/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

class FicheControleQualite extends StatefulWidget {
  final String codeBarre;
  final String tableRecherche;
  final String opeNum;
  final String libelle;

  const FicheControleQualite({
    Key key,
    @required this.libelle,
    @required this.codeBarre,
    @required this.tableRecherche,
    @required this.opeNum,
  }) : super(key: key);

  @override
  _FicheControleQualiteState createState() => _FicheControleQualiteState();
}

class _FicheControleQualiteState extends State<FicheControleQualite> {
  String ofNum;
  String numPiece;

  List<Aspect> _aspects;
  List<FocusNode> _focusNodes = [];
  List<Widget> cards;
  File _imageFile;

  Widget retry = Center(
    child: SpinKitCubeGrid(
      color: darkBlue,
      size: 75,
    ),
  );

  Future<void> fetchAspects() async {
    var res = await UnigesBackend.tableRecherche(widget.tableRecherche, param: [
      ofNum,
      widget.opeNum,
      numPiece,
      kDebugMode ? "7ab8fcc62ddea35" : await FlutterUdid.udid
    ]);
    if (res != null) {
      _aspects = res.map((e) => Aspect.fromJson(e)).toList();
      _focusNodes.clear();
      for (int i = 0; i < _aspects.length; i++) {
        _focusNodes.add(FocusNode());
      }
      cards = createView();
      setState(() {});
    } else {
      retry = Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: ElevatedButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh,
                  size: 26,
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  child: Text(
                    "Réessayer",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            onPressed: () {
              setState(() {
                retry = Center(
                  child: SpinKitCubeGrid(
                    color: darkBlue,
                    size: 75,
                  ),
                );
              });
              fetchAspects();
            },
          ),
        ),
      );
      setState(() {});
      Fluttertoast.showToast(
        msg: "Echec de connexion !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    }
  }

  List<AspectView> createView() {
    List<AspectView> v = [];
    if (_focusNodes.length != 0) {
      for (var index = 0; index < _focusNodes.length; index++) {
        if (_aspects[index].qfControleValeurNominale != null)
          v.add(
            AspectView(
              aspect: _aspects[index],
              focusNode: _focusNodes[index],
              isLast: index == _focusNodes.length - 1 ? true : false,
              nextFocusNode: index == _focusNodes.length - 1
                  ? null
                  : _focusNodes[index + 1],
            ),
          );
      }
    }
    return v;
  }

  void _sendData(String payload) async {
    try {
      if ((_imageFile == null) &&
          (widget.opeNum == "1" || widget.opeNum == "10")) {
        Fluttertoast.showToast(
          msg: "Veuillez prendre une photo !",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
        return;
      }
      // Le reste du code pour envoyer les données...
      String apiURL = "api/ds/post";
      Response res = await post(
        Uri.parse("${userSettings.serverURL}$apiURL"),
        body: payload,
        headers: headersJSON,
      );
      if (res.statusCode == 200) {
        print("Data sent successfully!");
        print(res.body);

        var file_key = jsonDecode(res.body)["code"];
        print(file_key);
        var imageBytes = await _imageFile.readAsBytes();
        var imageBase64 = base64Encode(imageBytes);
        var dsFiles = await UnigesBackend.dsGet("Files");
        dsFiles["Files"][0]["File_Key"] = file_key;
        dsFiles["Files"][0]["File_Content"] = imageBase64;
        dsFiles["Files"][0]["File_Date"] = DateTime.now().toIso8601String();
        dsFiles["Files"][0]["File_Extension"] = "png";
        print(dsFiles);
        if (await UnigesBackend.dsPost(dsFiles)) {
          print("Image sent successfully!");
        } else {
          print("Error sending image!");
        }
      } else {
        print("Failed to send data. Status code: ${res.statusCode}");
      }
    } catch (e) {
      print("**Send method exception** ${e.toString()}");
    }
  }

  String buildPayload() {
    var payload2 = {
      "QualFicheR": [
        {
          "QualFicheR_Code": null,
          "QualFiche_Code": null,
          "QualFiche_Libelle": null,
          "QualFiche_Date": null,
          "QualFiche_Texte": null,
          "Art_Code": null,
          "QualFiche_Doc": null,
          "Ope_Code": widget.opeNum,
          "OFDG_Num": widget.opeNum,
          "QualFicheR_Conforme": (cards as List<AspectView>)
                  .where((element) =>
                      element.value >
                          element.aspect.qfControleValeurNominale +
                              element.aspect.qfControleToleranceP ||
                      element.value <
                          element.aspect.qfControleValeurNominale -
                              element.aspect.qfControleToleranceN)
                  .toList()
                  .isEmpty
              ? '1'
              : '0',
          "User_Id_Create": employee.persoNom,
          "Date_Create": null,
          "User_Id_Modif": null,
          "Date_Modif": null,
          "OF_Num": ofNum,
          "Site_Code": Site_Code,
          "QualFiche_NumPiece": numPiece,
          "Perso_Matricule": employee.persoMatricule,
          "U_timestamp": null
        }
      ],
      "QualFicheRD": (cards as List<AspectView>)
          .where((card) => !card.isEmpty)
          .map((card) => {
                "id": null,
                "QualFicheR_Code": null,
                "QualFiche_Code": null,
                "QualFicheR_Val": null,
                "QualFicheD_Type": null,
                "QualFicheD_Text": card.aspect.qfControleTitre,
                "QualControl_Code": null,
                "QualFicheD_ValeurNominale":
                    card.aspect.qfControleValeurNominale,
                "QualFicheD_ToleranceP": card.aspect.qfControleToleranceP,
                "QualFicheD_ToleranceN": card.aspect.qfControleToleranceN,
                "QualFicheRD_ValeurMesure": card.value,
                "QualFicheRD_Conforme": card.value >
                            card.aspect.qfControleValeurNominale +
                                card.aspect.qfControleToleranceP ||
                        card.value <
                            card.aspect.qfControleValeurNominale -
                                card.aspect.qfControleToleranceN
                    ? '1'
                    : '0',
                "U_timestamp": null
              })
          .toList(),
      "ApiForm": [
        {"For_Code": "QualFicheR", "For_Val": ""}
      ],
    };

    print(jsonEncode(payload2));

    return jsonEncode(payload2);
  }

  Future<void> _takePicture() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  @override
  void initState() {
    ofNum = widget.codeBarre.split(";")[0];
    numPiece = widget.codeBarre.split(";")[1];
    fetchAspects();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.libelle,
              style: GoogleFonts.signika(
                textStyle: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Text(
              "${ofNum.toUpperCase()}",
              style: GoogleFonts.signika(
                textStyle: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: (cards == null)
            ? retry
            : (cards.isEmpty)
                ? Center(
                    child: Text("Aucun SOF n'est effectué sur cette pièce"))
                : SingleChildScrollView(
                    child: Container(
                      color: Colors.grey[200],
                      child: Form(
                        child: Column(
                          children: [
                            SizedBox(height: 2),
                            Column(
                              children: cards,
                            ),
                            Center(
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 10.0),
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.camera),
                                  label: Text('Prendre une photo'),
                                  onPressed: _takePicture,
                                ),
                              ),
                            ),
                            if (_imageFile != null)
                              Center(
                                child: Image.file(_imageFile),
                              ),
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(top: 15, bottom: 20),
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if ((cards as List<AspectView>)
                                        .where(
                                            (element) => element.value == null)
                                        .toList()
                                        .isNotEmpty) {
                                      Fluttertoast.showToast(
                                        msg: "Veuillez remplir le rapport !",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                      );
                                      return;
                                    }

                                    if (_imageFile == null) {
                                      Fluttertoast.showToast(
                                        msg: "Veuillez prendre une photo !",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                      );
                                      return;
                                    }
                                    String data = buildPayload();
                                    await _sendData(
                                        data); // Appel direct à la fonction sendData
                                    Fluttertoast.showToast(
                                      msg: "Rapport Enregistré !",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                    );
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => HomeScreen(),
                                      ),
                                      (Route<dynamic> route) => false,
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.send_to_mobile,
                                        size: 26,
                                        color: darkBlue,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Enregistrer",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: darkBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
