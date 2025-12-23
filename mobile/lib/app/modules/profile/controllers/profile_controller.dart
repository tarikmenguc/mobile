import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile/app/routes/app_routes.dart';
import 'package:mobile/data/services/dio_service.dart';
import '../../home/controllers/home_controller.dart';

class ProfileController extends GetxController {
  final box = GetStorage();
  final dio = Get.find<DioService>().client;

  var user = {}.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  void loadUser() {
    // Load from local storage initially
    final storedUser = box.read('user');
    if (storedUser != null) {
      user.value = storedUser;
    }
  }

  Future<void> updateWeight(String weightStr) async {
    if (weightStr.isEmpty) return;
    double? newWeight = double.tryParse(weightStr);
    if (newWeight == null) {
      Get.snackbar("Hata", "Geçerli bir kilo giriniz");
      return;
    }

    // Close dialog immediately after validation
    Get.back();

    try {
      isLoading.value = true;
      Get.snackbar("Güncelleniyor", "Kilo bilgisi güncelleniyor...",
          showProgressIndicator: true);

      final userId = user['_id'];

      final response = await dio
          .put('/auth/update', data: {"userId": userId, "kilo": newWeight});

      if (response.statusCode == 200) {
        // Update local storage with new user data (including new BMR/Goals)
        box.write('user', response.data);
        user.value = response.data;

        // Success Snackbar (closes previous loading snackbar implicitly)
        Get.snackbar(
            "Başarılı", "Kilo güncellendi ve hedefler yeniden hesaplandı.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3));
      }
    } catch (e) {
      print("Update Error: $e");
      Get.snackbar("Hata", "Güncelleme yapılamadı: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    Get.defaultDialog(
        title: "Çıkış Yap",
        middleText: "Hesabınızdan çıkış yapmak istediğinize emin misiniz?",
        textConfirm: "Çıkış",
        textCancel: "İptal",
        confirmTextColor: Colors.white,
        buttonColor: Colors.red,
        onConfirm: () {
          box.remove('token');
          box.remove('user');
          Get.offAllNamed(Routes.LOGIN);
        });
  }

  void showUpdateWeightDialog() {
    final TextEditingController weightCtrl = TextEditingController();
    Get.defaultDialog(
        title: "Kilo Güncelle",
        content: Column(
          children: [
            TextField(
              controller: weightCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Yeni Kilo (kg)", border: OutlineInputBorder()),
            )
          ],
        ),
        textConfirm: "Güncelle",
        textCancel: "İptal",
        confirmTextColor: Colors.white,
        onConfirm: () {
          updateWeight(weightCtrl.text);
        });
  }

  void showEditGoalDialog(String type) {
    // type: 'calorie' or 'water'
    final isCalorie = type == 'calorie';
    final TextEditingController ctrl = TextEditingController();

    Get.defaultDialog(
        title: isCalorie ? "Günlük Kalori Hedefi" : "Günlük Su Hedefi",
        content: Column(
          children: [
            Text(
              isCalorie
                  ? "Otomatik hesaplanan değeri değiştirmek istiyor musunuz?"
                  : "Günlük su hedefinizi değiştirmek istiyor musunuz?",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText:
                      isCalorie ? "Yeni Kalori (kcal)" : "Yeni Hedef (ml)",
                  border: const OutlineInputBorder()),
            )
          ],
        ),
        textConfirm: "Kaydet",
        textCancel: "İptal",
        confirmTextColor: Colors.white,
        onConfirm: () {
          if (ctrl.text.isEmpty) return;
          int val = int.tryParse(ctrl.text) ?? 0;
          updateGoal(type, val);
          Get.back();
        });
  }

  Future<void> updateGoal(String type, int value) async {
    try {
      isLoading.value = true;
      final userId = user['_id'];

      Map<String, dynamic> data = {"userId": userId};
      if (type == 'calorie') {
        data['gunluk_kalori'] = value;
      } else {
        data['su_hedefi_ml'] = value;
      }

      final response = await dio.put('/auth/update', data: data);

      if (response.statusCode == 200) {
        box.write('user', response.data);
        user.value = response.data;
        Get.snackbar("Başarılı", "Hedef güncellendi.",
            backgroundColor: Colors.green, colorText: Colors.white);

        // Should also update Home Controller if active
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().loadGoals(); // Reload goals in Home
        }
      }
    } catch (e) {
      Get.snackbar("Hata", "Güncelleme başarısız.");
    } finally {
      isLoading.value = false;
    }
  }
}
