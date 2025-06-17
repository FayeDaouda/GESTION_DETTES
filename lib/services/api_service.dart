import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  // Récupérer la liste des clients
  Future<List<Client>> fetchClients() async {
    final response = await http.get(Uri.parse('$baseUrl/clients'));

    if (response.statusCode == 200) {
      final List<dynamic> clientsJson = json.decode(response.body);
      return clientsJson.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des clients');
    }
  }

  // Ajouter une dette à un client (clientId est maintenant une String)
  Future<bool> addDetteToClient(String clientId, Map<String, dynamic> detteData) async {
    final clientResponse = await http.get(Uri.parse('$baseUrl/clients/$clientId'));
    if (clientResponse.statusCode != 200) {
      throw Exception('Client non trouvé');
    }

    Map<String, dynamic> clientJson = json.decode(clientResponse.body);

    List<dynamic> dettes = clientJson['dettes'] ?? [];

    // Si tu veux générer un id pour la dette, décommente cette partie
    /*
    int newDetteId = dettes.isNotEmpty
        ? (dettes.map((d) => d['id'] as int).reduce((a, b) => a > b ? a : b) + 1)
        : 1;
    detteData['id'] = newDetteId;
    */

    dettes.add(detteData);
    clientJson['dettes'] = dettes;

    final putResponse = await http.put(
      Uri.parse('$baseUrl/clients/$clientId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(clientJson),
    );

    return putResponse.statusCode == 200;
  }

  // Ajouter un client (POST)
  Future<Client> ajouterClient(Client client) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "nom": client.nom,
        "telephone": client.telephone,
        "adresse": client.adresse,
        "dettes": client.dettes.map((d) => d.toJson()).toList(),
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonClient = json.decode(response.body);
      return Client.fromJson(jsonClient);
    } else {
      throw Exception('Erreur lors de l\'ajout du client');
    }
  }
}
