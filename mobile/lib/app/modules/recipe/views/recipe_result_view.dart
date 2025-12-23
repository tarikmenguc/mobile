import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/recipe_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';

class RecipeResultView extends GetView<RecipeController> {
  const RecipeResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipe = controller.generatedRecipe;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Card (Image Placeholder + Title + Stats)
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Decorative Header Area
                  Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.orange.shade100,
                    child: const Icon(Icons.restaurant_menu,
                        size: 50, color: Colors.orange),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(recipe['tarif_adi'] ?? 'İsimsiz Tarif',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                                Icons.timer,
                                recipe['hazirlanis_suresi'] ?? '? dk',
                                Colors.blue),
                            Container(
                                width: 1,
                                height: 30,
                                color: Colors.grey.shade300),
                            _buildStatItem(Icons.local_fire_department,
                                "${recipe['kalori']} kcal", Colors.orange),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 2. Macros Row
          Row(
            children: [
              _buildMacroCard(
                  "Protein", "${recipe['makrolar']['protein']}g", Colors.blue),
              const SizedBox(width: 10),
              _buildMacroCard("Karb", "${recipe['makrolar']['karbonhidrat']}g",
                  Colors.green),
              const SizedBox(width: 10),
              _buildMacroCard(
                  "Yağ", "${recipe['makrolar']['yag']}g", Colors.red),
            ],
          ),

          const SizedBox(height: 24),

          // 3. Ingredients Section
          const Text("Malzemeler",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (recipe['malzemeler'] as List)
                .map((e) => Chip(
                      label: Text(e.toString(),
                          style: const TextStyle(color: Colors.black87)),
                      backgroundColor: Colors.white,
                      elevation: 1,
                      avatar: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child:
                              Icon(Icons.check, size: 12, color: Colors.white)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade200)),
                    ))
                .toList(),
          ),

          const SizedBox(height: 24),

          // 4. Instructions Section
          const Text("Hazırlanış Adımları",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: (recipe['adimlar'] as List).length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final step = recipe['adimlar'][index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primary,
                      child: Text("${index + 1}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(step,
                            style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Colors.black87))),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          // 5. Add Button
          ElevatedButton.icon(
            onPressed: controller.addRecipeToLog,
            icon: const Icon(Icons.add_circle, color: Colors.white),
            label: const Text("Bu Yemeği Günlüğüme Ekle",
                style: TextStyle(color: Colors.white, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
          ),

          const SizedBox(height: 16),

          TextButton(
            onPressed: () {
              controller.generatedRecipe.clear();
              controller.ingredientsController.clear();
            },
            child: const Text("Yeni Tarif Oluştur",
                style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(text,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800)),
      ],
    );
  }

  Widget _buildMacroCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
