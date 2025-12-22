import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/food_controller.dart';

class AiAnalysisView extends GetView<FoodController> {
  const AiAnalysisView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Analiz Sonucu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Selected Image
            if (controller.selectedImage.value != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  controller.selectedImage.value!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 24),

            // Result Card - Total Calories
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text("Toplam Kalori",
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                    Text(
                      "${controller.analyzedFood['toplam_kalori'] ?? 0} kcal",
                      style: const TextStyle(
                          fontSize: 32,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text("Tespit Edilenler:",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),

            // List of Detected Foods
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  (controller.analyzedFood['yemekler'] as List?)?.length ?? 0,
              itemBuilder: (context, index) {
                final item = controller.analyzedFood['yemekler'][index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(item['isim'] ?? 'Bilinmiyor',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "${item['miktar'] ?? ''} • ${item['kalori']} kcal"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("P: ${item['makrolar']['protein']}g",
                                style: const TextStyle(fontSize: 12)),
                            Text("K: ${item['makrolar']['karbonhidrat']}g",
                                style: const TextStyle(fontSize: 12)),
                            Text("Y: ${item['makrolar']['yag']}g",
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_border,
                              color: Colors.red),
                          onPressed: () => controller.addToFavorites(item),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: Obx(() => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: controller.confirmFood,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Onayla ve Günlüğe Ekle',
                          style: TextStyle(fontSize: 18)),
                    )),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Vazgeç / Yeniden Çek"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(String label, dynamic value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text("${value ?? 0}g", style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
