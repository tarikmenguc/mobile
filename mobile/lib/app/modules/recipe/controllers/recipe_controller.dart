import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_pkg;
import '../../../../core/constants/api_endpoints.dart';
import 'package:get_storage/get_storage.dart';
import '../../home/controllers/home_controller.dart';
import '../../../routes/app_routes.dart';

class RecipeController extends GetxController {
  final dio = dio_pkg.Dio(dio_pkg.BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: const Duration(seconds: 40),
    receiveTimeout: const Duration(seconds: 40),
  ));
  final box = GetStorage();

  final ingredientsController = TextEditingController();
  final isLoading = false.obs;

  // Recipe Result
  final generatedRecipe = <String, dynamic>{}.obs;

  @override
  void onClose() {
    ingredientsController.dispose();
    super.onClose();
  }

  Future<void> generateRecipe() async {
    final ingredients = ingredientsController.text.trim();
    if (ingredients.isEmpty) {
      if (Get.context != null) {
        Get.snackbar("Eksik Bilgi", "Lütfen elinizdeki malzemeleri giriniz.");
      }
      return;
    }

    // Virgülle ayrılmış string'i listeye çevir
    final ingredientsList =
        ingredients.split(',').map((e) => e.trim()).toList();

    isLoading.value = true;
    try {
      final user = box.read('user');
      final userId = user['_id'];

      print("GENERATING RECIPE FOR: $ingredientsList");

      final response = await dio.post('/recipes/generate',
          data: {'userId': userId, 'ingredients': ingredientsList});

      if (response.statusCode == 200 && response.data['success'] == true) {
        generatedRecipe.value = response.data['data'];
      } else {
        if (Get.context != null) Get.snackbar("Hata", "Tarif üretilemedi.");
      }
    } on dio_pkg.DioException catch (e) {
      print("RECIPE DIO ERROR: ${e.message}");
      print("DATA: ${e.response?.data}");

      // Close keyboard to prevent overlay conflicts
      FocusManager.instance.primaryFocus?.unfocus();
      await Future.delayed(const Duration(milliseconds: 500));

      if (Get.context != null) {
        try {
          Get.snackbar("Hata",
              "Tarif üretilemedi: ${e.response?.data['message'] ?? e.message}",
              snackPosition: SnackPosition.BOTTOM);
        } catch (_) {
          print("Could not show snackbar.");
        }
      }
    } catch (e) {
      print("RECIPE ERROR: $e");
      // Fallback
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addRecipeToLog() async {
    if (generatedRecipe.isEmpty) return;

    isLoading.value = true;
    try {
      final user = box.read('user');
      final userId = user['_id'];
      final date = DateTime.now().toIso8601String().split('T')[0];

      final foodData = {
        'isim': generatedRecipe['tarif_adi'],
        'kalori': generatedRecipe['kalori'],
        'makrolar': generatedRecipe['makrolar'],
        'miktar': '1 Porsiyon',
        'kaynak': 'ai-recipe'
      };

      await dio.post('/food/confirm',
          data: {'userId': userId, 'date': date, 'food': foodData});

      Get.find<HomeController>().fetchTodayLog();
      Get.offAllNamed(Routes.ROOT);
      if (Get.context != null) {
        Get.snackbar("Leziz!", "Tarif günlüğe eklendi. Afiyet olsun! 👨‍🍳");
      }
    } catch (e) {
      print("ADD RECIPE ERROR: $e");
      if (Get.context != null) Get.snackbar("Hata", "Günlüğe eklenemedi.");
    } finally {
      isLoading.value = false;
    }
  }
}
