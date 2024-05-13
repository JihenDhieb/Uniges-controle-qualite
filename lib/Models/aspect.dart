import 'dart:convert';

List<Aspect> aspectFromJson(String str) =>
    List<Aspect>.from(json.decode(str).map((x) => Aspect.fromJson(x)));

String aspectToJson(List<Aspect> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Aspect {
  Aspect({
    this.qfControleTitre,
    this.qfControleValeurNominale,
    this.qfControleToleranceP,
    this.qfControleToleranceN,
  });

  String qfControleTitre;
  double qfControleValeurNominale;
  double qfControleToleranceP;
  double qfControleToleranceN;

  factory Aspect.fromJson(Map<String, dynamic> json) => Aspect(
        qfControleTitre: json["QualFicheD_Text"],
        qfControleValeurNominale:
            double.tryParse(json["QualFicheD_ValeurNominale"].toString()),
        qfControleToleranceP:
            double.tryParse(json["QualFicheD_ToleranceP"].toString()),
        qfControleToleranceN:
            double.tryParse(json["QualFicheD_ToleranceN"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "QualFicheD_Text": qfControleTitre,
        "QualFicheD_ValeurNominale": qfControleValeurNominale,
        "QualFicheD_ToleranceP": qfControleToleranceP,
        "QualFicheD_ToleranceN": qfControleToleranceN,
      };
}
