import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profilim")),
      body: Obx(() {
        final userData = controller.user.value;
        if (userData.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final profil = userData['profil'] ?? {};
        final hedefler = userData['hedefler'] ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                userData['ad_soyad'] ?? 'Kullanıcı',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                userData['email'] ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Info Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                          Icons.cake, "Yaş", "${profil['yas'] ?? '-'}"),
                      const Divider(),
                      _buildInfoRow(
                          Icons.height, "Boy", "${profil['boy'] ?? '-'} cm"),
                      const Divider(),
                      _buildInfoRow(Icons.monitor_weight, "Kilo",
                          "${profil['kilo'] ?? '-'} kg"),
                      const Divider(),
                      _buildInfoRow(Icons.local_fire_department, "Günlük Hedef",
                          "${hedefler['gunluk_kalori'] ?? '-'} kcal"),
                      const Divider(),
                      _buildInfoRow(Icons.local_drink, "Su Hedefi",
                          "${hedefler['su_hedefi_ml'] ?? '-'} ml"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Actions
              ElevatedButton.icon(
                onPressed: controller.showUpdateWeightDialog,
                icon: const Icon(Icons.edit),
                label: const Text("Kilo Güncelle"),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    minimumSize: const Size(double.infinity, 50)),
              ),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                onPressed: controller.logout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("Çıkış Yap",
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size(double.infinity, 50)),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 10),
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
