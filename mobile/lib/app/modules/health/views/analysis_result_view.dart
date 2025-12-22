import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/health_controller.dart';

class AnalysisResultView extends GetView<HealthController> {
  const AnalysisResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analiz Sonucu")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final result = controller.currentResult.value;
          if (result == null)
            return const Center(child: Text("Sonuç bulunamadı"));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("AI Uzman Yorumu:",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal.shade200)),
                child: Text(result.aiAnalizMetni,
                    style: const TextStyle(fontSize: 15)),
              ),
              const SizedBox(height: 20),
              if (result.oneriler.isNotEmpty) ...[
                const Text("Öneriler:",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange)),
                const SizedBox(height: 10),
                ...result.oneriler.map((e) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(e)),
                            ],
                          )),
                    ))
              ]
            ],
          );
        }),
      ),
    );
  }
}
