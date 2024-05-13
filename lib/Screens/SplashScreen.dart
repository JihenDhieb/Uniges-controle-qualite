import 'package:controle_qualite/Global/GlobalVar.dart';
import 'package:controle_qualite/Global/unigesBackend.dart';
import 'package:controle_qualite/Models/Setting.dart';
import 'package:controle_qualite/Screens/HomeScreen.dart';
import 'package:controle_qualite/Screens/LoginScreen.dart';
import 'package:controle_qualite/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:hive/hive.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

String version = "";
String loadingMessage = "Initilisation des paramètres ..";
bool isLoading = false;

class _SplashScreenState extends State<SplashScreen> {
  Future<bool> checkForUpdates() async {
    try {
      version = (await PackageInfo.fromPlatform()).buildNumber;

      dynamic _appInfos = await UnigesBackend.getAppInfos();

      int _minVersion = _appInfos["xApps_minVersion"];
      String _lastVersionURL = _appInfos["xApps_lastVersionURL"];

      if (_minVersion != null && _minVersion > int.parse(version)) {
        OtaUpdate()
            .execute(
          _lastVersionURL,
          destinationFilename: 'app.apk',
        )
            .listen((OtaEvent event) {
          setState(() {
            loadingMessage =
                "Téléchargement de la mise à jour en cours ( ${event.value}% )";
          });
        });

        setState(() {
          isLoading = true;
          loadingMessage = "Téléchargement de la mise à jour en cours";
        });
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadSettings() async {
    setState(() {
      loadingMessage = "Initilisation des paramètres ..";
    });

    if (await checkForUpdates()) {
      return;
    }

    WidgetsFlutterBinding.ensureInitialized();

    var appDocDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocDirectory.path);

    settingsBox = await Hive.openBox("Settings_new4");
    queueBox = await Hive.openBox('queue');

    settingsBox.clear();
    userSettings = Setting(
        serverURL: settingsBox.get("serverURL"),
        password: settingsBox.get("password"),
        enableManualCode: settingsBox.get("enableManualCode"));

    userSettings.serverURL = "https://srv2-msgi.pmc.tn/";

    try {
      androidId = await FlutterUdid.udid;
      var req = await UnigesBackend.tableRecherche("API_PDAProfile",
          param: [androidId]);
      String s = req[0]["Site_Code"];

      Site_Code = s;
      settingsBox.put("Site_Code", s);
    } catch (e) {}

    if (settingsBox.containsKey("Site_Code")) {
      Site_Code = settingsBox.get("Site_Code");
    }

    if (userSettings.enableManualCode == null)
      userSettings.enableManualCode = !kReleaseMode;

    Navigator.of(context).pop();
    if (employee != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => HomeScreen(reloadSetting: false)));
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  void initState() {
    loadSettings();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(loadingMessage)));
  }
}
