import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/client_controller.dart';
import '../controllers/auth_controller.dart';
import 'client_detail_page.dart';
import 'login_page.dart';
import 'dashboard_page.dart';  // Pour la navigation vers l'accueil (DashboardPage)

class ClientListPage extends StatefulWidget {
  @override
  State<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {
  final ClientController clientController = Get.put(ClientController());
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController _searchController = TextEditingController();
  RxString _searchTerm = ''.obs;

  int _currentIndex = 0; // Clients = 0, Accueil = 1, Dettes = 2

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      _searchTerm.value = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      // Clients - on est déjà sur cette page, rien à faire
    } else if (index == 1) {
      // Accueil
      Get.off(() => DashboardPage());
    } else if (index == 2) {
      Get.snackbar('Info', 'Page liste des dettes à implémenter', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Clients'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () {
              authController.logout();
              Get.offAll(() => LoginPage());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher par nom',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: Obx(() => _searchTerm.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : SizedBox.shrink()),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (clientController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              } else if (clientController.errorMessage.isNotEmpty) {
                return Center(child: Text(clientController.errorMessage.value));
              } else {
                final filteredClients = clientController.clients.where((client) {
                  return client.nom.toLowerCase().contains(_searchTerm.value);
                }).toList();

                if (filteredClients.isEmpty) {
                  return Center(child: Text('Aucun client trouvé'));
                }

                return ListView.builder(
                  itemCount: filteredClients.length,
                  itemBuilder: (context, index) {
                    final client = filteredClients[index];
                    return ListTile(
                      title: Text(client.nom),
                      subtitle: Text('${client.telephone} - ${client.adresse}'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Get.to(() => ClientDetailPage(client: client));
                      },
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
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
        onTap: _onBottomNavTapped,
      ),
    );
  }
}
