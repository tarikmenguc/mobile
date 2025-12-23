import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/food_controller.dart';

class ManualAddView extends GetView<FoodController> {
  const ManualAddView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Local controllers for the form
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final proteinCtrl = TextEditingController();
    final carbCtrl = TextEditingController();
    final fatCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Manuel Yemek Ekle")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Yemeğin bilgilerini giriniz:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Name
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                  labelText: "Yemek Adı",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant)),
            ),
            const SizedBox(height: 16),

            // Amount & Calories
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: amountCtrl,
                    decoration: const InputDecoration(
                        labelText: "Miktar (örn: 1 porsiyon)",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.scale)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: calCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "Kalori (kcal)",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_fire_department)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text("Makro Değerler (İsteğe Bağlı):",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _buildMacroField(proteinCtrl, "Protein (g)")),
                const SizedBox(width: 8),
                Expanded(child: _buildMacroField(carbCtrl, "Karb (g)")),
                const SizedBox(width: 8),
                Expanded(child: _buildMacroField(fatCtrl, "Yağ (g)")),
              ],
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Validation
                  if (nameCtrl.text.isEmpty || calCtrl.text.isEmpty) {
                    Get.snackbar(
                        "Hata", "Lütfen yemek adı ve kaloriyi giriniz.");
                    return;
                  }

                  // Prepare object
                  final foodData = {
                    "isim": nameCtrl.text,
                    "kalori": int.tryParse(calCtrl.text) ?? 0,
                    "miktar": amountCtrl.text.isEmpty
                        ? "1 porsiyon"
                        : amountCtrl.text,
                    "makrolar": {
                      "protein": double.tryParse(proteinCtrl.text) ?? 0,
                      "karbonhidrat": double.tryParse(carbCtrl.text) ?? 0,
                      "yag": double.tryParse(fatCtrl.text) ?? 0,
                    },
                    "kaynak": "manuel"
                  };

                  controller.addManualFood(foodData);
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green),
                child: const Text("Ekle",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMacroField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
    );
  }
}
