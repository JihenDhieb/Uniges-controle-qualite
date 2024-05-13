import 'package:controle_qualite/Models/Employee.dart';
import 'package:controle_qualite/Models/Setting.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/foundation.dart';

Setting userSettings = Setting();
Employee employee;

String androidId = "";

String Site_Code = "";

String employeeURL =
    "${userSettings.serverURL}api/recherche/tbdata?tablere=API_GetPersoNomByMatricule&param=";
String aspectsURL =
    "${userSettings.serverURL}api/recherche/tbdata?tablere=FicheControle&param=";

String operationsURL =
    "${userSettings.serverURL}api/recherche/tbdata?tablere=api_GammeParOF&param=";
String machinesURL =
    "${userSettings.serverURL}api/recherche/tbdata?tablere=api_MachinesParQRCode&param=";
String typesURL =
    "${userSettings.serverURL}api/recherche/tbdata?tablere=api_xQualType";
String causesURL =
    "${userSettings.serverURL}api/recherche/tbdata?tablere=api_xQualCause";
String controlePFURL =
    "${userSettings.serverURL}api/recherche/tbdata?tablere=FicheControlePF&param=";
String controleGalURL =
    "${userSettings.serverURL}api/recherche/tbdata?tablere=FicheControleGal&param=";
bool mutex = false;
Color darkBlue = Color.fromRGBO(1, 0, 78, 1);
Color myDarkCyan = Color.fromRGBO(2, 154, 186, 1);
Color myCyan = Color.fromRGBO(0, 253, 254, 1);
