import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/recipe_controller.dart';

class RecipeResultView extends GetView<RecipeController> {
  const RecipeResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipe = controller.generatedRecipe;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(recipe['tarif_adi'] ?? 'İsimsiz Tarif',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer, size: 20, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(recipe['hazirlanis_suresi'] ?? '? dk'),
                      const SizedBox(width: 20),
                      const Icon(Icons.local_fire_department,
                          size: 20, color: Colors.orange),
                      const SizedBox(width: 5),
                      Text("${recipe['kalori']} kcal",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Macros
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroInfo(
                  "Protein", recipe['makrolar']['protein'], Colors.blue),
              _buildMacroInfo(
                  "Karb", recipe['makrolar']['karbonhidrat'], Colors.green),
              _buildMacroInfo("Yağ", recipe['makrolar']['yag'], Colors.red),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),

          // Ingredients
          const Text("Malzemeler",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...List<Widget>.from(
              (recipe['malzemeler'] as List).map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      const Icon(Icons.check_circle_outline,
                          size: 16, color: Colors.green),
                      const SizedBox(width: 10),
                      Expanded(child: Text(e))
                    ]),
                  ))),

          const SizedBox(height: 20),
          const Divider(),

          // Steps
          const Text("Hazırlanış",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...List<Widget>.from((recipe['adimlar'] as List).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(e, style: const TextStyle(height: 1.5)),
              ))),

          const SizedBox(height: 30),

          // Add Button
          ElevatedButton.icon(
            onPressed: controller.addRecipeToLog,
            icon: const Icon(Icons.add_circle, color: Colors.white),
            label: const Text("Bu Yemeği Günlüğüme Ekle",
                style: TextStyle(color: Colors.white, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
            ),
          ),

          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              controller.generatedRecipe.clear(); // Reset to go back to input
              controller.ingredientsController.clear();
            },
            child: const Text("Yeni Tarif Oluştur"),
          )
        ],
      ),
    );
  }

  Widget _buildMacroInfo(String label, dynamic val, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        Text("${val}g", style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
