import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_wave/src/providers/providerInterface.dart';
import '../services/apiInterface.dart';
import '../services/bd/StorageService.dart';
import '../../utils/constants.dart';

class AuthProvider with ChangeNotifier implements ProviderInterface {
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _errorMessage;
  final ApiInterface _apiService;
  final StorageService _storageService;

  @override
  late final Future<List<dynamic>> transactions;
  @override
  late final Future<Map<String, dynamic>> balanceData;

  AuthProvider(this._apiService, this._storageService) {
    transactions = _apiService.getTransactions();
    balanceData = _apiService.getBalanceData();
  }

  @override
  Map<String, dynamic>? get user => _user;
  @override
  bool get isLoading => _isLoading;
  @override
  String? get errorMessage => _errorMessage;
  @override
  bool get isAuthenticated => _user != null;

  @override
  ApiInterface get apiService => _apiService;


  @override
  Future<void> checkIfUserIsAuthenticated() async {
    final userData = await _storageService.getData(Constants.userDataKey);
    if (userData != null) {
      _user = jsonDecode(userData);
      notifyListeners();
    }
  }

  @override
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Récupérer la réponse complète du service d'API
      final response = await _apiService.login(email, password);
      if (response != null) {
        // Sauvegarder le token
        final token = response[Constants.authTokenKey] as String;
        await _storageService.saveData(Constants.authTokenKey, token);

        // Sauvegarder le refresh token si nécessaire
        final refreshToken = response[Constants.refreshTokenKey] as String;
        await _storageService.saveData(Constants.refreshTokenKey, refreshToken);

        // Sauvegarder les données utilisateur
        _user = response[Constants.userDataKey] as Map<String, dynamic>;
        await _storageService.saveData(Constants.userDataKey, jsonEncode(_user));
      }
    } catch (e) {
      _errorMessage = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> register(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responseData = await _apiService.register(data);
      if (responseData != null && responseData['status'] == 'ECHEC') {
        // En cas d'échec, extraire les messages d'erreur
        final errors = responseData['data'] as Map<String, dynamic>;
        _errorMessage = errors.entries.map((e) => "${e.key}: ${e.value.join(", ")}").join("\n");
        print('Erreur lors de l\'inscription : $_errorMessage');
        _user = null; // Ne pas définir d'utilisateur en cas d'échec
      } else {
        // Si succès, définir les données utilisateur
        _user = responseData?['data'];
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('Erreur lors de l\'inscription : $_errorMessage');
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> loadUserFromStorage() async {
    final userData = await _storageService.getData(Constants.userDataKey);
    if (userData != null) {
      _user = jsonDecode(userData);
      notifyListeners();
    } else {
      // Si aucune donnée utilisateur n'est trouvée, l'utilisateur est considéré comme non authentifié
      _user = null;
      notifyListeners();
    }
  }

  @override
  Future<void> logout() async {
    _user = null;
    _errorMessage = null;
    await _storageService.removeData('user');
    await _storageService.removeData('token');
    await _storageService.removeData('refresh_token');
    notifyListeners();
  }
}



