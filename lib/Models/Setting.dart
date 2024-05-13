import 'dart:convert';

class Setting {
  String password;
  String serverURL;
  bool enableManualCode;

  Setting(
      {this.password = "", this.serverURL = "", this.enableManualCode = false});
  Setting.fromJson(Map<String, dynamic> json) {
    password = json["password"];
    serverURL = json["serverURL"];
    enableManualCode = json["enableManualCode"];
  }
  String settingToJson() {
    var subMap = new Map<String, dynamic>();
    subMap["password"] = password;
    subMap["serverURL"] = serverURL;
    subMap["enableManualCode"] = enableManualCode;
    return jsonEncode(subMap);
  }

  @override
  String toString() {
    return "$password  $serverURL  $enableManualCode";
  }
}
