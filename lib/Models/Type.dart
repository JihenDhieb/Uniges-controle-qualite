class TypeNC {
  int xQualType_Id;
  String xQualType_Titre;
  int xQualType_OperationID;
  // String xQualType_Ordre;

  TypeNC(
    this.xQualType_Id,
    this.xQualType_Titre,
    this.xQualType_OperationID,
    //this.xQualType_Ordre,
  );

  TypeNC.fromJson(Map<String, dynamic> json) {
    xQualType_Id = json["XQualType_Id"];
    xQualType_Titre = json["xQualType_Titre"];
    xQualType_OperationID = json["xQualType_OperationID"];
    // xQualType_Ordre = json["xQualType_Ordre"];
  }
}
