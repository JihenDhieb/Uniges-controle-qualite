import 'dart:convert';
import 'dart:io';
import 'package:controle_qualite/Global/GlobalVar.dart';
import 'package:controle_qualite/Models/Cause.dart';
import 'package:controle_qualite/Models/Machine.dart';
import 'package:controle_qualite/Models/Operation.dart';
import 'package:controle_qualite/Models/Type.dart';
import 'package:controle_qualite/Screens/HomeScreen.dart';
import 'package:controle_qualite/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

class FicheNonConformite extends StatefulWidget {
  String qFControle_CodeBarre;
  String qF_Num;
  String qFControle_NumPiece;

  FicheNonConformite({Key key, String code}) : super(key: key) {
    if (!code.contains(";")) return;
    qFControle_CodeBarre = code;
    qF_Num = code.split(";").elementAt(0);
    qFControle_NumPiece = code.split(";").elementAt(1);
  }
  @override
  _FicheNonConformiteState createState() => _FicheNonConformiteState();
}

class _FicheNonConformiteState extends State<FicheNonConformite> {
  List<Operation> data_operations = [];
  List<Machine> data_machines = [];
  List<TypeNC> data_types = [];
  List<Cause> data_causes = [];

  List<Operation> dropdown_operations = [];
  List<Machine> dropdown_machines = [];
  List<TypeNC> dropdown_types = [];
  List<Cause> dropdown_causes = [];

  //DropDown Controllers:
  Operation selectedOperation;
  Machine selectedMachine;
  TypeNC selectedType;
  Cause selectedCause;

  File _image;
  TextEditingController description = new TextEditingController();
  Widget alternativeBody = Center(
    child: SpinKitCubeGrid(
      color: darkBlue,
      size: 75,
    ),
  );
  List<String> errorsLog = [];

  Widget loading(String s) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Chargement des $s",
            style: GoogleFonts.signika(
              textStyle: TextStyle(
                fontSize: 18,
                color: darkBlue,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: SpinKitCubeGrid(
              color: darkBlue,
              size: 75,
            ),
          ),
        ],
      ),
    );
  }

  Future<String> buildPayload() async {
    try {
      var payload = {
        "xQualFNC_Id": null,
        "xQualFNC_OFNum": widget.qF_Num,
        "Perso_Matricule": employee.persoPrenom,
        "xQualFNC_PieceNum": widget.qFControle_NumPiece,
        "OFDG_Num": selectedOperation.oFDG_Num,
        "xQualCause_Id": selectedCause.xQualCause_Id,
        "xQualType_Id": selectedType.xQualType_Id,
        "Machine_Code": selectedMachine?.machine_Code,
        "xQualFNC_Desc": description.text,
        "xQualFNC_Date": DateTime.now().toString(),
        "xQualFNC_Image": base64Encode(await _image.readAsBytes()),
      };

      return jsonEncode(payload);
    } catch (e) {
      return null;
    }
  }

  Future<void> getEverything() async {
    try {
      errorsLog.clear();

      setState(() {
        alternativeBody = loading("opérations");
      });

      var operationResponse =
          await get(Uri.parse("$operationsURL${widget.qF_Num}"));
      if (operationResponse.statusCode == 200) {
        var operationsJson = json.decode(operationResponse.body);
        data_operations.clear();
        for (var item in operationsJson) {
          data_operations.add(Operation.fromJson(item));
        }
        if (data_operations.isEmpty)
          errorsLog.add("Aucune opération n'est trouvée");
      } else {
        buildAlternativeBody();
      }
      setState(() {
        alternativeBody = loading("machines");
      });

      var machineResponse = await get(Uri.parse(
          "$machinesURL${widget.qF_Num}:${widget.qFControle_NumPiece}"));
      if (machineResponse.statusCode == 200) {
        var machinesJson = json.decode(machineResponse.body);
        data_machines.clear();
        for (var item in machinesJson) {
          data_machines.add(Machine.fromJson(item));
        }
        if (data_machines.isEmpty)
          errorsLog.add("Aucune machine n'est trouvée");
      } else {
        buildAlternativeBody();
      }
      setState(() {
        alternativeBody = loading("types");
      });
      var typeResponse = await get(Uri.parse(typesURL));
      if (typeResponse.statusCode == 200) {
        var typesJson = json.decode(typeResponse.body);
        data_types.clear();
        for (var item in typesJson) {
          data_types.add(TypeNC.fromJson(item));
        }
        if (data_types.isEmpty) errorsLog.add("Aucun type n'est trouvé");
      } else {
        buildAlternativeBody();
      }
      setState(() {
        alternativeBody = loading("causes");
      });
      var causeResponse = await get(Uri.parse(causesURL));
      if (causeResponse.statusCode == 200) {
        var causeJson = json.decode(causeResponse.body);
        data_causes.clear();
        for (var item in causeJson) {
          data_causes.add(Cause.fromJson(item));
        }
        if (data_causes.isEmpty) errorsLog.add("Aucune cause n'est trouvée");
      } else {
        buildAlternativeBody();
      }

      if (errorsLog.isNotEmpty) {
        alternativeBody = Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var item in errorsLog)
                Container(
                  padding: EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
                  child: Text(
                    "$item pour l'${widget.qF_Num}",
                    style: GoogleFonts.signika(
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: darkBlue,
                      ),
                    ),
                  ),
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
                          Icons.refresh,
                          size: 26,
                          color: darkBlue,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          child: Text(
                            "Réessayer",
                            style: TextStyle(
                              fontSize: 18,
                              color: darkBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        alternativeBody = Center(
                          child: SpinKitCubeGrid(
                            color: darkBlue,
                            size: 75,
                          ),
                        );
                      });
                      getEverything();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
        setState(() {});
      }
      setState(() {
        dropdown_operations.clear();
        dropdown_operations.addAll(data_operations.where((Operation item) =>
            data_machines.indexWhere(
                (Machine item2) => item.oFDG_Num == item2.oFDG_Num) !=
            -1));

        refreshDropdrownLists();
      });
    } catch (e) {
      buildAlternativeBody();
    }
  }

  void refreshDropdrownLists() {
    dropdown_causes.clear();
    dropdown_types.clear();

    setState(() {});
    if (selectedOperation == null) return;
    setState(() {});

    dropdown_machines = data_machines
        .where((Machine item) => item.oFDG_Num == selectedOperation.oFDG_Num)
        .toList();

    selectedMachine = dropdown_machines.isEmpty ? null : dropdown_machines[0];

    dropdown_types = data_types
        .where((TypeNC item) =>
            item.xQualType_OperationID.toString() == selectedOperation.oFDG_Num)
        .toList();
    setState(() {});
    if (selectedType == null) return;

    dropdown_causes = data_causes
        .where((Cause item) => item.xQualType_Id == selectedType.xQualType_Id)
        .toList();

    setState(() {});
  }

  buildAlternativeBody() {
    alternativeBody = Center(
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
              alternativeBody = Center(
                child: SpinKitCubeGrid(
                  color: darkBlue,
                  size: 75,
                ),
              );
            });
            getEverything();
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

  queueData(String data) async {
    //await pq.push(data);
    await queueBox.add(data);
  }

  @override
  void initState() {
    getEverything();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Fiche de non conformité",
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
      body: (data_operations.isEmpty ||
              data_operations.isEmpty ||
              data_machines.isEmpty ||
              data_causes.isEmpty)
          ? alternativeBody
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    //Operation Card
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 15,
                          bottom: 15,
                          right: 10,
                          left: 10,
                        ),
                        child: Container(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "Opération",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Container(
                                //width: 130,
                                padding: EdgeInsets.only(
                                  left: 6,
                                  right: 2,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2.0,
                                    color: darkBlue.withOpacity(0.5),
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      10,
                                    ),
                                  ),
                                ),
                                child: ClipRRect(
                                  child: Container(
                                    width: 160,
                                    child: DropdownButton<Operation>(
                                      hint: Text("Opération         "),
                                      underline: Container(),
                                      value: selectedOperation,
                                      icon: Container(),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                      onChanged: (Operation newValue) {
                                        if (selectedOperation !=
                                            null) if (selectedOperation
                                                .oFDG_Num ==
                                            newValue.oFDG_Num) return;
                                        selectedCause = null;
                                        selectedType = null;
                                        selectedOperation = newValue;
                                        refreshDropdrownLists();
                                        setState(() {});
                                      },
                                      items: dropdown_operations.map(
                                        (Operation item) {
                                          return DropdownMenuItem<Operation>(
                                            value: item,
                                            child: Text(item.oFDG_Designation),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    //Type Card
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 15,
                          bottom: 15,
                          right: 10,
                          left: 10,
                        ),
                        child: Container(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "Type",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                  left: 6,
                                  right: 2,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2.0,
                                    color: darkBlue.withOpacity(0.5),
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      10,
                                    ),
                                  ),
                                ),
                                child: ClipRRect(
                                  child: Container(
                                    width: 160,
                                    child: DropdownButton<TypeNC>(
                                      hint: Text("Type                  "),
                                      underline: Container(),
                                      value: selectedType,
                                      icon: Container(),
                                      /*icon: Icon(
                                        Icons.arrow_downward,
                                      ),*/
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                      onChanged: (TypeNC newValue) {
                                        if (selectedType !=
                                            null) if (selectedType
                                                .xQualType_Id ==
                                            newValue.xQualType_Id) return;
                                        selectedCause = null;
                                        selectedType = newValue;
                                        refreshDropdrownLists();
                                        setState(() {});
                                      },
                                      items: dropdown_types.map(
                                        (TypeNC value) {
                                          return DropdownMenuItem<TypeNC>(
                                            value: value,
                                            child: Text(value.xQualType_Titre),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    //Cause Card
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 15,
                          bottom: 15,
                          right: 10,
                          left: 10,
                        ),
                        child: Container(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "Cause",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                  left: 6,
                                  right: 2,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2.0,
                                    color: darkBlue.withOpacity(0.5),
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      10,
                                    ),
                                  ),
                                ),
                                child: ClipRRect(
                                  child: Container(
                                    width: 160,
                                    child: DropdownButton<Cause>(
                                      hint: Text("Cause               "),
                                      underline: Container(),
                                      value: selectedCause,
                                      icon: Container(),
                                      /*icon: Icon(
                                        Icons.arrow_downward,
                                      ),*/
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                      onChanged: (Cause newValue) {
                                        selectedCause = newValue;
                                        refreshDropdrownLists();
                                        setState(() {});
                                      },
                                      items: dropdown_causes
                                          .map<DropdownMenuItem<Cause>>(
                                        (Cause value) {
                                          return DropdownMenuItem<Cause>(
                                            value: value,
                                            child: Text(value.xQualCause_Titre),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Card(
                      elevation: 3,
                      child: TextButton(
                        onPressed: () {
                          showChoiceDialog(context);
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 6,
                            bottom: 6,
                          ),
                          child: _image == null
                              ? Container(
                                  height:
                                      MediaQuery.of(context).size.width - 20,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text("Cliquez pour inserer image"),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  margin: EdgeInsets.only(left: 4, right: 4),
                                  color: Colors.grey[350],
                                  //padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Image.file(_image),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Card(
                      elevation: 3,
                      child: Container(
                        padding: const EdgeInsets.only(
                          top: 15,
                          bottom: 15,
                          right: 10,
                          left: 10,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Description",
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: null,
                          controller: description,
                        ),
                      ),
                    ),
                    //Save Button
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
                          onPressed: () async {
                            if (selectedType != null &&
                                selectedCause != null &&
                                _image != null) {
                              String data = await buildPayload();
                              if (data == null) {
                                Fluttertoast.showToast(
                                    msg: "Erreur d'enregistrement");
                                return;
                              }
                              queueData(data);
                              Fluttertoast.showToast(
                                msg: "Fiche Enregistée !",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                              );
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(),
                                  ),
                                  (Route<dynamic> route) => false);
                            } else {
                              Fluttertoast.showToast(
                                msg: "Veuillez remplir toute la fiche !",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  final picker = ImagePicker();

  openCamera() async {
    Navigator.of(context).pop();
    var pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 25);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> showChoiceDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choisir une option :'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                InkWell(
                  child: Container(
                    height: 80,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Icon(Icons.camera_alt),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Caméra"),
                      ],
                    ),
                  ),
                  onTap: () {
                    openCamera();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
