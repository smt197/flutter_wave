import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/bd/SharedPreferencesService.dart';
import '../../utils/constants.dart';
import 'apiInterface.dart';
import 'dart:io';

void disableSSLCertificateCheck() {
  HttpOverrides.global = MyHttpOverrides();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class HttpApiService implements ApiInterface {
  @override
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/${Constants.apiVersion}/users/login'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      print(response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData as Map<String, dynamic>;
      } else {
        final error = jsonDecode(response.body);
        final message =
            error['message'] ?? 'Erreur inconnue lors de la connexion';
        throw Exception(message);
      }
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> register(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/${Constants.apiVersion}/clients/store'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData != null && responseData['data'] != null) {
          return responseData['data'] as Map<String, dynamic>;
        } else {
          throw Exception('Données utilisateur manquantes');
        }
      } else {
        final error = jsonDecode(response.body);
        final message =
            error['message'] ?? 'Erreur inconnue lors de l\'inscription';
        throw Exception(message);
      }
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<dynamic>> getTransactions() async {
    final token = await SharedPreferencesService().getAuthToken();
    if (token == null) {
      throw Exception('Utilisateur non authentifié');
    }

    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/${Constants.apiVersion}/transactions'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['transactions'];
    } else {
      throw Exception('Erreur lors de la récupération des transactions');
    }
  }

  @override
  Future<Map<String, dynamic>> getBalanceData() async {
    final token = await SharedPreferencesService().getAuthToken();
    if (token == null) {
      throw Exception('Utilisateur non authentifié');
    }

    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/${Constants.apiVersion}/client/balance'),
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

  Future<Map<String, dynamic>> submitDeposit(
      String amount, String method) async {
    final token = await SharedPreferencesService().getAuthToken();

    if (token == null) {
      throw Exception('Utilisateur non authentifié');
    }

    final depositData = {
      'amount': amount,
      'method': method,
    };

    final url = Uri.parse(
        '${Constants.baseUrl}/${Constants.apiVersion}/transactions/deposit');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(depositData),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Erreur lors du dépôt');
    }
  }

  Future<Map<String, dynamic>> sendTransferRequest(
      String phone, String amount) async {

    final token = await SharedPreferencesService().getAuthToken();

    if (token == null) {
      throw Exception('Aucun token d\'authentification');
    }

    final url =
        Uri.parse('${Constants.baseUrl}/${Constants.apiVersion}/transactions/transfer');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'receiverPhone': phone,
        'amount': amount,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Erreur lors du transfert');
    }
  }
}
