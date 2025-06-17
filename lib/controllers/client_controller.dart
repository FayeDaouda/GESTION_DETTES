import 'package:get/get.dart';
import '../models/client.dart';
import '../services/api_service.dart';

class ClientController extends GetxController {
  var clients = <Client>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    fetchClients();
  }

  void fetchClients() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final fetchedClients = await _apiService.fetchClients();
      clients.value = fetchedClients;
    } catch (e) {
      errorMessage.value = 'Erreur : ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> ajouterDette(String clientId, Map<String, dynamic> detteData) async {
  try {
    final success = await _apiService.addDetteToClient(clientId, detteData);
    if (success) {
      fetchClients();
    }
    return success;
  } catch (e) {
    errorMessage.value = 'Erreur lors de l\'ajout : ${e.toString()}';
    return false;
  }
}


  // Nouvelle version async pour ajouter un client via API et localement
  Future<void> ajouterClient(Client client) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final Client clientAjoute = await _apiService.ajouterClient(client);
      clients.add(clientAjoute);
    } catch (e) {
      errorMessage.value = 'Erreur lors de l\'ajout du client : ${e.toString()}';
      Get.snackbar('Erreur', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
