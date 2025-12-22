import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  final _box = GetStorage();

  Future<StorageService> init() async {
    await GetStorage.init();
    return this;
  }

  // Token
  String? getToken() => _box.read('token');
  Future<void> saveToken(String token) => _box.write('token', token);
  Future<void> removeToken() => _box.remove('token');

  // User
  Map<String, dynamic>? getUser() => _box.read('user');
  Future<void> saveUser(Map<String, dynamic> user) => _box.write('user', user);
}
