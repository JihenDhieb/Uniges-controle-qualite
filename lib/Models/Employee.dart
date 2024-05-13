import 'dart:convert';

Employee employeeFromJson(String str) => Employee.fromJson(json.decode(str));

String employeeToJson(Employee data) => json.encode(data.toJson());

class Employee {
  Employee({
    this.persoMatricule,
    this.persoNom,
    this.persoPrenom,
  });

  String persoMatricule;
  String persoNom;
  String persoPrenom;

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        persoMatricule: json["Perso_Matricule"],
        persoNom: json["Perso_Nom"],
        persoPrenom: json["Perso_Prenom"],
      );

  Map<String, dynamic> toJson() => {
        "Perso_Matricule": persoMatricule,
        "Perso_Nom": persoNom,
        "Perso_Prenom": persoPrenom,
      };

  String toString() {
    return persoNom.toUpperCase();
  }
}
