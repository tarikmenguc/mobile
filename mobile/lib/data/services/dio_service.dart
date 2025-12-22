import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/constants/api_endpoints.dart';
import 'storage_service.dart';

class DioService extends GetxService {
  late Dio _dio;
  final StorageService _storageService = Get.find<StorageService>();

  Future<DioService> init() async {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add Token if exists
        final token = _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print("REQUEST [${options.method}] => PATH: ${options.path}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("RESPONSE [${response.statusCode}] => DATA: ${response.data}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print("ERROR [${e.response?.statusCode}] => MSG: ${e.message}");
        return handler.next(e);
      },
    ));

    return this;
  }

  Dio get client => _dio;
}
