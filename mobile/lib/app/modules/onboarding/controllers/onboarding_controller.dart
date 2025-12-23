import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile/app/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  var isLastPage = false.obs;
  final box = GetStorage();

  void changePage(int index) {
    isLastPage.value = (index == 2);
  }

  void completeOnboarding() {
    // Flag this user as having seen onboarding
    box.write('seenOnboarding', true);
    Get.offAllNamed(Routes.LOGIN);
  }

  void skipOnboarding() {
    completeOnboarding();
  }
}
