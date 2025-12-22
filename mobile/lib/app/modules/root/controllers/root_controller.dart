import 'package:get/get.dart';
import 'package:mobile/app/routes/app_routes.dart';

class RootController extends GetxController {
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}
