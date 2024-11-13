abstract class ApiInterface {
  Future<Map<String, dynamic>?> login(String email, String password);
  Future<Map<String, dynamic>?> register(Map<String, dynamic> data);
  Future<List<dynamic>> getTransactions();
  Future<Map<String, dynamic>> getBalanceData();
}