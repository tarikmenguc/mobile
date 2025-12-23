import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/health_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';

class AnalysisResultView extends GetView<HealthController> {
  const AnalysisResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), // Light Background
      appBar: AppBar(
        title: const Text("AI Analiz Sonucu",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final result = controller.currentResult.value;
          if (result == null)
            return const Center(child: Text("Sonuç bulunamadı"));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Chat Bubble for Summary
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.auto_awesome, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2))
                          ]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Kısa Özet",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primary)),
                          const SizedBox(height: 8),
                          Text(result.aiAnalizMetni,
                              style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Colors.black87)),
                        ],
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 24),

              // 2. Chat Bubble for Recommendations
              if (result.oneriler.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.lightbulb, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2))
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("3 Önemli Tavsiye",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.orange)),
                            const SizedBox(height: 12),
                            ...result.oneriler
                                .map((e) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.check,
                                              size: 16, color: Colors.green),
                                          const SizedBox(width: 8),
                                          Expanded(
                                              child: Text(e,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black87))),
                                        ],
                                      ),
                                    ))
                                .toList()
                          ],
                        ),
                      ),
                    )
                  ],
                ),
            ],
          );
        }),
      ),
    );
  }
}
