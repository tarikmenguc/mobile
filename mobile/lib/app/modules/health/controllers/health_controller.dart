import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:file_picker/file_picker.dart';
import 'package:mobile/data/models/health_report_model.dart';
import 'package:mobile/data/services/dio_service.dart';
import 'package:mobile/app/routes/app_routes.dart';

class HealthController extends GetxController {
  final dio = Get.find<DioService>().client;
  final box = GetStorage();

  // History List
  var history = <HealthReportModel>[].obs;
  var isLoadingHistory = false.obs;

  // Analysis State
  var isAnalyzing = false.obs;
  var currentResult = Rxn<HealthReportModel>();

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoadingHistory.value = true;
    try {
      final user = box.read('user');
      final userId = user['_id'];

      final response =
          await dio.get('/health/history', queryParameters: {'userId': userId});

      if (response.statusCode == 200 && response.data != null) {
        final list = (response.data as List)
            .map((e) => HealthReportModel.fromJson(e))
            .toList();
        history.value = list;
      }
    } catch (e) {
      print("Health History Error: $e");
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> pickAndAnalyze() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      String path = result.files.single.path!;
      await uploadAndAnalyze(File(path));
    }
  }

  Future<void> uploadAndAnalyze(File file) async {
    isAnalyzing.value = true;

    try {
      final user = box.read('user');
      final userId = user['_id'];

      String fileName = file.path.split('/').last;

      dio_pkg.FormData formData = dio_pkg.FormData.fromMap({
        "userId": userId,
        "file":
            await dio_pkg.MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await dio.post('/health/analyze', data: formData);

      if (response.statusCode == 200) {
        currentResult.value = HealthReportModel.fromJson(response.data);
        fetchHistory(); // Refresh history

        // Go to Result Page
        Get.toNamed(Routes.HEALTH_RESULT);
      }
    } catch (e) {
      print("Analysis Error: $e");
      Get.snackbar("Hata",
          "Analiz yapılamadı. Bağlantı zaman aşımına uğramış olabilir.\nDetay: ${e.toString().substring(0, e.toString().length > 50 ? 50 : e.toString().length)}...",
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isAnalyzing.value = false;
    }
  }
}
