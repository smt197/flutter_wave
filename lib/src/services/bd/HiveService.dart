// import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'StorageService.dart';

class HiveService implements StorageService {
  static const String _authTokenKey = 'auth_token';

  Future<Box> _getBox() async {
    Hive.initFlutter();
    return await Hive.openBox('app_data');
  }

  @override
  Future<void> saveData(String key, String value) async {
    final box = await _getBox();
    await box.put(key, value);
  }

  @override
  Future<String?> getData(String key) async {
    final box = await _getBox();
    return box.get(key);
  }

  // @override
  Future<String?> getAuthToken() async {
    final box = await _getBox();
    return box.get(_authTokenKey);
  }

  @override
  Future<void> setAuthToken(String token) async {
    final box = await _getBox();
    await box.put(_authTokenKey, token);
  }

  @override
  Future<void> removeData(String key) async {
    final box = await _getBox();
    await box.delete(key);
  }
}