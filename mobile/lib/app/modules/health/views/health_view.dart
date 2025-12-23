import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/routes/app_routes.dart';
import '../controllers/health_controller.dart';

class HealthView extends GetView<HealthController> {
  const HealthView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sağlık & Tahlil Analizi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: controller.pickAndAnalyze,
            tooltip: "Yeni Tahlil Ekle",
          )
        ],
      ),
      body: Stack(
        children: [
          // Main Content
          Obx(() {
            if (controller.isLoadingHistory.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.history.isEmpty) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.medical_services_outlined,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text("Henüz analiz edilmiş bir tahlil yok.",
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                      onPressed: controller.pickAndAnalyze,
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Yeni Tahlil Yükle"))
                ],
              ));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.history.length,
              itemBuilder: (context, index) {
                final report = controller.history[
                    controller.history.length - 1 - index]; // Reverse locally
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.assignment, color: Colors.white),
                    ),
                    title: Text("Tahlil Raporu #${index + 1}"),
                    subtitle: Text(report.tarih ?? '', maxLines: 1),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      controller.currentResult.value = report;
                      Get.toNamed(Routes.HEALTH_RESULT);
                    },
                  ),
                );
              },
            );
          }),

          // Loading Overlay
          Obx(() => controller.isAnalyzing.value
              ? Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 20),
                        Text("AI Tahlil Ediyor...\nBu işlem biraz sürebilir.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      floatingActionButton: null,
    );
  }
}
