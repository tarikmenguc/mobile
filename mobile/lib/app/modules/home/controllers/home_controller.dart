import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:5000/api',
  ));
  final box = GetStorage();

  // Observables
  final isLoading = false.obs;
  // We store the whole log object or individual fields. Individual is easier for UI binding initially.
  final takenCalories = 0.obs;
  final burnedCalories = 0.obs;
  final waterMl = 0.obs;
  final foods = <dynamic>[].obs; // List of foods

  // Goals (defaults, should come from User Profile)
  final calorieGoal = 2000.obs;
  final waterGoal = 2500.obs;

  @override
  void onInit() {
    super.onInit();
    // Load User Goals from Storage
    final user = box.read('user');
    if (user != null && user['hedefler'] != null) {
      calorieGoal.value = user['hedefler']['gunluk_kalori'] ?? 2000;
      waterGoal.value = user['hedefler']['su_hedefi_ml'] ?? 2500;
    }
    fetchTodayLog();
  }

  String get todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> fetchTodayLog() async {
    isLoading.value = true;
    try {
      final user = box.read('user');
      final userId = user['_id'];

      // Backend expects userId in query for GET logs/date if not using full auth middleware yet
      final response = await dio
          .get('/logs/$todayDate', queryParameters: {'userId': userId});

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        // Backend ensures unique log per day.
        takenCalories.value = data['toplam_alinan_kalori'] ?? 0;
        burnedCalories.value = data['toplam_yakilan_kalori'] ?? 0;
        waterMl.value = data['su_tuketimi_ml'] ?? 0;
        foods.value = data['yemekler'] ?? [];
      } else {
        // No log yet, all 0
        takenCalories.value = 0;
        burnedCalories.value = 0;
        waterMl.value = 0;
        foods.clear();
      }
    } catch (e) {
      print("Error fetching log: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addWater(int amount) async {
    print("ADD WATER CLICKED: $amount ml");
    try {
      final user = box.read('user');
      if (user == null) {
        Get.snackbar("Hata", "Kullanıcı bulunamadı.");
        return;
      }
      final userId = user['_id'];

      // Optimistic Update
      waterMl.value += amount;

      // Backend Call
      final response = await dio.post('/water/update',
          data: {'userId': userId, 'date': todayDate, 'amount': amount});

      print("WATER UPDATE SUCCESS: ${response.statusCode}");
    } catch (e) {
      print("WATER UPDATE ERROR: $e");
      waterMl.value -= amount; // Revert
      Get.snackbar('Hata', 'Su eklenemedi');
    }
  }
}
