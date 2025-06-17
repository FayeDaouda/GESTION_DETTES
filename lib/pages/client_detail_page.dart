import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/client.dart';
import '../controllers/client_controller.dart';

class ClientDetailPage extends StatefulWidget {
  final Client client;

  const ClientDetailPage({Key? key, required this.client}) : super(key: key);

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage> {
  final ClientController _clientController = Get.find<ClientController>();

  final _dateController = TextEditingController();
  final _montantController = TextEditingController();
  final _montantPayeController = TextEditingController();

  void _showAddDetteDialog() {
    _dateController.clear();
    _montantController.clear();
    _montantPayeController.clear();

    Get.defaultDialog(
      title: 'Ajouter une dette à ${widget.client.nom}',
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildTextField(_dateController, 'Date (ex: 2025-06-17)'),
            _buildTextField(_montantController, 'Montant dette', isNumber: true),
            _buildTextField(_montantPayeController, 'Montant payé', isNumber: true),
            const SizedBox(height: 16),
            Obx(() {
              if (_clientController.isLoading.value) {
                return const CircularProgressIndicator();
              }
              return ElevatedButton(
                onPressed: _handleAddDette,
                child: const Text('Ajouter'),
              );
            }),
          ],
        ),
      ),
    );
  }

  TextField _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    );
  }

  Future<void> _handleAddDette() async {
    final date = _dateController.text.trim();
    final montant = double.tryParse(_montantController.text.trim()) ?? 0.0;
    final paye = double.tryParse(_montantPayeController.text.trim()) ?? 0.0;

    if (date.isEmpty || montant <= 0) {
      Get.snackbar('Erreur', 'Champs invalides', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final detteData = {
      'date': date,
      'montantDette': montant,
      'montantPaye': paye,
    };

    final success = await _clientController.ajouterDette(widget.client.id, detteData);

    if (success) {
      Get.back();
      Get.snackbar('Succès', 'Dette ajoutée', snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Erreur', 'Échec de l\'ajout', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = _clientController.clients.firstWhere(
      (c) => c.id == widget.client.id,
      orElse: () => widget.client,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de ${client.nom}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter une dette',
            onPressed: _showAddDetteDialog,
          ),
        ],
      ),
      body: client.dettes.isEmpty
          ? const Center(child: Text("Aucune dette enregistrée."))
          : ListView.builder(
              itemCount: client.dettes.length,
              itemBuilder: (context, index) {
                final dette = client.dettes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    title: Text('Dette du ${dette.date}'),
                    subtitle: Text(
                      'Montant: ${dette.montantDette} | Payé: ${dette.montantPaye} | Restant: ${dette.montantRestant}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
