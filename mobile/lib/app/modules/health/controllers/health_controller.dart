import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:file_picker/file_picker.dart';
import 'package:mobile/data/models/health_report_model.dart';
import 'package:mobile/data/services/dio_service.dart';
import 'package:mobile/app/routes/app_routes.dart';
import 'package:http_parser/http_parser.dart'; // Import added for MediaType

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
    // Show Loading Overlay
    Get.dialog(
      const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text("Yapay Zeka Raporunu İnceliyor...",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    decoration: TextDecoration.none)),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final user = box.read('user');
      final userId = user['_id'];

      String fileName = file.path.split('/').last;

      // Dynamic ContentType Logic
      MediaType? mediaType;
      final ext = fileName.split('.').last.toLowerCase();
      if (ext == 'pdf') {
        mediaType = MediaType('application', 'pdf');
      } else if (['jpg', 'jpeg'].contains(ext)) {
        mediaType = MediaType('image', 'jpeg');
      } else if (ext == 'png') {
        mediaType = MediaType('image', 'png');
      } else {
        mediaType =
            MediaType('application', 'octet-stream'); // Default fallback
      }

      dio_pkg.FormData formData = dio_pkg.FormData.fromMap({
        "userId": userId,
        "file": await dio_pkg.MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: mediaType,
        ),
      });

      print("SENDING HEALTH REQUEST (MIME: $mediaType)...");
      final response = await dio.post('/health/analyze', data: formData);

      // Close Loading Dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (response.statusCode == 200) {
        var responseData = response.data;
        print("HEALTH RESPONSE TYPE: ${responseData.runtimeType}");
        print("HEALTH RESPONSE DATA: $responseData");

        // Handle List vs Map
        if (responseData is List) {
          print("Response is LIST. Taking first element.");
          if (responseData.isNotEmpty) {
            currentResult.value =
                HealthReportModel.fromJson(responseData.first);
          }
        } else if (responseData is Map) {
          print("Response is MAP. Parsing directly.");
          currentResult.value = HealthReportModel.fromJson(
              Map<String, dynamic>.from(responseData));
        } else {
          print("UNKNOWN RESPONSE FORMAT");
        }

        fetchHistory(); // Refresh history

        // Go to Result Page
        Get.toNamed(Routes.HEALTH_RESULT);
      }
    } on dio_pkg.DioException catch (e) {
      // Close Loading Dialog if open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      print("DIO CRITICAL ERROR: ${e.message}");
      if (e.response != null) {
        print("BACKEND ERROR DATA: ${e.response?.data}");
        print("BACKEND STATUS CODE: ${e.response?.statusCode}");
      }

      Get.snackbar("Analiz Hatası",
          "Sunucu tarafında bir sorun oluştu.\nDetay: ${e.response?.data?['message'] ?? e.message}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5));
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      print("UNKNOWN ERROR: $e");
      Get.snackbar("Hata", "Beklenmeyen bir hata: $e");
    } finally {
      isAnalyzing.value = false;
    }
  }
}
