import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/theme/app_colors.dart';
import '../controllers/onboarding_controller.dart';

class WelcomeView extends GetView<OnboardingController> {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: controller.pageController,
          onPageChanged: controller.changePage,
          children: [
            _buildPage(
              color: Colors.white,
              image: Icons.camera_alt_outlined,
              title: "Fotoğraf Çek & Analiz Et",
              subtitle:
                  "Yediğin yemeğin fotoğrafını çek, yapay zeka anında kalorisini hesaplasın.",
            ),
            _buildPage(
              color: Colors.white,
              image: Icons.soup_kitchen_outlined,
              title: "Akıllı Tarifler Üret",
              subtitle:
                  "Elinizdeki malzemeleri girin, size özel sağlıklı ve lezzetli tarifler önerelim.",
            ),
            _buildPage(
              color: Colors.white,
              image: Icons.health_and_safety_outlined,
              title: "Sağlığını Takip Et",
              subtitle:
                  "Günlük su, kalori ve kilo takibi ile hedeflerinize ulaşmak artık çok kolay.",
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 80,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: controller.skipOnboarding,
              child: const Text("Atla", style: TextStyle(fontSize: 16)),
            ),
            Center(
              child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        3,
                        (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              height: 10,
                              width: controller.isLastPage.value && index == 2
                                  ? 20
                                  : 10, // Highlight current logic needs better indexing check but simple dot is fine
                              decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(5)),
                            )),
                  )),
            ),
            Obx(() => TextButton(
                  onPressed: () {
                    if (controller.isLastPage.value) {
                      controller.completeOnboarding();
                    } else {
                      controller.pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut);
                    }
                  },
                  child: Text(controller.isLastPage.value ? "Başla" : "İleri",
                      style: const TextStyle(fontSize: 16)),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(
      {required Color color,
      required IconData image,
      required String title,
      required String subtitle}) {
    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(image, size: 150, color: AppColors.primary),
          const SizedBox(height: 60),
          Text(
            title,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
