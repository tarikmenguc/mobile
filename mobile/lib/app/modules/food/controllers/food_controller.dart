import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../routes/app_routes.dart';

class FoodController extends GetxController {
  final dio = dio_pkg.Dio(dio_pkg.BaseOptions(
    baseUrl: 'http://10.0.2.2:5000/api',
    connectTimeout: const Duration(seconds: 30), // AI takes time
    receiveTimeout: const Duration(seconds: 30),
  ));
  final box = GetStorage();
  final picker = ImagePicker();

  final isLoading = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);

  // Analysis Result
  final analyzedFood = <String, dynamic>{}.obs;

  Future<void> pickImage(ImageSource source) async {
    print("------------------------------------------------");
    print("PICK IMAGE REQUESTED: $source");

    // 1. Request Permission
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      // For Gallery (Android 13+ sets different permissions, but photos is general)
      // On Android 13+, READ_MEDIA_IMAGES is needed. Permission.photos handles logical mapping often,
      // but let's be explicit or safe.
      status = await Permission.storage.request();
      if (status.isDenied) {
        // Try media images for Android 13
        status = await Permission.photos.request();
      }
    }

    print("PERMISSION STATUS: $status");

    if (status.isPermanentlyDenied) {
      Get.snackbar('İzin Gerekli', 'Lütfen ayarlardan izin verin.');
      openAppSettings();
      return;
    }

    // 2. Pick Image
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        print("PICK IMAGE SUCCESS: ${pickedFile.path}");
        selectedImage.value = File(pickedFile.path);
        // Auto-analyze as per prompt
        analyzeImage();
      } else {
        print("PICK IMAGE CANCELLED (User didn't select)");
      }
    } catch (e) {
      print("PICK IMAGE ERROR: $e");
      Get.snackbar('Hata', 'Fotoğraf seçilemedi: $e');
    }
  }

  Future<void> analyzeImage() async {
    if (selectedImage.value == null) {
      print("ANALYZE ABORTED: No image selected");
      return;
    }

    print("STARTING ANALYSIS...");
    isLoading.value = true;
    try {
      String fileName = selectedImage.value!.path.split('/').last;
      print("FILE NAME: $fileName");

      dio_pkg.FormData formData = dio_pkg.FormData.fromMap({
        "image": await dio_pkg.MultipartFile.fromFile(
          selectedImage.value!.path,
          filename: fileName,
        ),
      });

      print("SENDING TO BACKEND (/food/analyze)...");
      final response = await dio.post('/food/analyze', data: formData);
      print("BACKEND RESPONSE CODE: ${response.statusCode}");
      print("BACKEND RESPONSE DATA: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        print("ANALYSIS SUCCESS! Mapping data...");
        analyzedFood.value = response.data['data'];

        // Navigate to Confirmation Screen
        Get.toNamed(Routes.AI_ANALYSIS);
      } else {
        print("ANALYSIS FAILED: ${response.data}");
        Get.snackbar("Hata", "Analiz başarısız oldu.");
      }
    } on dio_pkg.DioException catch (e) {
      print("DIO ERROR: ${e.message}");
      print("DIO RESPONSE: ${e.response?.data}");
      Get.snackbar('Hata', 'AI Analizi başarısız: ${e.message}');
    } catch (e) {
      print("UNKNOWN ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmFood() async {
    isLoading.value = true;
    try {
      final user = box.read('user');
      final userId = user['_id'];
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final List<dynamic> foods = analyzedFood['yemekler'] ?? [];

      // Loop through all items and save them
      for (var item in foods) {
        final foodData = {
          'isim': item['isim'] ?? 'Bilinmeyen Yemek',
          'kalori': item['kalori'] ?? 0,
          'makrolar': item['makrolar'] ?? {},
          'miktar': item['miktar'] ?? '1 Porsiyon',
          'kaynak': 'ai'
        };

        // Send to Backend
        await dio.post('/food/confirm',
            data: {'userId': userId, 'date': date, 'food': foodData});
      }

      Get.offAllNamed(Routes.HOME);
      Get.snackbar("Başarılı", "${foods.length} besin günlüğe eklendi! 🥗");
    } catch (e) {
      print("CONFIRM ERROR: $e");
      Get.snackbar('Hata', 'Kayıt başarısız: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
