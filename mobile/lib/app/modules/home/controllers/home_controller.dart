import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/constants/api_endpoints.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
  ));
  final box = GetStorage();

  // Observables
  final isLoading = false.obs;

  // Date Logic
  final currentDate = DateTime.now().obs;
  String get formattedDate =>
      DateFormat('yyyy-MM-dd').format(currentDate.value);
  String get displayDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
        currentDate.value.year, currentDate.value.month, currentDate.value.day);

    if (selected == today) return "Bugün";
    if (selected == today.subtract(const Duration(days: 1))) return "Dün";
    return DateFormat('d MMMM', 'tr_TR').format(currentDate.value);
    // Requires initializeDateFormatting usually, fallback to simple if needed.
    // Using simple format to avoid locale crash if not initialized:
    // return DateFormat('dd.MM.yyyy').format(currentDate.value);
  }

  // We store the whole log object or individual fields. Individual is easier for UI binding initially.
  final takenCalories = 0.obs;
  final burnedCalories = 0.obs;
  final waterMl = 0.obs;
  final foods = <dynamic>[].obs; // List of foods
  final healthTip = "".obs;

  // Weekly Stats
  final weeklyLogs = <dynamic>[].obs;

  // Goals (defaults, should come from User Profile)
  final calorieGoal = 2000.obs;
  final waterGoal = 2500.obs;

  // Macros (Aggregated)
  final totalCarbs = 0.0.obs;
  final totalProtein = 0.0.obs;
  final totalFat = 0.0.obs;

  // Macro Goals (Mocked for now, can be calculated from calories later)
  final carbGoal = 300.0.obs;
  final proteinGoal = 120.0.obs;
  final fatGoal = 80.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Load User Goals from Storage
    loadGoals();

    // Listen to user changes (e.g. from Profile update)
    box.listenKey('user', (value) {
      if (value != null) loadGoals();
    });

    fetchTodayLog(); // This actually fetches for 'currentDate'
    fetchHealthTip();
    fetchWeeklyStats();
  }

  void loadGoals() {
    final user = box.read('user');
    if (user != null && user['hedefler'] != null) {
      calorieGoal.value = user['hedefler']['gunluk_kalori'] ?? 2000;
      waterGoal.value = user['hedefler']['su_hedefi_ml'] ?? 2500;
    }
  }

  void changeDate(int days) {
    currentDate.value = currentDate.value.add(Duration(days: days));
    fetchTodayLog();
  }

  // String get todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now()); -> Replaced by formattedDate

  Future<void> fetchHealthTip() async {
    try {
      final user = box.read('user');
      if (user == null) return;
      final userId = user['_id'];

      final response =
          await dio.get('/health/tip', queryParameters: {'userId': userId});

      if (response.statusCode == 200 && response.data != null) {
        healthTip.value = response.data['tip'] ?? "";
      }
    } catch (e) {
      print("Error fetching health tip: $e");
    }
  }

  Future<void> fetchTodayLog() async {
    isLoading.value = true;
    try {
      final user = box.read('user');
      if (user == null) return;
      final userId = user['_id'];

      // Use formattedDate (selected date)
      final response = await dio
          .get('/logs/$formattedDate', queryParameters: {'userId': userId});

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['data'] == null) {
        // NOTE: Backend returns {message, data: null} if not found based on my previous edit, OR logic might return raw log.
        // Let's handle both. Logic in logController: return {message, data: null} if !log.
        // If log exists, it returns log object directly? No, wait.
        // logController: res.status(200).json(log); -> Returns Log Object directly if found.
        // if not found: res.status(200).json({ message: '...', data: null });

        final data = response.data;
        if (data is Map && data.containsKey('data') && data['data'] == null) {
          _resetLog();
        } else {
          // It is a log object
          _fillLog(data);
        }
      } else if (response.statusCode == 200 && response.data != null) {
        // Direct log object
        _fillLog(response.data);
      } else {
        _resetLog();
      }
    } catch (e) {
      print("Error fetching log: $e");
      _resetLog(); // Safe fallback
    } finally {
      isLoading.value = false;
    }
  }

  void _fillLog(Map<String, dynamic> data) {
    takenCalories.value = data['toplam_alinan_kalori'] ?? 0;
    burnedCalories.value = data['toplam_yakilan_kalori'] ?? 0;
    waterMl.value = data['su_tuketimi_ml'] ?? 0;
    foods.value = data['yemekler'] ?? [];
    _calculateMacros();
  }

  void _resetLog() {
    takenCalories.value = 0;
    burnedCalories.value = 0;
    waterMl.value = 0;
    foods.clear();
    totalCarbs.value = 0;
    totalProtein.value = 0;
    totalFat.value = 0;
  }

  Future<void> fetchWeeklyStats() async {
    try {
      final user = box.read('user');
      if (user == null) return;
      final userId = user['_id'];

      final response = await dio
          .get('/logs/history', queryParameters: {'userId': userId, 'days': 7});
      if (response.statusCode == 200) {
        weeklyLogs.value = response.data;
      }
    } catch (e) {
      print("Weekly Stats Error: $e");
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
          data: {'userId': userId, 'date': formattedDate, 'amount': amount});

      print("WATER UPDATE SUCCESS: ${response.statusCode}");
    } catch (e) {
      print("WATER UPDATE ERROR: $e");
      waterMl.value -= amount; // Revert
      Get.snackbar('Hata', 'Su eklenemedi');
    }
  }

  void _calculateMacros() {
    double tCarbs = 0;
    double tProtein = 0;
    double tFat = 0;

    for (var food in foods) {
      if (food['makrolar'] != null) {
        var macros = food['makrolar'];
        if (macros is Map) {
          tCarbs += _parseMacro(macros['karbonhidrat']);
          tProtein += _parseMacro(macros['protein']);
          tFat += _parseMacro(macros['yag']);
        }
      }
    }

    totalCarbs.value = tCarbs;
    totalProtein.value = tProtein;
    totalFat.value = tFat;
  }

  double _parseMacro(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) {
      String clean = value.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(clean) ?? 0;
    }
    return 0;
  }
}
