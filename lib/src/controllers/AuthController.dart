import 'dart:convert';
import 'package:get/get.dart';
import '../services/apiInterface.dart';
import '../services/bd/StorageService.dart';
import '../../utils/constants.dart';

class AuthController extends GetxController  {
  final ApiInterface _apiService;
  final StorageService _storageService;

  AuthController(this._apiService, this._storageService);

  // Variables d'état
  var user = Rxn<Map<String, dynamic>>();
  var isLoading = false.obs;
  var errorMessage = RxnString();

  // Transactions et balance en tant que variables observables
  late final Future<List<dynamic>> transactions;
  late final Future<Map<String, dynamic>> balanceData;

  @override
  void onInit() {
    super.onInit();
    transactions = _apiService.getTransactions();
    balanceData = _apiService.getBalanceData();
    checkIfUserIsAuthenticated();
  }

  bool get isAuthenticated => user.value != null;

  Future<void> checkIfUserIsAuthenticated() async {
    final userData = await _storageService.getData(Constants.userDataKey);
    if (userData != null) {
      user.value = jsonDecode(userData);
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await _apiService.login(email, password);
      if (response != null) {
        final token = response[Constants.authTokenKey] as String;
        await _storageService.saveData(Constants.authTokenKey, token);

        final refreshToken = response[Constants.refreshTokenKey] as String;
        await _storageService.saveData(Constants.refreshTokenKey, refreshToken);

        user.value = response[Constants.userDataKey] as Map<String, dynamic>;
        await _storageService.saveData(Constants.userDataKey, jsonEncode(user.value));
      }
    } catch (e) {
      errorMessage.value = e.toString();
      user.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final responseData = await _apiService.register(data);
      if (responseData != null && responseData['status'] == 'ECHEC') {
        final errors = responseData['data'] as Map<String, dynamic>;
        errorMessage.value = errors.entries.map((e) => "${e.key}: ${e.value.join(", ")}").join("\n");
        user.value = null;
      } else {
        user.value = responseData?['data'];
      }
    } catch (e) {
      errorMessage.value = e.toString();
      user.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserFromStorage() async {
    final userData = await _storageService.getData(Constants.userDataKey);
    if (userData != null) {
      user.value = jsonDecode(userData);
    } else {
      user.value = null;
    }
  }

  Future<void> logout() async {
    user.value = null;
    errorMessage.value = null;
    await _storageService.removeData('user');
    await _storageService.removeData('token');
    await _storageService.removeData('refresh_token');
  }
}
