import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/root_controller.dart';
import '../../home/views/home_view.dart';
import '../../diary/views/diary_view.dart';
import '../../health/views/health_view.dart';
import '../../profile/views/profile_view.dart';
import '../../../routes/app_routes.dart';

class RootView extends GetView<RootController> {
  const RootView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeView(),
              DiaryView(),
              HealthView(),
              ProfileView(),
            ],
          )),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changePage,
          // Use Material 3 NavigationBar or BottomNavigationBar?
          // NavigationBar is modern but slightly taller. Let's use BottomNavigationBar for classic look if preferred, but Material 3 default is NavigationBar.
          // Let's stick to standard BottomNavigationBar for thinner profile if needed, OR NavigationBar.
          // Prompt said "Bottom Navigation Bar".
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Ana Sayfa'),
            NavigationDestination(
                icon: Icon(Icons.book_outlined),
                selectedIcon: Icon(Icons.book),
                label: 'Günlük'),
            NavigationDestination(
                icon: Icon(Icons.medical_services_outlined),
                selectedIcon: Icon(Icons.medical_services),
                label: 'Sağlık'),
            NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.bottomSheet(
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                height: 200,
                child: Column(
                  children: [
                    const Text("Ekle",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ListTile(
                      leading:
                          const Icon(Icons.restaurant, color: Colors.orange),
                      title: const Text("Yemek Ekle"),
                      onTap: () {
                        Get.back(); // close sheet
                        Get.toNamed(Routes.FOOD_ENTRY);
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.directions_run, color: Colors.blue),
                      title: const Text("Aktivite Ekle"),
                      onTap: () {
                        Get.back();
                        // Get.toNamed(Routes.ACTIVITY_ADD);
                        Get.snackbar("Yakında", "Aktivite ekleme yakında...");
                      },
                    ),
                  ],
                ),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ));
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerDocked, // Or just standard above nav?
      // NavigationBar doesn't support notch like BottomAppBar.
      // So standard FAB location.
    );
  }
}
