import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/onboarding_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/root/views/root_view.dart';
import '../modules/root/bindings/root_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/food/views/food_entry_view.dart';
import '../modules/food/bindings/food_binding.dart';
import '../modules/food/views/ai_analysis_view.dart';
import '../modules/activity/views/activity_add_view.dart';
import '../modules/activity/bindings/activity_binding.dart';
import '../modules/recipe/views/recipe_input_view.dart';
import '../modules/recipe/bindings/recipe_binding.dart';
import '../modules/health/views/analysis_result_view.dart';
import '../modules/health/bindings/health_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import 'package:get_storage/get_storage.dart';
// Aliased import to avoid conflict with Auth OnboardingView
import '../modules/onboarding/views/onboarding_view.dart' as intro;
import '../modules/onboarding/bindings/onboarding_binding.dart';

class AppPages {
  AppPages._();

  static var INITIAL = Routes.LOGIN;

  static void determineInitialRoute() {
    final box = GetStorage();
    final token = box.read('token');
    final seenOnboarding = box.read('seenOnboarding') ?? false;

    if (token != null) {
      INITIAL = Routes.ROOT;
    } else if (!seenOnboarding) {
      INITIAL = Routes.WELCOME;
    } else {
      INITIAL = Routes.LOGIN;
    }
  }

  static final routes = [
    GetPage(
      name: Routes.WELCOME, // The intro carousel (class: WelcomeView)
      page: () => const intro.WelcomeView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.ONBOARDING, // The profile setup (class: OnboardingView)
      page: () => const OnboardingView(),
      binding: AuthBinding(),
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
      name: Routes.ROOT,
      page: () => const RootView(),
      binding: RootBinding(),
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
      name: Routes.RECIPE,
      page: () => const RecipeInputView(),
      binding: RecipeBinding(),
    ),
    GetPage(
      name:
          Routes.HEALTH_RESULT, // Fixed route name from HEALTH to HEALTH_RESULT
      page: () => const AnalysisResultView(),
      binding: HealthBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
  ];
}
