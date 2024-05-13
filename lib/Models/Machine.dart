class Machine {
  String oFDG_Num;
  //String oFSPDA_CodeBarre;
  String machine_Code;

  Machine(
    this.oFDG_Num, //this.oFSPDA_CodeBarre,
    this.machine_Code,
  );

  Machine.fromJson(Map<String, dynamic> json) {
    oFDG_Num = json["OFDG_Num"];
    //oFSPDA_CodeBarre = json["OFSPDA_CodeBarre"];
    machine_Code = json["Machine_Code"];
  }
}
