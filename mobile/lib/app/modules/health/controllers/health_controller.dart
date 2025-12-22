import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:image_picker/image_picker.dart';
import 'package:mobile/data/models/health_report_model.dart';
import 'package:mobile/data/services/dio_service.dart';
import 'package:mobile/app/routes/app_routes.dart';
import 'package:http_parser/http_parser.dart';

class HealthController extends GetxController {
  final dio = Get.find<DioService>().client;
  final box = GetStorage();
  final ImagePicker _picker = ImagePicker();

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

  // Kamera/Galeri Seçimi İçin Popup
  void showImageSourceSelection() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        uploadReport(File(image.path));
      }
    } catch (e) {
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          content: Text("Resim seçilemedi: $e"),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  Future<void> uploadReport(File file) async {
    // 1. Dosya Boyutu Kontrolü (5MB = 5 * 1024 * 1024 bytes)
    int sizeInBytes = await file.length();
    if (sizeInBytes > 5 * 1024 * 1024) {
      Get.snackbar("Hata",
          "Dosya boyutu çok yüksek! Lütfen 5MB'dan küçük bir dosya seçin.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isAnalyzing.value = true;

    // Loading Dialog Göster (Kapatılamaz)
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 20),
                Text(
                  "Tahliliniz Yapay Zeka Tarafından Analiz Ediliyor...",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final user = box.read('user');
      final userId = user['_id'];
      String fileName = file.path.split('/').last;

      // Sadece resim varsayımı
      var contentType = MediaType('image', 'jpeg');
      String extension = fileName.split('.').last.toLowerCase();
      if (extension == 'png') {
        contentType = MediaType('image', 'png');
      }

      dio_pkg.FormData formData = dio_pkg.FormData.fromMap({
        "userId": userId,
        "file": await dio_pkg.MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: contentType,
        ),
      });

      // 2. Zaman Aşımı Ayarları (90 Saniye)
      final response = await dio.post(
        '/health/analyze',
        data: formData,
        options: dio_pkg.Options(
          sendTimeout: const Duration(seconds: 90),
          receiveTimeout: const Duration(seconds: 90),
        ),
      );

      // Dialogu kapat ve bekle (Overlay temizliği için)
      if (Get.isDialogOpen ?? false) {
        Get.back();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (response.statusCode == 200 && response.data['success'] == true) {
        var reportData = response.data['data'];
        currentResult.value = HealthReportModel.fromJson(reportData);
        fetchHistory();

        // Başarılı olursa direkt yönlendir
        Get.toNamed(Routes.HEALTH_RESULT, arguments: reportData);
      }
    } catch (e) {
      // Hata durumunda ÖNCE dialogu kapat ve bekle
      if (Get.isDialogOpen ?? false) {
        Get.back();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      print("Analysis Error: $e");

      String errorMessage = "Analiz yapılamadı.";

      if (e is dio_pkg.DioException) {
        if (e.type == dio_pkg.DioExceptionType.sendTimeout ||
            e.type == dio_pkg.DioExceptionType.receiveTimeout) {
          errorMessage = "Sunucu yanıt vermiyor. Zaman aşımına uğradı (90sn).";
        } else if (e.response != null) {
          if (e.response!.data is Map && e.response!.data['message'] != null) {
            errorMessage = "Hata: ${e.response!.data['message']}";
          } else if (e.response!.statusCode == 500) {
            errorMessage = "Tahlil analiz edilemedi. Lütfen tekrar deneyin.";
          } else {
            errorMessage = "Sunucu Hatası: ${e.response!.statusCode}";
          }
        } else {
          errorMessage = "Bağlantı hatası: ${e.message}";
        }
      } else {
        errorMessage = "Beklenmeyen hata: $e";
      }

      // Güvenli Snackbar
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ));
      }
    } finally {
      // Yükleme ekranını kapat (Eğer hala açıksa)
      if (Get.isDialogOpen ?? false) {
        Get.back();
        await Future.delayed(const Duration(milliseconds: 100));
      }
      isAnalyzing.value = false;
    }
  }
}
