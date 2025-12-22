import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile/data/services/dio_service.dart';
import 'package:mobile/data/services/storage_service.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Services
  await GetStorage.init();
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => DioService().init());

  // Initialize Date Formatting
  await initializeDateFormatting('tr_TR', null);

  runApp(
    GetMaterialApp(
      title: "Kalori Lens",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
    ),
  );
}
