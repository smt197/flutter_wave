abstract class StorageService {
  Future<void> saveData(String key, String value);
  Future<String?> getData(String key);
  void setAuthToken(String token);
  Future<void> removeData(String key);
}
