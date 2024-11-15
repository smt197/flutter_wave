import 'package:flutter/material.dart';
import '../services/apiInterface.dart';

abstract class ProviderInterface with ChangeNotifier {
  Map<String, dynamic>? get user;
  bool get isLoading;
  String? get errorMessage;
  bool get isAuthenticated;
  ApiInterface get apiService;

  Future<void> checkIfUserIsAuthenticated();
  Future<void> login(String email, String password);
  Future<void> register(Map<String, dynamic> data);
  Future<void> loadUserFromStorage();
  Future<void> logout();

  Future<List<dynamic>> get transactions;
  Future<Map<String, dynamic>> get balanceData;

}