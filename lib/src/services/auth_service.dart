import 'dart:convert';
import 'package:http/http.dart' as http;
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

class AuthService {
  final String baseUrl = "http://192.168.6.44:8000";

Future<Map<String, dynamic>?> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/users/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(responseData);
      // Retourner la réponse complète au lieu de juste l'utilisateur
      return responseData as Map<String, dynamic>;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Erreur inconnue lors de la connexion';
      throw Exception(message);
    }
  } catch (error) {
    rethrow;
  }
}

Future<Map<String, dynamic>?> register(Map<String, dynamic> data) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/clients/store'),
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));
      print(response.body);


    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(responseData);

      // Vérifiez si la clé 'data' et la clé 'user' sont présentes dans la réponse
      if (responseData != null && responseData['data'] != null) {
        return responseData['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Données utilisateur manquantes');
      }
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Erreur inconnue lors de l\'inscription';
      throw Exception(message);
    }
  } catch (error) {
    rethrow; // Re-throw the error if something goes wrong
  }
}



}
