import 'dart:convert';

import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UnigesBackend {
  //static String baseUrl = "http://proxy-msgi-dev.cloud.pmc.tn/api";
  static String baseUrl = "https://srv2-msgi.pmc.tn/api";

  static Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json'
  };

  static Future<List<dynamic>> tableRecherche(tablere,
      {List<String> param = const []}) async {
    String _params = param.join(',');

    try {
      var _url = '$baseUrl/recherche/tbdata?tablere=$tablere';
      if (param.length > 0) _url += '&param=$_params';
      print(_url);

      var res = await get(Uri.parse(_url));
      return jsonDecode(res.body);
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<dynamic> dsGet(code, {List<String> param = const []}) async {
    String _params = param.join(',');

    try {
      var _url = '$baseUrl/ds/formdata?code=$code';
      if (param.length > 0) _url += '&val=$_params';
      print(_url);

      var res = await get(Uri.parse(_url));
      return jsonDecode(res.body);
    } catch (e) {
      print(e);
      return const {};
    }
  }

  static Future<bool> dsPost(body) async {
    try {
      var res = await post(Uri.parse('$baseUrl/ds/uploadFile'),
          headers: requestHeaders, body: jsonEncode(body));
      print(res.body);
      print(res.statusCode);
      if (res.statusCode < 300) return true;
      return false;
    } catch (e) {
      print('Error in dsPost: $e'); // Afficher l'erreur exacte ici
      return false;
    }
  }

  static Future<bool> dsSkgPost(body) async {
    try {
      var res = await post(Uri.parse('$baseUrl/skg/post'),
          headers: requestHeaders, body: jsonEncode(body));
      print(res.body);
      print(res.statusCode);
      if (res.statusCode < 300) return true;
      return false;
      //return jsonDecode(res.body);
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> login(String username, String password) async {
    try {
      var _url = '$baseUrl/users/login';
      print(_url);
      var res = await post(Uri.parse(_url),
          headers: requestHeaders,
          body: jsonEncode({"username": username, "password": password}));
      print(res.statusCode);
      print(res.body);

      var response = jsonDecode(res.body);
      print(response);

      return response["success"];
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<dynamic> getAppInfos() async {
    var res = await UnigesBackend.tableRecherche("API_xApps",
        param: [(await PackageInfo.fromPlatform()).packageName]);
    try {
      return res.elementAt(0);
    } catch (e) {
      return null;
    }
  }
}
