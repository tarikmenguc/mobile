import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../routes/app_routes.dart';
import '../../home/controllers/home_controller.dart';

class FoodController extends GetxController {
  final dio = dio_pkg.Dio(dio_pkg.BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: const Duration(seconds: 30), // AI takes time
    receiveTimeout: const Duration(seconds: 30),
  ));
  final box = GetStorage();
  final picker = ImagePicker();

  final isLoading = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);

  // Analysis Result
  final analyzedFood = <String, dynamic>{}.obs;

  Future<void> pickImage(ImageSource source) async {
    print("------------------------------------------------");
    print("PICK IMAGE REQUESTED: $source");

    // 1. Request Permission
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      // For Gallery (Android 13+ sets different permissions, but photos is general)
      // On Android 13+, READ_MEDIA_IMAGES is needed. Permission.photos handles logical mapping often,
      // but let's be explicit or safe.
      status = await Permission.storage.request();
      if (status.isDenied) {
        // Try media images for Android 13
        status = await Permission.photos.request();
      }
    }

    print("PERMISSION STATUS: $status");

    if (status.isPermanentlyDenied) {
      Get.snackbar('İzin Gerekli', 'Lütfen ayarlardan izin verin.');
      openAppSettings();
      return;
    }

    // 2. Pick Image
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        print("PICK IMAGE SUCCESS: ${pickedFile.path}");
        selectedImage.value = File(pickedFile.path);
        // Auto-analyze as per prompt
        analyzeImage();
      } else {
        print("PICK IMAGE CANCELLED (User didn't select)");
      }
    } catch (e) {
      print("PICK IMAGE ERROR: $e");
      Get.snackbar('Hata', 'Fotoğraf seçilemedi: $e');
    }
  }

  Future<void> analyzeImage() async {
    if (selectedImage.value == null) {
      print("ANALYZE ABORTED: No image selected");
      return;
    }

    print("STARTING ANALYSIS...");
    isLoading.value = true;
    try {
      String fileName = selectedImage.value!.path.split('/').last;
      print("FILE NAME: $fileName");

      dio_pkg.FormData formData = dio_pkg.FormData.fromMap({
        "image": await dio_pkg.MultipartFile.fromFile(
          selectedImage.value!.path,
          filename: fileName,
        ),
      });

      print("SENDING TO BACKEND (/food/analyze)...");
      final response = await dio.post('/food/analyze', data: formData);
      print("BACKEND RESPONSE CODE: ${response.statusCode}");
      print("BACKEND RESPONSE DATA: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        print("ANALYSIS SUCCESS! Mapping data...");

        // Handle explicit List vs Map (Gemini sometimes wraps result in Array)
        var responseData = response.data['data'];
        if (responseData is List) {
          if (responseData.isNotEmpty) {
            analyzedFood.value = Map<String, dynamic>.from(responseData.first);
          }
        } else {
          analyzedFood.value = Map<String, dynamic>.from(responseData);
        }

        // Navigate to Confirmation Screen
        Get.toNamed(Routes.AI_ANALYSIS);
      } else {
        print("ANALYSIS FAILED: ${response.data}");
        Get.snackbar("Hata", "Analiz başarısız oldu.");
      }
    } on dio_pkg.DioException catch (e) {
      print("DIO ERROR: ${e.message}");
      print("DIO RESPONSE: ${e.response?.data}");
      Get.snackbar('Hata', 'AI Analizi başarısız: ${e.message}');
    } catch (e) {
      print("UNKNOWN ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addManualFood(Map<String, dynamic> foodData) async {
    isLoading.value = true;
    try {
      final user = box.read('user');
      if (user == null) return;
      final userId = user['_id'];
      final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Using /food/confirm for now as /food/add in backend is just an alias or handled same way
      // Wait, I mapped /food/add to foodController.confirmFood in routes.
      // So I can use /food/add or /food/confirm. Let's use /food/add to be explicit.

      // ConfirmFood controller expects: { userId, date, food }
      final response = await dio.post('/food/add',
          data: {"userId": userId, "date": formattedDate, "food": foodData});

      if (response.statusCode == 200) {
        Get.snackbar("Başarılı", "Yemek başarıyla eklendi.",
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.find<HomeController>().fetchTodayLog(); // Refresh Home
        Get.until((route) => route.settings.name == Routes.HOME); // Go Home
      }
    } catch (e) {
      Get.snackbar("Hata", "Yemek eklenirken bir sorun oluştu.");
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmFood() async {
    isLoading.value = true;
    try {
      final user = box.read('user');
      final userId = user['_id'];
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final List<dynamic> foods = analyzedFood['yemekler'] ?? [];

      // Loop through all items and save them
      for (var item in foods) {
        final foodData = {
          'isim': item['isim'] ?? 'Bilinmeyen Yemek',
          'kalori': item['kalori'] ?? 0,
          'makrolar': item['makrolar'] ?? {},
          'miktar': item['miktar'] ?? '1 Porsiyon',
          'kaynak': 'ai'
        };

        // Send to Backend
        await dio.post('/food/confirm',
            data: {'userId': userId, 'date': date, 'food': foodData});
      }

      // İŞLEM TAMAMLANDI: Ana İskelete Dön (Bottom Bar görünsün diye ROOT'a gidiyoruz)
      Get.offAllNamed(Routes.ROOT);
      // Get.offAllNamed(Routes.HOME); // HATA: Bu komut alt menüyü yok eder, sadece sayfayı açar.
      Get.snackbar("Başarılı", "${foods.length} besin günlüğe eklendi! 🥗");
    } catch (e) {
      print("CONFIRM ERROR: $e");
      Get.snackbar('Hata', 'Kayıt başarısız: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Search & Favorites
  final searchTextController = TextEditingController();
  final searchResults =
      <dynamic>[].obs; // For Text Search Results (usually 1 item from AI)
  final favorites = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<void> searchFoodText() async {
    final text = searchTextController.text.trim();
    if (text.isEmpty) {
      Get.snackbar("Uyarı", "Lütfen bir yemek yazın.");
      return;
    }

    isLoading.value = true;
    searchResults.clear(); // Clear previous
    try {
      final response = await dio.post('/food/search', data: {'text': text});
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        // Handle { items: [...] } structure
        if (data is Map && data.containsKey('items')) {
          final list = List<dynamic>.from(data['items']);
          searchResults.value = list;
        } else if (data is List) {
          searchResults.value = data;
        } else {
          // Fallback for single item
          searchResults.value = [data];
        }

        // Do NOT navigate away. UI will show the list.
        if (searchResults.isEmpty) {
          Get.snackbar("Bilgi", "Sonuç bulunamadı.");
        }
      }
    } on dio_pkg.DioException catch (e) {
      print("SEARCH DIO ERROR: ${e.message}");
      if (Get.context != null) {
        Get.snackbar("Hata",
            "Arama başarısız: ${e.response?.data['message'] ?? e.message}");
      }
    } catch (e) {
      print("SEARCH ERROR: $e");
      if (Get.context != null) {
        Get.snackbar("Hata", "Arama yapılamadı.");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFavorites() async {
    try {
      final user = box.read('user');
      if (user == null) return;
      final userId = user['_id'];

      final response =
          await dio.get('/food/favorites', queryParameters: {'userId': userId});
      if (response.statusCode == 200) {
        favorites.value = response.data;
      }
    } catch (e) {
      print("FETCH FAV ERROR: $e");
    }
  }

  Future<void> addToFavorites(Map<String, dynamic> foodItem) async {
    try {
      final user = box.read('user');
      final userId = user['_id'];

      // Sanitize foodItem (remove _id if exists to avoid conflicts, or keep it?)
      // Backend pushes to array, Mongo auto-generates _id for subdoc.
      final cleanItem = Map<String, dynamic>.from(foodItem);
      cleanItem.remove('_id');

      final response = await dio
          .post('/food/favorites', data: {'userId': userId, 'food': cleanItem});

      if (response.statusCode == 200) {
        favorites.value = response.data; // Updated list
        Get.snackbar("Başarılı", "Favorilere eklendi! ❤️");
      }
    } on dio_pkg.DioException catch (e) {
      print("ADD FAV DIO ERROR: ${e.message}");
      print("STATUS: ${e.response?.statusCode}");
      print("DATA: ${e.response?.data}");
      Get.snackbar("Hata", "Favori eklenemedi.");
    } catch (e) {
      print("ADD FAV ERROR: $e");
    }
  }

  Future<void> removeFromFavorites(String favId) async {
    try {
      final user = box.read('user');
      final userId = user['_id'];

      final response =
          await dio.delete('/food/favorites/$favId', data: {'userId': userId});

      if (response.statusCode == 200) {
        favorites.value = response.data; // Updated list
      }
    } catch (e) {
      print("REMOVE FAV ERROR: $e");
    }
  }

  Future<void> addFavoriteToLog(Map<String, dynamic> favoriteItem) async {
    // Directly add a favorite item to daily log
    isLoading.value = true;
    try {
      final user = box.read('user');
      final userId = user['_id'];
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final foodData = {
        'isim': favoriteItem['isim'],
        'kalori': favoriteItem['kalori'],
        'makrolar': favoriteItem['makrolar'],
        'miktar': favoriteItem['miktar'],
        'kaynak': 'favorite'
      };

      await dio.post('/food/confirm',
          data: {'userId': userId, 'date': date, 'food': foodData});

      Get.find<HomeController>().fetchTodayLog(); // Refresh Home

      Get.back(); // Close bottom sheet or dialog
      Get.snackbar("Afiyet Olsun", "${favoriteItem['isim']} eklendi! 🍎");
    } on dio_pkg.DioException catch (e) {
      print("ADD FAV LOG DIO ERROR: ${e.message}");
      print("STATUS: ${e.response?.statusCode}");
      print("DATA: ${e.response?.data}");
      Get.snackbar("Hata", "Eklenemedi: ${e.response?.statusCode}");
    } catch (e) {
      print("ADD FAV LOG ERROR: $e");
      Get.snackbar("Hata", "Eklenemedi.");
    } finally {
      isLoading.value = false;
    }
  }
}
