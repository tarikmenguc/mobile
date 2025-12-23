import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:intl/intl.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../routes/app_routes.dart';
import '../../home/controllers/home_controller.dart';

class ActivityController extends GetxController {
  final dio = dio_pkg.Dio(dio_pkg.BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
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
      final duration = int.parse(durationController.text);
      final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final activityData = {
        'userId': userId,
        'activityName': selectedActivityType.value,
        'duration': duration,
        'date': todayDate
      };

      final response = await dio.post('/activity/add', data: activityData);

      if (response.statusCode == 200) {
        // Refresh Home UI to show new calories
        try {
          Get.find<HomeController>().fetchTodayLog();
        } catch (e) {
          print("Home Refresh Error: $e");
        }

        // İŞLEM TAMAMLANDI: Ana İskelete Dön (Bottom Bar)
        Get.offAllNamed(Routes.ROOT);
        Get.snackbar("Başarılı", "Aktivite eklendi! 💪");
      }
    } catch (e) {
      print("ACTIVITY ADD ERROR: $e");
      Get.snackbar("Hata", "Aktivite eklenemedi.");
    } finally {
      isLoading.value = false;
    }
  }
}
