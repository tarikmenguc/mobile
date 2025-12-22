import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/recipe_controller.dart';
import 'recipe_result_view.dart';

class RecipeInputView extends GetView<RecipeController> {
  const RecipeInputView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Şef 👨‍🍳')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() {
          // If loading, show overlay logic (or simple center loader here)
          if (controller.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Şefimiz size uygun en sağlıklı tarifi hazırlıyor..."),
                  Text("🥦🥕🥩", style: TextStyle(fontSize: 24)),
                ],
              ),
            );
          }

          // If recipe exists, show result (or we can navigate, but reactive UI is nice)
          if (controller.generatedRecipe.isNotEmpty) {
            return const RecipeResultView();
          }

          // Input Form
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Bugün ne pişirelim?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Elinizdeki malzemeleri girin, kalori limitinize uygun tarifi üretelim.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: controller.ingredientsController,
                decoration: InputDecoration(
                  labelText: "Malzemeler",
                  hintText: "Örn: Tavuk, Mantar, Krema",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.kitchen),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: controller.generateRecipe,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Tarif Oluştur ✨",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
