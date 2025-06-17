import 'package:flutter/material.dart';
import '../models/client.dart';
import '../models/dette.dart';

class ListeDettesPage extends StatefulWidget {
  final List<Client> clients;

  const ListeDettesPage({Key? key, required this.clients}) : super(key: key);

  @override
  State<ListeDettesPage> createState() => _ListeDettesPageState();
}

class _ListeDettesPageState extends State<ListeDettesPage> {
  String searchText = '';

  List<Map<String, dynamic>> get filteredDettes {
    final List<Map<String, dynamic>> toutesLesDettes = [];

    for (var client in widget.clients) {
      if (searchText.isEmpty || client.nom.toLowerCase().contains(searchText.toLowerCase())) {
        for (var dette in client.dettes) {
          toutesLesDettes.add({'client': client, 'dette': dette});
        }
      }
    }

    return toutesLesDettes;
  }

  @override
  Widget build(BuildContext context) {
    final dettesAffichees = filteredDettes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toutes les dettes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher par nom de client',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: dettesAffichees.isEmpty
                ? const Center(child: Text('Aucune dette trouvée'))
                : ListView.builder(
                    itemCount: dettesAffichees.length,
                    itemBuilder: (context, index) {
                      final client = dettesAffichees[index]['client'] as Client;
                      final dette = dettesAffichees[index]['dette'] as Dette;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: ListTile(
                          title: Text('Client: ${client.nom}'),
                          subtitle: Text(
                            'Date: ${dette.date}\n'
                            'Montant total: ${dette.montantDette.toStringAsFixed(2)}\n'
                            'Payé: ${dette.montantPaye.toStringAsFixed(2)}\n'
                            'Restant: ${dette.montantRestant.toStringAsFixed(2)}',
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
