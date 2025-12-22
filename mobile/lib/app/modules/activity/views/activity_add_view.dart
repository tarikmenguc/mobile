import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/activity_controller.dart';

class ActivityAddView extends GetView<ActivityController> {
  const ActivityAddView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aktivite Ekle")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Icon
            const Icon(Icons.fitness_center, size: 80, color: Colors.blue),
            const SizedBox(height: 20),

            // Dropdown
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedActivityType.value,
                  decoration: const InputDecoration(
                    labelText: "Aktivite Tipi",
                    border: OutlineInputBorder(),
                  ),
                  items: controller.activityTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      controller.selectedActivityType.value = val;
                    }
                  },
                )),

            const SizedBox(height: 20),

            // Duration Input
            TextField(
              controller: controller.durationController,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                  labelText: "Süre (dakika)",
                  border: OutlineInputBorder(),
                  suffixText: "dk"),
            ),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: Obx(() => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: controller.saveActivity,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white),
                      child:
                          const Text("Kaydet", style: TextStyle(fontSize: 18)),
                    )),
            )
          ],
        ),
      ),
    );
  }
}
