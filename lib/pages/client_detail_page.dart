import 'package:flutter/material.dart';
import '../models/client.dart';

class ClientDetailPage extends StatelessWidget {
  final Client client;

  ClientDetailPage({required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de ${client.nom}'),
      ),
      body: ListView.builder(
        itemCount: client.dettes.length,
        itemBuilder: (context, index) {
          final dette = client.dettes[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text('Dette du ${dette.date}'),
              subtitle: Text(
                  'Montant total: ${dette.montantDette} - Payé: ${dette.montantPaye} - Restant: ${dette.montantRestant}'),
            ),
          );
        },
      ),
    );
  }
}
