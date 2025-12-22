import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/food_controller.dart';

class FoodEntryView extends GetView<FoodController> {
  const FoodEntryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yemek Ekle')),
      body: Center(
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

              // Camera Button
              ElevatedButton.icon(
                onPressed: () => controller.pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera),
                label: const Text("Fotoğraf Çek"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),

              // Gallery Button
              ElevatedButton.icon(
                onPressed: () => controller.pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text("Galeriden Seç"),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue),
              ),
            ],
          );
        }),
      ),
    );
  }
}
