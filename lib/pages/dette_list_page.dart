import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/client_controller.dart';

class DetteListPage extends StatelessWidget {
  final ClientController clientController = Get.find<ClientController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Dettes'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (clientController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (clientController.errorMessage.isNotEmpty) {
          return Center(
              child: Text(
            clientController.errorMessage.value,
            style: TextStyle(color: Colors.red),
          ));
        }

        // Récupérer toutes les dettes de tous les clients dans une liste plate
        final allDettes = clientController.clients.expand((client) {
          return client.dettes.map((dette) => {
                'clientNom': client.nom,
                'date': dette.date,
                'montantDette': dette.montantDette,
                'montantPaye': dette.montantPaye,
                'montantRestant': dette.montantRestant,
              });
        }).toList();

        if (allDettes.isEmpty) {
          return Center(child: Text('Aucune dette trouvée'));
        }

        return ListView.builder(
          itemCount: allDettes.length,
          itemBuilder: (context, index) {
            final dette = allDettes[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text('${dette['clientNom']}'),
                subtitle: Text(
                  'Date: ${dette['date']}\nMontant dû: ${dette['montantDette']} FCFA\nPayé: ${dette['montantPaye']} FCFA',
                ),
                trailing: Text(
                  'Restant:\n${dette['montantRestant']} FCFA',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: (dette['montantRestant'] > 0) ? Colors.red : Colors.green,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
