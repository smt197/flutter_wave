import '../services/bd/SharedPreferencesService.dart';
import 'package:dio/dio.dart';
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

class DioApiService implements ApiInterface {
  final String baseUrl = "http://192.168.6.44:8000";
  final Dio _dio = Dio();

  @override
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio
          .post(
            '$baseUrl/api/v1/users/login',
            data: {'email': email, 'password': password},
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'accept': 'application/json',
              },
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        final message =
            response.data['message'] ?? 'Erreur inconnue lors de la connexion';
        throw Exception(message);
      }
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> register(Map<String, dynamic> data) async {
    try {
      final response = await _dio
          .post(
            '$baseUrl/api/v1/clients/store',
            data: data,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'accept': 'application/json',
              },
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        if (response.data != null && response.data['data'] != null) {
          return response.data['data'] as Map<String, dynamic>;
        } else {
          throw Exception('Données utilisateur manquantes');
        }
      } else {
        final message = response.data['message'] ??
            'Erreur inconnue lors de l\'inscription';
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

    final response = await _dio.get(
      '$baseUrl/api/v1/transactions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data['transactions'];
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

    final response = await _dio.get(
      '$baseUrl/api/v1/client/balance',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
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

    final response = await _dio.post(
      '$baseUrl/api/v1/transactions/deposit',
      data: depositData,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception(response.data['message'] ?? 'Erreur lors du dépôt');
    }
  }

  Future<Map<String, dynamic>> sendTransferRequest(
      String phone, String amount) async {
    final token = await SharedPreferencesService().getAuthToken();
    if (token == null) {
      throw Exception('Aucun token d\'authentification');
    }

    final response = await _dio.post(
      '$baseUrl/api/v1/transactions/transfer',
      data: {
        'receiverPhone': phone,
        'amount': amount,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception(response.data['message'] ?? 'Erreur lors du transfert');
    }
  }
}
