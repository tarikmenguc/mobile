import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title:
            const Text('Bugünün Özeti', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: controller.fetchTodayLog)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Calorie Ring Chart
            _buildCalorieChart(),

            const SizedBox(height: 24),

            // 1.5 AI Health Tip
            _buildHealthTip(),

            const SizedBox(height: 24),

            // 2. Water Tracking
            _buildWaterTracker(),

            const SizedBox(height: 24),

            // 3. Quick Actions or List (Placeholder for next prompt)
            const Text("Günlük Aktiviteler & Yemekler",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Obx(() {
              if (controller.foods.isEmpty) {
                return const Card(
                    child: Padding(
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                            width: double.infinity,
                            child: Text("Henüz kayıt yok."))));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.foods.length,
                itemBuilder: (context, index) {
                  final item = controller.foods[index];
                  // If reversed needed: final item = controller.foods[controller.foods.length - 1 - index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.orangeAccent,
                        child: Icon(Icons.restaurant, color: Colors.white),
                      ),
                      title: Text(item['isim'] ?? 'Bilinmiyor',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${item['miktar'] ?? ''}"),
                      trailing: Text("${item['kalori']} kcal",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.FOOD_ENTRY);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalorieChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Obx(() {
            final double taken = controller.takenCalories.value.toDouble();
            final double burned = controller.burnedCalories.value.toDouble();
            final double goal = controller.calorieGoal.value.toDouble();

            // Net Calorie Logic: Remaining = (Goal + Burned) - Taken
            final double adjustedGoal = goal + burned;
            final double remaining =
                (adjustedGoal - taken).clamp(0, adjustedGoal);

            return PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 60,
                startDegreeOffset: 270,
                sections: [
                  // Taken Section
                  PieChartSectionData(
                    color: Colors.orange,
                    value: taken,
                    showTitle: false,
                    radius: 20,
                  ),
                  // Remaining Section (Grey)
                  PieChartSectionData(
                    color: Colors.grey[200],
                    value: remaining,
                    showTitle: false,
                    radius: 20,
                  ),
                ],
              ),
            );
          }),
          // Center Text
          Center(
            child: Obx(() {
              final double taken = controller.takenCalories.value.toDouble();
              final double burned = controller.burnedCalories.value.toDouble();
              final double goal = controller.calorieGoal.value.toDouble();
              final double netRemaining = (goal + burned) - taken;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    netRemaining.toStringAsFixed(0),
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const Text("Kalan Kcal",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTracker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.blue[50], borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Su Takibi",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              Obx(() => Text(
                  "${controller.waterMl.value} / ${controller.waterGoal.value} ml",
                  style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() {
            final double progress =
                (controller.waterMl.value / controller.waterGoal.value)
                    .clamp(0.0, 1.0);
            return LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white,
              color: Colors.blue,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            );
          }),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => controller.addWater(200),
                icon: const Icon(Icons.water_drop, size: 16),
                label: const Text("+200ml"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white),
              ),
              ElevatedButton.icon(
                onPressed: () => controller.addWater(500),
                icon: const Icon(Icons.local_drink, size: 16),
                label: const Text("+500ml"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHealthTip() {
    return Obx(() {
      if (controller.healthTip.value.isEmpty) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.teal[50], // Light teal for health/freshness
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.teal.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.teal),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("AI Sağlık İpucu",
                      style: TextStyle(
                          color: Colors.teal, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(controller.healthTip.value,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87)),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
