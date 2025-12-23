import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/food_controller.dart';

class AiAnalysisView extends GetView<FoodController> {
  const AiAnalysisView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Analiz Sonucu (Düzenle)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Selected Image
            if (controller.selectedImage.value != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  controller.selectedImage.value!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 24),

            // Analysis Result List (Editable)
            Obx(() {
              // We need the controller to expose a reactive list we can edit directly or local state
              // Since analyzedFood is RxMap, and 'yemekler' is inside, we might need a better approach for form editing.
              // Best practice: Controller creates text controllers upon analysis success.
              // For MVP/Speed: We will use a local Stateful Widget wrapper or GetX Controllers per item?
              // Let's create a local item editor widget for each item.

              final yemekler =
                  (controller.analyzedFood['yemekler'] as List?) ?? [];

              if (yemekler.isEmpty) return const Text("Yiyecek bulunamadı.");

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: yemekler.length,
                separatorBuilder: (c, i) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _EditableFoodItem(
                    item: yemekler[index],
                    onUpdate: (updatedItem) {
                      // Update controller data
                      var currentList = List<Map<String, dynamic>>.from(
                          controller.analyzedFood['yemekler']);
                      currentList[index] = updatedItem;
                      controller.analyzedFood['yemekler'] = currentList;
                      controller.analyzedFood.refresh(); // Trigger Obx

                      // Recalculate total calories
                      int total = 0;
                      for (var f in currentList) {
                        total += (f['kalori'] as num).toInt();
                      }
                      controller.analyzedFood['toplam_kalori'] = total;
                    },
                    onDelete: () {
                      var currentList = List<Map<String, dynamic>>.from(
                          controller.analyzedFood['yemekler']);
                      currentList.removeAt(index);
                      controller.analyzedFood['yemekler'] = currentList;
                      controller.analyzedFood.refresh();

                      int total = 0;
                      for (var f in currentList) {
                        total += (f['kalori'] as num).toInt();
                      }
                      controller.analyzedFood['toplam_kalori'] = total;
                    },
                  );
                },
              );
            }),

            const SizedBox(height: 30),

            // Total Calories Display
            Obx(() => Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Toplam:",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                            "${controller.analyzedFood['toplam_kalori'] ?? 0} kcal",
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange)),
                      ],
                    ),
                  ),
                )),

            const SizedBox(height: 20),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: Obx(() => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        // Send the modified list
                        controller.confirmFood();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Bu Haliyle Onayla',
                          style: TextStyle(fontSize: 18)),
                    )),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.refresh),
              label: const Text("Vazgeç / Yeniden Çek"),
            )
          ],
        ),
      ),
    );
  }
}

class _EditableFoodItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(Map<String, dynamic>) onUpdate;
  final VoidCallback onDelete;

  const _EditableFoodItem(
      {Key? key,
      required this.item,
      required this.onUpdate,
      required this.onDelete})
      : super(key: key);

  @override
  _EditableFoodItemState createState() => _EditableFoodItemState();
}

class _EditableFoodItemState extends State<_EditableFoodItem> {
  late TextEditingController nameCtrl;
  late TextEditingController calCtrl;
  late TextEditingController amountCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.item['isim']);
    calCtrl = TextEditingController(text: widget.item['kalori'].toString());
    amountCtrl = TextEditingController(text: widget.item['miktar']);
  }

  void _update() {
    // Create updated map
    // Only updating basic fields for simplicity, ignoring macros recalc for now unless detailed
    final updated = Map<String, dynamic>.from(widget.item);
    updated['isim'] = nameCtrl.text;
    updated['kalori'] = int.tryParse(calCtrl.text) ?? 0;
    updated['miktar'] = amountCtrl.text;
    widget.onUpdate(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                        labelText: "Yemek Adı", border: OutlineInputBorder()),
                    onChanged: (_) => _update(),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onDelete)
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(
                      labelText: "Miktar", border: OutlineInputBorder()),
                  onChanged: (_) => _update(),
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: TextField(
                  controller: calCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Kalori (kcal)", border: OutlineInputBorder()),
                  onChanged: (_) => _update(),
                )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
