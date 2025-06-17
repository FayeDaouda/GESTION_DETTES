import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/client_controller.dart';
import '../models/client.dart';
import 'client_list_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  final ClientController clientController = Get.find<ClientController>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _nomController = TextEditingController();
  final _telController = TextEditingController();
  final _adresseController = TextEditingController();

  int _currentIndex = 1; // Accueil par défaut

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    if (clientController.clients.isNotEmpty) {
      _animationController.value = 1.0;
    } else {
      ever<List<Client>>(clientController.clients, (clients) {
        if (clients.isNotEmpty) {
          _animationController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nomController.dispose();
    _telController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String value,
    Color? color,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: color ?? Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 11),
          child: SizedBox(
            width: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 36, color: Colors.blueAccent),
                const SizedBox(height: 8),
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddClientForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _nomController,
          decoration: const InputDecoration(labelText: 'Nom'),
        ),
        TextField(
          controller: _telController,
          decoration: const InputDecoration(labelText: 'Téléphone'),
          keyboardType: TextInputType.phone,
        ),
        TextField(
          controller: _adresseController,
          decoration: const InputDecoration(labelText: 'Adresse'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            final nom = _nomController.text.trim();
            final tel = _telController.text.trim();
            final adresse = _adresseController.text.trim();

            if (nom.isEmpty || tel.isEmpty || adresse.isEmpty) {
              Get.snackbar('Erreur', 'Tous les champs sont obligatoires',
                  snackPosition: SnackPosition.BOTTOM);
              return;
            }

            final newId = DateTime.now().millisecondsSinceEpoch.toString();

            clientController.ajouterClient(
              Client(
                id: newId,
                nom: nom,
                telephone: tel,
                adresse: adresse,
                dettes: [],
              ),
            );

            _nomController.clear();
            _telController.clear();
            _adresseController.clear();

            Get.back();
            Get.snackbar('Succès', 'Client ajouté', snackPosition: SnackPosition.BOTTOM);
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }

  void _showAddDetteDialog(Client client) {
    final dateController = TextEditingController();
    final montantController = TextEditingController();
    final montantPayeController = TextEditingController();

    Get.defaultDialog(
      title: 'Ajouter une dette à ${client.nom}',
      content: Column(
        children: [
          TextField(
            controller: dateController,
            decoration: const InputDecoration(labelText: 'Date (ex: 2025-06-17)'),
          ),
          TextField(
            controller: montantController,
            decoration: const InputDecoration(labelText: 'Montant dette'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: montantPayeController,
            decoration: const InputDecoration(labelText: 'Montant payé'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final date = dateController.text.trim();
              final montant = double.tryParse(montantController.text.trim()) ?? 0.0;
              final paye = double.tryParse(montantPayeController.text.trim()) ?? 0.0;

              if (date.isEmpty || montant <= 0) {
                Get.snackbar('Erreur', 'Champs invalides', snackPosition: SnackPosition.BOTTOM);
                return;
              }

              final dette = {
                'date': date,
                'montantDette': montant,
                'montantPaye': paye,
                'paiements': [],
              };

              final success = await clientController.ajouterDette(client.id, dette);
              if (success) {
                Get.back();
                Get.snackbar('Succès', 'Dette ajoutée', snackPosition: SnackPosition.BOTTOM);
              } else {
                Get.snackbar('Erreur', 'Échec de l\'ajout', snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: const Text('Ajouter'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (clientController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (clientController.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              clientController.errorMessage.value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else {
          final clients = clientController.clients;

          final totalClients = clients.length;
          final totalDettes = clients.fold<int>(
            0,
            (sum, c) => sum + c.dettes.length,
          );
          final totalMontantRestant = clients.fold<double>(
            0.0,
            (sum, c) =>
                sum + c.dettes.fold(0.0, (sumDettes, d) => sumDettes + d.montantRestant),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un client'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Get.defaultDialog(
                          title: 'Ajouter un client',
                          content: _buildAddClientForm(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          _buildCard(
                            icon: Icons.people,
                            title: 'Clients',
                            value: '$totalClients',
                            color: Colors.lightBlue.shade50,
                          ),
                          const SizedBox(width: 16),
                          _buildCard(
                            icon: Icons.receipt_long,
                            title: 'Dettes',
                            value: '$totalDettes',
                            color: Colors.orange.shade50,
                          ),
                          const SizedBox(width: 16),
                          _buildCard(
                            icon: Icons.attach_money,
                            title: 'Restant dû',
                            value: '${totalMontantRestant.toStringAsFixed(0)} FCFA',
                            color: Colors.green.shade50,
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.list),
                      label: const Text('Voir la liste des clients'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Get.to(() => ClientListPage());
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text('Liste des clients:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final c = clients[index];
                    return Card(
                      child: ListTile(
                        title: Text(c.nom),
                        subtitle: Text('Téléphone: ${c.telephone}'),
                        trailing: ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Dette'),
                          onPressed: () => _showAddDetteDialog(c),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      }),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Dettes',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);

          if (index == 0) {
            Get.to(() => ClientListPage());
          } else if (index == 1) {
            // Accueil - déjà ici, rien à faire
          } else if (index == 2) {
            Get.snackbar(
              'Info',
              'Page liste des dettes à implémenter',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
      ),
    );
  }
}
