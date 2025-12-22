import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/food_controller.dart';

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
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: controller.searchFoodText,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onSubmitted: (_) => controller.searchFoodText(),
          ),
          const SizedBox(height: 20),

          // Favoriler Başlığı
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Favorilerim ⭐",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),

          // Favori Listesi
          Expanded(
            child: Obx(() {
              if (controller.favorites.isEmpty) {
                return const Center(
                  child: Text("Henüz favori yemeğiniz yok.",
                      style: TextStyle(color: Colors.grey)),
                );
              }
              return ListView.builder(
                itemCount: controller.favorites.length,
                itemBuilder: (context, index) {
                  final fav = controller.favorites[index];
                  // fav = {isim, kalori, miktar, makrolar...}
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Text("❤️")),
                      title: Text(fav['isim'] ?? 'Bilinmiyor'),
                      subtitle:
                          Text("${fav['miktar']} - ${fav['kalori']} kcal"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            controller.removeFromFavorites(fav['_id']),
                      ),
                      onTap: () {
                        // Tıklayınca günlüğe ekle
                        Get.defaultDialog(
                            title: "Günlüğe Ekle",
                            middleText:
                                "${fav['isim']} bugünkü günlüğe eklensin mi?",
                            textConfirm: "Evet, Ekle",
                            textCancel: "İptal",
                            onConfirm: () {
                              Get.back(); // Dialog kapat
                              controller.addFavoriteToLog(
                                  Map<String, dynamic>.from(fav));
                            });
                      },
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }
}
