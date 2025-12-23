import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final box = GetStorage();
  final dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:5000/api', // Android Emulator Loopback
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Temporary storage for registration flow
  var tempRegisterData = <String, dynamic>{};

  // Controllers for Onboarding
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  // Page Controller for Onboarding
  final pageController = PageController();
  final isOnboardingLastPage = false.obs;

  // Observables for Dropdowns
  final gender = 'Erkek'.obs; // Default
  final activityLevel = 'Hareketsiz'.obs; // Default
  final goal =
      'Kilo Ver'.obs; // Info only, backend calculates calories based on stats

  // Mapping UI values to Backend API values
  String _mapGenderToBackend(String uiGender) {
    return uiGender == 'Erkek' ? 'erkek' : 'kadın';
  }

  String _mapActivityToBackend(String uiActivity) {
    switch (uiActivity) {
      case 'Hareketsiz':
        return 'sedanter';
      case 'Az Hareketli':
        return 'hafif';
      case 'Orta Hareketli':
        return 'orta';
      case 'Çok Hareketli':
        return 'yuksek'; // or cok_yuksek
      default:
        return 'sedanter';
    }
  }

  // Called from LoginView
  void login(String email, String password) async {
    isLoading.value = true;
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final user = response.data; // user details

        await box.write('token', token);
        await box.write('user', user);

        Get.offAllNamed(Routes.ROOT); // Navigate to Root to show BottomBar
        Get.snackbar('Başarılı', 'Giriş yapıldı');
        print('TOKEN: $token');
      }
    } on DioException catch (e) {
      String message = e.response?.data['message'] ?? 'Bağlantı hatası';
      Get.snackbar('Hata', message);
    } catch (e) {
      Get.snackbar('Hata', 'Beklenmedik bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  // Called from RegisterView -> Moves to Onboarding
  void startRegistration(String name, String email, String password) {
    tempRegisterData['ad_soyad'] = name;
    tempRegisterData['email'] = email;
    tempRegisterData['password'] = password;
    Get.toNamed(Routes.ONBOARDING);
  }

  // Called from OnboardingView (Last Step)
  void completeOnboarding() async {
    print("--------------------------------------------------");
    print("STARTING ONBOARDING COMPLETION");
    isLoading.value = true;
    try {
      // Prepare full data payload
      final fullData = {
        ...tempRegisterData,
        'yas': int.tryParse(ageController.text) ?? 25,
        'boy': int.tryParse(heightController.text) ?? 175,
        'kilo': int.tryParse(weightController.text) ?? 75,
        'cinsiyet': _mapGenderToBackend(gender.value),
        'aktivite_seviyesi': _mapActivityToBackend(activityLevel.value),
      };
      print("DATA PREPARED: $fullData");

      final response = await dio.post('/auth/register', data: fullData);
      print("RESPONSE: ${response.statusCode} - ${response.data}");

      if (response.statusCode == 201) {
        final token = response.data['token'];
        final user = response.data;

        await box.write('token', token);
        await box.write('user', user);

        Get.offAllNamed(Routes.ROOT);
        Get.snackbar('Tebrikler', 'Hesabınız oluşturuldu!');
      }
    } on DioException catch (e) {
      String message = e.response?.data['message'] ?? 'Kayıt başarısız';
      Get.snackbar('Hata', message);
      print(e.response?.data);
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
  }
}
