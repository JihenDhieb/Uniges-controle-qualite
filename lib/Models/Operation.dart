class Operation {
  String oFDG_Num;
  String oFDG_Designation;

  Operation(
    this.oFDG_Num,
    this.oFDG_Designation,
  );

  Operation.fromJson(Map<String, dynamic> json) {
    oFDG_Num = json["OFDG_Num"];
    oFDG_Designation = json["OFDG_Designation"];
  }
}
