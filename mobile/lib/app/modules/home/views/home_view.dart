import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';
import '../../../../core/theme/app_colors.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bugünün Özeti'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: controller.fetchTodayLog)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Calorie Ring Chart (Premium Style)
            _buildCalorieChart(),

            const SizedBox(height: 24),

            // 2. Water Tracking
            _buildWaterTracker(),

            const SizedBox(height: 30),

            // 3. Quick Actions
            const Text("Günlük Hareketler",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            Obx(() {
              if (controller.foods.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.foods.length,
                itemBuilder: (context, index) {
                  final item = controller.foods[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.restaurant_rounded,
                            color: Colors.orange),
                      ),
                      title: Text(item['isim'] ?? 'Bilinmiyor',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${item['miktar'] ?? ''}"),
                      trailing: Text("${item['kalori']} kcal",
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.notes_rounded, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text("Henüz bir kayıt yok.",
              style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildCalorieChart() {
    return Obx(() {
      final double taken = controller.takenCalories.value.toDouble();
      final double burned = controller.burnedCalories.value.toDouble();
      final double goal = controller.calorieGoal.value.toDouble();

      final int carbs = controller.takenCarbs.value;
      final int carbsGoal = controller.carbsGoal.value;
      final int protein = controller.takenProtein.value;
      final int proteinGoal = controller.proteinGoal.value;
      final int fat = controller.takenFat.value;
      final int fatGoal = controller.fatGoal.value;

      final double totalBudget = goal + burned;
      var remaining = (totalBudget - taken);
      if (remaining < 0) remaining = 0;

      const themeColor = Color(0xFF26C6DA); // Turquoise

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 5),
              )
            ]),
        child: Column(
          children: [
            // 1. TOP ROW: Eaten - Ring - Burned
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Column: Alınan (Eaten)
                _buildInfoColumn(
                    "Alınan", taken.toStringAsFixed(0), Colors.black87),

                // Center: Main Ring (Remaining)
                SizedBox(
                  height: 140,
                  width: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: 270,
                          sectionsSpace: 0,
                          centerSpaceRadius: 55,
                          sections: [
                            // Taken Fills the ring
                            PieChartSectionData(
                              color: themeColor,
                              value: taken,
                              showTitle: false,
                              radius: 12,
                            ),
                            // Remaining is empty
                            PieChartSectionData(
                              color: Colors.grey[200],
                              value: remaining,
                              showTitle: false,
                              radius: 12,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            remaining.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF37474F), // Dark Grey
                              height: 1.0,
                            ),
                          ),
                          const Text("Kalan",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9E9E9E), // Light Grey
                                  fontWeight: FontWeight.w600)),
                        ],
                      )
                    ],
                  ),
                ),

                // Right Column: Yakılan (Burned)
                _buildInfoColumn(
                    "Yakılan", burned.toStringAsFixed(0), Colors.black87),
              ],
            ),

            const SizedBox(height: 30),

            // 2. MACROS ROW
            Row(
              children: [
                Expanded(
                    child: _buildMacroItem(
                        "Karbonhidrat", carbs, carbsGoal, themeColor)),
                const SizedBox(width: 20),
                Expanded(
                    child: _buildMacroItem(
                        "Protein", protein, proteinGoal, themeColor)),
                const SizedBox(width: 20),
                Expanded(
                    child: _buildMacroItem("Yağ", fat, fatGoal, themeColor)),
              ],
            )
          ],
        ),
      );
    });
  }

  Widget _buildInfoColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
      ],
    );
  }

  Widget _buildMacroItem(String label, int value, int goal, Color color) {
    double progress = (value / (goal == 0 ? 1 : goal)).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF757575))),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: Colors.grey[200],
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text("${value} / ${goal} g",
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9E9E9E),
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildWaterTracker() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Su Tüketimi",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  Text("Bugünkü Hedef: ${controller.waterGoal.value}ml",
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppColors.water.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.water_drop_rounded,
                    color: AppColors.water),
              )
            ],
          ),
          const SizedBox(height: 20),

          // Progress Bar
          Obx(() {
            final double progress =
                (controller.waterMl.value / controller.waterGoal.value)
                    .clamp(0.0, 1.0);
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.water.withOpacity(0.1),
                color: AppColors.water,
                minHeight: 12,
              ),
            );
          }),
          const SizedBox(height: 10),
          Obx(() => Align(
              alignment: Alignment.centerRight,
              child: Text("${controller.waterMl.value} ml",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.water)))),

          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              Expanded(child: _buildWaterButton(200)),
              const SizedBox(width: 15),
              Expanded(child: _buildWaterButton(500)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWaterButton(int amount) {
    return ElevatedButton.icon(
      onPressed: () => controller.addWater(amount),
      icon: const Icon(Icons.add_rounded, size: 18),
      label: Text("+$amount ml"),
      style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
    );
  }
}
