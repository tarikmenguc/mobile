import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';
import '../controllers/home_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), // Light background
      appBar: AppBar(
        // title: const Text('Bugünün Özeti', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        title: Obx(() => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      size: 16, color: Colors.black),
                  onPressed: () => controller.changeDate(-1),
                ),
                Text(
                  controller.displayDate,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.black),
                  onPressed: () => controller.changeDate(1),
                ),
              ],
            )),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: () {
                controller.fetchTodayLog();
                controller.fetchWeeklyStats();
              })
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildWaterCard(),
            const SizedBox(height: 16),
            _buildFoodList(),
            const SizedBox(height: 24),
            _buildWeeklyChart(), // New Weekly Chart
            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/food-entry');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ... (Summary Card, Water Card, Food List - Keep Existing) ...
  // Re-declare them here or rely on them being unchanged if not targeted.
  // Since replace_file_content works on chunks, I target build() method mainly.

  // Adding _buildWeeklyChart method
  Widget _buildWeeklyChart() {
    return Obx(() {
      if (controller.weeklyLogs.isEmpty) return const SizedBox.shrink();

      // Prepare data for last 7 days from weeklyLogs
      // weeklyLogs is List of DailyLog objects.
      // We need to map them to BarGroups.

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Haftalık Özet",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 10),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ]),
            child: BarChart(BarChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    // value is index 0..6
                    // We need to map index to Day Name (Pzt, Sal...)
                    if (value < 0 || value >= controller.weeklyLogs.length)
                      return const SizedBox();
                    final log = controller.weeklyLogs[value.toInt()];
                    final date = DateTime.parse(log['tarih']);
                    final dayName =
                        DateFormat('E', 'tr_TR').format(date); // Pzt, Sal
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child:
                          Text(dayName, style: const TextStyle(fontSize: 10)),
                    );
                  },
                )),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(controller.weeklyLogs.length, (index) {
                final log = controller.weeklyLogs[controller.weeklyLogs.length -
                    1 -
                    index]; // Reverse to show Oldest -> Newest left to right?
                // Controller fetches SORTED BY DATE DESC (Newest first).
                // So index 0 is Today.
                // We want Left (Oldest) -> Right (Newest).
                // So read from end.
                final actualLog = controller
                    .weeklyLogs[controller.weeklyLogs.length - 1 - index];

                return BarChartGroupData(x: index, barRods: [
                  BarChartRodData(
                    toY: (actualLog['toplam_alinan_kalori'] ?? 0).toDouble(),
                    color: (actualLog['toplam_alinan_kalori'] ?? 0) >
                            (controller.calorieGoal.value)
                        ? Colors.redAccent
                        : Colors.teal,
                    width: 12,
                    borderRadius: BorderRadius.circular(4),
                  )
                ]);
              }),
            )),
          )
        ],
      );
    });
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // Light Background
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Softer shadow
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Obx(() {
        final double taken = controller.takenCalories.value.toDouble();
        final double burned = controller.burnedCalories.value.toDouble();
        final double goal = controller.calorieGoal.value.toDouble();

        final double adjustedGoal = goal + burned;
        final double remaining = (adjustedGoal - taken).clamp(0, adjustedGoal);
        final double progress = (taken / adjustedGoal).clamp(0.0, 1.0);

        return Column(
          children: [
            // Top Section: Calories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Alınan
                _buildCalorieInfoColumn("${taken.toInt()}", "Alınan"),

                // Ring
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background Ring
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: 1,
                          color: const Color(0xFFF2F4F7), // Light Grey Track
                          strokeWidth: 12,
                        ),
                      ),
                      // Progress Ring
                      Transform.rotate(
                        angle: -math.pi / 2, // Start from top
                        child: SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: progress,
                            color: const Color(0xFF2ECC71), // Turquoise
                            strokeWidth: 12,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                      ),
                      // Text Inside
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${remaining.toInt()}",
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Dark Text
                                fontFamily: 'Poppins'),
                          ),
                          const Text(
                            "Kalan",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontFamily: 'Poppins'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // Yakılan
                _buildCalorieInfoColumn("${burned.toInt()}", "Yakılan"),
              ],
            ),

            const SizedBox(height: 24),

            // Macros Section
            Row(
              children: [
                _buildMacroColumn("Karbonhidrat", controller.totalCarbs.value,
                    controller.carbGoal.value, const Color(0xFF2ECC71)),
                const SizedBox(width: 8),
                _buildMacroColumn("Protein", controller.totalProtein.value,
                    controller.proteinGoal.value, const Color(0xFF2ECC71)),
                const SizedBox(width: 8),
                _buildMacroColumn("Yağ", controller.totalFat.value,
                    controller.fatGoal.value, const Color(0xFF2ECC71)),
              ],
            )
          ],
        );
      }),
    );
  }

  Widget _buildCalorieInfoColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Dark Text
              fontFamily: 'Poppins'),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
              fontSize: 12, color: Colors.grey, fontFamily: 'Poppins'),
        ),
      ],
    );
  }

  Widget _buildMacroColumn(
      String label, double taken, double goal, Color color) {
    // Avoid division by zero
    double ratio = (goal > 0) ? (taken / goal).clamp(0.0, 1.0) : 0.0;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(label,
              style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 6),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: const Color(0xFFF2F4F7), // Light Track
              color: color,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          // Value text "0 / 335 g"
          Text(
            "${taken.toInt()} / ${goal.toInt()} g",
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // Light Background
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Obx(() {
        // Assuming 250ml per cup for visualization
        int cupsFilled = (controller.waterMl.value / 250).floor();
        // Display goal: 2000 ml = 2.00 L
        double currentLiters = controller.waterMl.value / 1000;
        double goalLiters = controller.waterGoal.value / 1000;

        return Column(
          children: [
            const Text("Su",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)), // Dark Text
            Text("Hedef: ${goalLiters.toStringAsFixed(2)} Litre",
                style: const TextStyle(color: Colors.grey, fontSize: 12)),

            const SizedBox(height: 12),

            Text(
              "${currentLiters.toStringAsFixed(2)} L.",
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins'), // Dark Text
            ),

            const SizedBox(height: 20),

            // Cups Grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: List.generate(8, (index) {
                bool isFilled = index < cupsFilled;
                bool isFirst = index == 0;

                return GestureDetector(
                  onTap: () {
                    // Add 250ml
                    controller.addWater(250);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 30, // Cup width
                        height: 40, // Cup height
                        decoration: BoxDecoration(
                          color: isFilled
                              ? Colors.blue.shade200
                              : const Color(0xFFF2F4F7), // Light empty cup
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: isFirst && !isFilled
                            ? const Center(
                                child: Icon(Icons.add,
                                    size: 16, color: Colors.blue))
                            : null,
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            Text(
              "+ Yediklerinden gelen su: 0 mL",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFoodList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Günlük Aktiviteler & Yemekler",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 10),
        Obx(() {
          if (controller.foods.isEmpty) {
            return const Card(
                color: Colors.white,
                elevation: 0,
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
              return Card(
                color: Colors.white,
                elevation: 0, // Flat look
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side:
                        BorderSide(color: Colors.grey.shade100) // Subtle border
                    ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF2ECC71),
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
    );
  }
}
