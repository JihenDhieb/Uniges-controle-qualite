class Cause {
  int xQualCause_Id;
  String xQualCause_Titre;
  int xQualType_Id;
  // int xQualCause_Ordre;

  Cause(
    this.xQualCause_Id,
    this.xQualCause_Titre,
    this.xQualType_Id,
    // this.xQualCause_Ordre
  );

  Cause.fromJson(Map<String, dynamic> json) {
    xQualCause_Id = json["xQualCause_Id"];
    xQualCause_Titre = json["xQualCause_Titre"];
    xQualType_Id = json["xQualType_Id"];
    //xQualCause_Ordre = json["xQualCause_Ordre"];
  }
}
