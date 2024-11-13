import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/bd/SharedPreferencesService.dart';

class TransactionService {
  Future<List<dynamic>> getTransactions() async {
    final token = await SharedPreferencesService().getAuthToken();

    if (token == null) {
      throw Exception('Utilisateur non authentifié');
    }

    final response = await http.get(
      Uri.parse('http://192.168.6.44:8000/api/v1/transactions'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Si la requête est réussie, retourner les transactions
      final Map<String, dynamic> data = json.decode(response.body);
      return data['transactions'];
    } else {
      // Si la requête échoue, lancer une exception
      throw Exception('Erreur lors de la récupération des transactions');
    }
  }

  Future<Map<String, dynamic>> getBalanceData() async {
    final token = await SharedPreferencesService().getAuthToken();

    if (token == null) {
      throw Exception('Utilisateur non authentifié');
    }

    final response = await http.get(
      Uri.parse('http://192.168.6.44:8000/api/v1/client/balance'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Échec du chargement des données');
    }
  }

  
}
