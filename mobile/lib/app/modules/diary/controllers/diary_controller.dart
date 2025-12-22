import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:intl/intl.dart';
import 'package:mobile/data/models/daily_log_model.dart';
import 'package:mobile/data/services/dio_service.dart';

class DiaryController extends GetxController {
  final dio = Get.find<DioService>()
      .client; // Use the properly init service if possible, or new Dio
  // Since DioService was init with baseurl, use it.

  final box = GetStorage();

  var selectedDate = DateTime.now().obs;
  var isLoading = false.obs;

  var dailyLog = Rxn<DailyLogModel>(); // Nullable

  @override
  void onInit() {
    super.onInit();
    fetchLog();
  }

  void changeDate(DateTime date) {
    selectedDate.value = date;
    fetchLog();
  }

  Future<void> fetchLog() async {
    isLoading.value = true;
    try {
      final user = box.read('user');
      final userId = user['_id'];
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);

      // GET /logs/:date
      final response =
          await dio.get('/logs/$dateStr', queryParameters: {'userId': userId});

      if (response.statusCode == 200 && response.data != null) {
        dailyLog.value = DailyLogModel.fromJson(response.data);
      } else {
        dailyLog.value = null; // No log found
      }
    } catch (e) {
      print("Diary Fetch Error: $e");
      dailyLog.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
