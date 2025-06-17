import 'dette.dart';


class Client {
  final String id;  // id en String
  final String nom;
  final String telephone;
  final String adresse;
  final List<Dette> dettes;

  Client({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.adresse,
    required this.dettes,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    var dettesJson = json['dettes'] as List? ?? [];
    List<Dette> dettesList = dettesJson.map((d) => Dette.fromJson(d)).toList();

    return Client(
      id: json['id'].toString(), // force en String
      nom: json['nom'] ?? '',
      telephone: json['telephone'] ?? '',
      adresse: json['adresse'] ?? '',
      dettes: dettesList,
    );
  }
}
