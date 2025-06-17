import 'paiement.dart';

class Dette {
  final int id;
  final String date;
  final double montantDette;
  final double montantPaye;
  final List<Paiement> paiements;

  Dette({
    required this.id,
    required this.date,
    required this.montantDette,
    required this.montantPaye,
    required this.paiements,
  });

  factory Dette.fromJson(Map<String, dynamic> json) {
    var paiementsJson = json['paiements'] as List? ?? [];
    List<Paiement> paiementsList = paiementsJson.map((p) => Paiement.fromJson(p)).toList();

    return Dette(
      id: (json['id'] is int) ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      date: json['date'] ?? '',
      montantDette: (json['montantDette'] as num?)?.toDouble() ?? 0.0,
      montantPaye: (json['montantPaye'] as num?)?.toDouble() ?? 0.0,
      paiements: paiementsList,
    );
  }

  double get montantRestant {
    return montantDette - montantPaye;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'montantDette': montantDette,
      'montantPaye': montantPaye,
      'paiements': paiements.map((p) => p.toJson()).toList(),
    };
  }
}
