import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/food_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';

class FoodEntryView extends GetView<FoodController> {
  const FoodEntryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yemek Ekle'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.camera_alt), text: "Fotoğraf"),
              Tab(icon: Icon(Icons.search), text: "Arama & Favoriler"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: FOTOĞRAF
            _buildPhotoTab(),
            // TAB 2: ARAMA & FAVORİLER
            _buildSearchTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoTab() {
    return Center(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("AI Yemeği Analiz Ediyor... 🤖🍎"),
            ],
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined,
                size: 100, color: Colors.grey),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => controller.pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera),
              label: const Text("Fotoğraf Çek"),
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text("Galeriden Seç"),
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Arama Alanı
          TextField(
            controller: controller.searchTextController,
            decoration: InputDecoration(
              hintText: "Örn: 1 kase mercimek çorbası",
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: controller.searchFoodText,
              ),
              // filled & border handled by AppTheme
            ),
            onSubmitted: (_) => controller.searchFoodText(),
          ),
          const SizedBox(height: 20),

          // Search Results or Favorites
          Expanded(
            child: Obx(() {
              // 1. Show Search Results if available
              if (controller.searchResults.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Arama Sonuçları",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue)),
                          TextButton(
                              onPressed: () => controller.searchResults
                                  .clear(), // Clear to show favorites again
                              child: const Text("Temizle"))
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.searchResults.length,
                        itemBuilder: (context, index) {
                          final item = controller.searchResults[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  child: Icon(Icons.restaurant_menu,
                                      color: Colors.white)),
                              title: Text(item['isim'] ?? 'Yemek',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  "${item['miktar']} • ${item['kalori']} kcal"),
                              trailing: IconButton(
                                icon: const Icon(Icons.star_border,
                                    color: Colors.orange),
                                onPressed: () => controller.addToFavorites(
                                    Map<String, dynamic>.from(item)),
                              ),
                              onTap: () {
                                // Select Item for Diary
                                controller.analyzedFood.value =
                                    Map<String, dynamic>.from(item);
                                // Wrap in standard format expected by Confirmation/Analysis view if needed,
                                // or just set it and go.
                                // The Analysis View expects 'yemekler' list usually?
                                // Let's adapt it.
                                controller.analyzedFood.value = {
                                  'yemekler': [item],
                                  'toplam_kalori': item['kalori']
                                };
                                Get.toNamed(
                                    '/ai-analysis'); // Using string route or Routes constant
                              },
                            ),
                          );
                        },
                      ),
                    )
                  ],
                );
              }

              // 2. Show Favorites (Default)
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("Favorilerim ⭐",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  if (controller.favorites.isEmpty)
                    const Expanded(
                        child: Center(
                            child: Text("Henüz favori yemeğiniz yok.",
                                style: TextStyle(color: Colors.grey))))
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.favorites.length,
                        itemBuilder: (context, index) {
                          final fav = controller.favorites[index];
                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(child: Text("❤️")),
                              title: Text(fav['isim'] ?? 'Bilinmiyor'),
                              subtitle: Text(
                                  "${fav['miktar']} - ${fav['kalori']} kcal"),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    controller.removeFromFavorites(fav['_id']),
                              ),
                              onTap: () {
                                Get.defaultDialog(
                                    title: "Günlüğe Ekle",
                                    middleText:
                                        "${fav['isim']} bugünkü günlüğe eklensin mi?",
                                    textConfirm: "Evet, Ekle",
                                    textCancel: "İptal",
                                    onConfirm: () {
                                      Get.back();
                                      controller.addFavoriteToLog(
                                          Map<String, dynamic>.from(fav));
                                    });
                              },
                            ),
                          );
                        },
                      ),
                    )
                ],
              );
            }),
          )
        ],
      ),
    );
  }
}
