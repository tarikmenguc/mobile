import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:intl/intl.dart';

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
    'Yürüyüş',
    'Koşu',
    'Bisiklet',
    'Yüzme',
    'Fitness',
    'Yoga'
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

      // Backend Endpoint check: /activity/add
      // Assumption: Backend logic handles calorie calculation or we send raw.
      // If backend needs calories, we might need to calc locally.
      // Prompt says: "Kaydet butonuna basınca ActivityController üzerinden /api/activity/add endpointine isteği at"
      // Let's send type and duration.

      final activityData = {
        'userId': userId,
        'date': date,
        'activity': {'type': selectedActivityType.value, 'duration': duration}
      };

      final response = await dio.post('/activity/add', data: activityData);

      if (response.statusCode == 200) {
        Get.back(); // Close sheet or navigate back?
        // If opened via Sheet -> Get.back()
        // If opened via Page -> Get.back()
        Get.snackbar("Başarılı", "Aktivite eklendi! 💪");
        // Trigger Home Refresh?
        // Get.find<HomeController>().fetchTodayLog(); // If Home is alive
      }
    } catch (e) {
      print("ACTIVITY ADD ERROR: $e");
      Get.snackbar("Hata", "Aktivite eklenemedi.");
    } finally {
      isLoading.value = false;
    }
  }
}
