import 'package:animations/animations.dart';
import 'package:controle_qualite/Global/GlobalVar.dart';
import 'package:controle_qualite/Global/unigesBackend.dart';
import 'package:controle_qualite/Screens/FicheContQual.dart';
import 'package:controle_qualite/Screens/FicheNonConformite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:google_fonts/google_fonts.dart';

class ControleTypeSelectionScreen extends StatefulWidget {
  final String code;

  ControleTypeSelectionScreen({this.code});
  @override
  _ControleTypeSelectionScreenState createState() =>
      _ControleTypeSelectionScreenState();
}

class _ControleTypeSelectionScreenState
    extends State<ControleTypeSelectionScreen> {
  
  List<dynamic> typesControles;

  fetchControleTypes() async {
    
    typesControles =
        await UnigesBackend.tableRecherche("API_QualContConf", param: [widget.code.replaceAll(';', '~'), widget.code.split(";").elementAt(0).toUpperCase(), widget.code.split(";").elementAt(1).toUpperCase(), kDebugMode ? "7ab8fcc62ddea35" : await FlutterUdid.udid, employee.persoMatricule ] ) ?? [];
    
    //typesControles = await UnigesBackend.tableRecherche("API_QualCont_PieceOPE", param: [widget.code, widget.code.split(";").elementAt(0).toUpperCase(), widget.code.split(";").elementAt(1).toUpperCase() ]) ?? [];
    
    setState(() {});
  }

  @override
  void initState() {
    fetchControleTypes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "${widget.code.split(";").elementAt(0).toUpperCase()}",
          style: GoogleFonts.signika(
            textStyle: TextStyle(),
          ),
        ),
      ),
      body: typesControles == null || typesControles.isEmpty
          ? Center(
              child: SpinKitCircle(
              color: darkBlue,
            ))
          : SingleChildScrollView(
            child: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...typesControles
                        .map((x) => OpenContainer(
                            closedElevation: 0,
                            closedBuilder: (context, action) => Card(
                                  margin: EdgeInsets.all(4),
                                  color: darkBlue,
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 40, vertical: 8),
                                      child: Text(
                                        x["libelle"],
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      )),
                                ),
                            openBuilder: (context, action) =>
                                FicheControleQualite(
                                    libelle: x["libelle"],
                                    codeBarre: widget.code,
                                    tableRecherche: x["tabRech"],
                                    opeNum: x["operation"].toString())))
                        .toList(),
                    OpenContainer(
                        closedElevation: 0,
                        closedBuilder: (context, action) => Card(
                              margin: EdgeInsets.all(15),
                              color: Colors.red[800],
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 12),
                                  child: Text(
                                    "Fiche non conformité",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  )),
                            ),
                        openBuilder: (context, action) => FicheNonConformite(
                              code: widget.code,
                            ))
                  ],
                ),
              ),
          ),
    );
  }
}
