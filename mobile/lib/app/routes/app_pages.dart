import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/onboarding_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/food/views/food_entry_view.dart';
import '../modules/food/views/ai_analysis_view.dart';
import '../modules/food/bindings/food_binding.dart';

import '../modules/root/views/root_view.dart';
import '../modules/root/bindings/root_binding.dart';
import '../modules/activity/views/activity_add_view.dart';
import '../modules/activity/bindings/activity_binding.dart';
import '../modules/health/views/analysis_result_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/health/bindings/health_binding.dart';
import 'package:get_storage/get_storage.dart';

class AppPages {
  AppPages._();

  static String get INITIAL {
    final token = GetStorage().read('token');
    return token != null ? Routes.ROOT : Routes.LOGIN;
  }

  static final routes = [
    GetPage(
      name: Routes.ROOT,
      page: () => const RootView(),
      binding: RootBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.FOOD_ENTRY,
      page: () => const FoodEntryView(),
      binding: FoodBinding(),
    ),
    GetPage(
      name: Routes.AI_ANALYSIS,
      page: () => const AiAnalysisView(),
      binding: FoodBinding(),
    ),
    GetPage(
      name: Routes.ACTIVITY_ADD,
      page: () => const ActivityAddView(),
      binding: ActivityBinding(),
    ),
    GetPage(
      name: Routes.HEALTH_RESULT,
      page: () => const AnalysisResultView(),
      binding: HealthBinding(), // Share binding
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
  ];
}
