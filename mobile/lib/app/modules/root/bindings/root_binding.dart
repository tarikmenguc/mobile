import 'package:get/get.dart';
import 'package:mobile/app/modules/home/controllers/home_controller.dart';
import 'package:mobile/app/modules/diary/controllers/diary_controller.dart';
import 'package:mobile/app/modules/health/controllers/health_controller.dart';
import 'package:mobile/app/modules/profile/controllers/profile_controller.dart';
import '../controllers/root_controller.dart';

class RootBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RootController>(() => RootController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DiaryController>(() => DiaryController()); // Inject
    Get.lazyPut<HealthController>(() => HealthController()); // Inject Health
    Get.lazyPut<ProfileController>(() => ProfileController()); // Inject Profile
    // LazyPut other controllers when we have them
  }
}
