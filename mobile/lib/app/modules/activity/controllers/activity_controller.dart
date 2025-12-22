import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:intl/intl.dart';
import '../../home/controllers/home_controller.dart';
import '../../diary/controllers/diary_controller.dart';

class ActivityController extends GetxController {
  final dio = dio_pkg.Dio(dio_pkg.BaseOptions(
    baseUrl: 'http://10.0.2.2:5000/api',
  ));
  final box = GetStorage();

  final isLoading = false.obs;

  // From UI
  final selectedActivityType = 'Yürüyüş'.obs;
  final durationController = TextEditingController();

  final activityTypes = [
    'Koşu',
    'Yüzme',
    'Bisiklet',
    'Fitness',
    'Futbol',
    'Basketbol',
    'Tenis',
    'Voleybol',
    'Dans',
    'Yürüyüş'
  ];

  Future<void> saveActivity() async {
    if (durationController.text.isEmpty) {
      Get.snackbar("Hata", "Lütfen süreyi giriniz.");
      return;
    }

    isLoading.value = true;
    try {
      final user = box.read('user');
      final userId = user['_id'];
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final duration = int.parse(durationController.text);

      final activityData = {
        'userId': userId,
        'date': date,
        'activity': {
          'isim': selectedActivityType.value
              .toLowerCase(), // Backend ile uyum için küçük harf
          'sure_dk': duration
        }
      };

      print('SEÇİLEN AKTİVİTE: ${selectedActivityType.value}');
      print('GÖNDERİLEN VERİ (Lowercase): $activityData');

      final response = await dio.post('/activity/add', data: activityData);

      if (response.statusCode == 200) {
        // 1. Önce sayfayı kapat
        Get.back();

        // 2. Sayfanın kapanmasını bekle (User Request)
        await Future.delayed(const Duration(milliseconds: 300));

        // 3. Bildirimi göster
        // 3. Bildirimi göster (ScaffoldMessenger - Native)
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text("Harika İş! 🔥 Aktivite başarıyla eklendi."),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );

        // Dashboard'u yenile
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchTodayLog();
        }

        // Günlük Geçmişi yenile
        if (Get.isRegistered<DiaryController>()) {
          Get.find<DiaryController>().fetchDailyLog();
        }
      }
    } catch (e) {
      print("ACTIVITY ADD ERROR: $e");
      Get.snackbar("Hata", "Aktivite eklenemedi: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
