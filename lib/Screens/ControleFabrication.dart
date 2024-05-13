import 'dart:convert';
import 'package:controle_qualite/Global/GlobalVar.dart';
import 'package:controle_qualite/Models/aspect.dart';
import 'package:controle_qualite/Screens/HomeScreen.dart';
import 'package:controle_qualite/Views/AspectView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import '../main.dart';

class ControlePage extends StatefulWidget {
  String qFControle_CodeBarre;
  String qF_Num;
  String qFControle_NumPiece;

  static goToNextField({FocusNode current, FocusNode next, bool isLast}) {
    current.unfocus();
    if (!isLast) next.requestFocus();
  }

  ControlePage({Key key, String code}) : super(key: key) {
    if (!code.contains(";")) return;
    qFControle_CodeBarre = code;
    qF_Num = code.split(";").elementAt(0);
    qFControle_NumPiece = code.split(";").elementAt(1);
  }

  @override
  _ControlePageState createState() => _ControlePageState();
}

class _ControlePageState extends State<ControlePage> {
  List<Aspect> _aspects = [];
  var _focusNodes = [];
  var color = Colors.black;
  List<Widget> cards = [];

  Widget retry = Center(
    child: SpinKitCubeGrid(
      color: darkBlue,
      size: 75,
    ),
  );

  Future<void> fetchAspects() async {
    try {
      var response = await get(Uri.parse(aspectsURL + widget.qF_Num + ",851"));
      if (response.statusCode == 200) {
        var aspectsJson = json.decode(response.body);
        _aspects.clear();
        _focusNodes.clear();
        for (var aspectJson in aspectsJson) {
          _aspects.add(Aspect.fromJson(aspectJson));
          _focusNodes.add(FocusNode());
        }
        cards = createView();
        setState(() {});
      }
    } catch (e) {
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

  queueData(String data) async {
    await queueBox.add(data);
  }

  String buildPayload() {
    List<Map> maps = [];
    for (AspectView card in cards) {
      if (card.isEmpty) continue;
      var subMap = new Map<String, dynamic>();
      subMap["QFControle_CodeBarre"] = widget.qFControle_CodeBarre;
      subMap["OF_Num"] = widget.qF_Num;
      subMap["QFControle_NumPiece"] = widget.qFControle_NumPiece;
      subMap["Perso_Matricule"] = employee.persoPrenom;
      subMap["QFControle_Titre"] = card.aspect.qfControleTitre;
      subMap["QFControle_ValeurMesure"] = card.value;
      subMap["QFControle_ValeurNominale"] =
          card.aspect.qfControleValeurNominale;
      subMap["QFControle_ToleranceP"] = card.aspect.qfControleToleranceP;
      subMap["QFControle_ToleranceN"] = card.aspect.qfControleToleranceN;
      subMap["QFControle_Date"] = DateTime.now().toString();
      subMap["Ope_Code"] = "851";
      //Add Last item:
      maps.add(subMap);
    }
    Map payload = new Map<String, List<Map>>();
    payload["QFControle"] = maps;
    return jsonEncode(payload);
  }

  @override
  void initState() {
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
              "Contrôle Fabrication",
              style: GoogleFonts.signika(
                textStyle: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Text(
              "${widget.qF_Num.toUpperCase()}",
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
        child: (cards.isEmpty)
            ? retry
            : SingleChildScrollView(
                child: Container(
                  color: Colors.grey[200],
                  child: Form(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 2,
                        ),
                        Column(
                          children: cards,
                        ),
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(
                              top: 15,
                              bottom: 20,
                            ),
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: 50,
                            child: ElevatedButton(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.send_to_mobile,
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
                                String data = buildPayload();
                                if (data == '{"QFControle":[]}') {
                                  Fluttertoast.showToast(
                                    msg: "Veuillez remplir le rapport !",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                  );
                                  return;
                                }
                                queueData(data);
                                Fluttertoast.showToast(
                                  msg: "Rapport Enregisté !",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                );
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
                                    ),
                                    (Route<dynamic> route) => false);
                              },
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
