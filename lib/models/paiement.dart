class Paiement {
  final int id;
  final double montant;

  Paiement({required this.id, required this.montant});

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: (json['id'] is int) ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      montant: (json['montant'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'montant': montant,
    };
  }
}
