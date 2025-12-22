import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class OnboardingView extends GetView<AuthController> {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profilini Oluşturalım')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                onPageChanged: (index) {
                  controller.isOnboardingLastPage.value = (index == 2);
                },
                children: [
                  _buildStep1(controller),
                  _buildStep2(controller),
                  _buildStep3(controller),
                ],
              ),
            ),
            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Check if we can go back, else stay or go back to register
                    if (controller.pageController.hasClients &&
                        controller.pageController.page! > 0) {
                      controller.pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  },
                  child: const Text('Geri'),
                ),
                Obx(() => controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (controller.isOnboardingLastPage.value) {
                            controller.completeOnboarding();
                          } else {
                            controller.pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        },
                        child: Text(controller.isOnboardingLastPage.value
                            ? 'Tamamla'
                            : 'İleri'),
                      )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(AuthController controller) {
    return Center(
        child: SingleChildScrollView(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.person_outline, size: 80, color: Colors.blue),
        const SizedBox(height: 20),
        const Text('Merhaba! Seni tanıyalım.',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(
          controller: controller.ageController,
          decoration: const InputDecoration(
              labelText: 'Yaşın', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        Obx(() => DropdownButtonFormField<String>(
              value: controller.gender.value.isEmpty
                  ? null
                  : controller.gender.value,
              items: const [
                DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
              ],
              onChanged: (v) => controller.gender.value = v!,
              decoration: const InputDecoration(
                  labelText: 'Cinsiyet', border: OutlineInputBorder()),
            )),
      ],
    )));
  }

  Widget _buildStep2(AuthController controller) {
    return Center(
        child: SingleChildScrollView(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.fitness_center, size: 80, color: Colors.orange),
        const SizedBox(height: 20),
        const Text('Fiziksel Özellikler',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(
          controller: controller.weightController,
          decoration: const InputDecoration(
              labelText: 'Kilo (kg)', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: controller.heightController,
          decoration: const InputDecoration(
              labelText: 'Boy (cm)', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
        ),
      ],
    )));
  }

  Widget _buildStep3(AuthController controller) {
    return Center(
        child: SingleChildScrollView(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.flag, size: 80, color: Colors.green),
        const SizedBox(height: 20),
        const Text('Hedefin Ne?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Obx(() => DropdownButtonFormField<String>(
              value:
                  controller.goal.value.isEmpty ? null : controller.goal.value,
              items: const [
                DropdownMenuItem(value: 'Kilo Ver', child: Text('Kilo Ver')),
                DropdownMenuItem(value: 'Kilo Al', child: Text('Kilo Al')),
                DropdownMenuItem(
                    value: 'Kilomu Koru', child: Text('Kilomu Koru')),
              ],
              onChanged: (v) => controller.goal.value = v!,
              decoration: const InputDecoration(
                  labelText: 'Hedef', border: OutlineInputBorder()),
            )),
        const SizedBox(height: 20),
        Obx(() => DropdownButtonFormField<String>(
              value: controller.activityLevel.value.isEmpty
                  ? null
                  : controller.activityLevel.value,
              items: const [
                DropdownMenuItem(
                    value: 'Hareketsiz', child: Text('Hareketsiz')),
                DropdownMenuItem(
                    value: 'Az Hareketli', child: Text('Az Hareketli')),
                DropdownMenuItem(
                    value: 'Orta Hareketli', child: Text('Orta Hareketli')),
                DropdownMenuItem(
                    value: 'Çok Hareketli', child: Text('Çok Hareketli')),
              ],
              onChanged: (v) => controller.activityLevel.value = v!,
              decoration: const InputDecoration(
                  labelText: 'Aktivite Seviyesi', border: OutlineInputBorder()),
            )),
      ],
    )));
  }
}
