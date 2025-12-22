import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/diary_controller.dart';

class DiaryView extends GetView<DiaryController> {
  const DiaryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Günlük Geçmiş"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Yemekler"),
              Tab(text: "Aktiviteler"),
            ],
          ),
        ),
        body: Column(
          children: [
            // Date Picker Section
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => controller.changeDate(controller
                        .selectedDate.value
                        .subtract(const Duration(days: 1))),
                  ),
                  Obx(() => Text(
                        DateFormat('d MMMM yyyy', 'tr_TR')
                            .format(controller.selectedDate.value),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () => controller.changeDate(controller
                        .selectedDate.value
                        .add(const Duration(days: 1))),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.dailyLog.value == null) {
                  return const Center(
                      child: Text("Bu tarihte kayıt bulunamadı."));
                }

                final log = controller.dailyLog.value!;

                return TabBarView(
                  children: [
                    // FOODS LIST
                    log.yemekler.isEmpty
                        ? const Center(child: Text("Yemek yok."))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: log.yemekler.length,
                            itemBuilder: (context, index) {
                              final item =
                                  log.yemekler.reversed.toList()[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.fastfood,
                                      color: Colors.orange),
                                  title: Text(item['isim'] ?? 'İsimsiz'),
                                  subtitle: Text(
                                      "${item['miktar'] ?? ''} • ${item['kalori']} kcal"),
                                ),
                              );
                            },
                          ),

                    // ACTIVITIES LIST
                    log.aktiviteler.isEmpty
                        ? const Center(child: Text("Aktivite yok."))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: log.aktiviteler.length,
                            itemBuilder: (context, index) {
                              final item =
                                  log.aktiviteler.reversed.toList()[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.fitness_center,
                                      color: Colors.blue),
                                  title: Text(item['isim'] ?? 'Bilinmiyor'),
                                  subtitle: Text(
                                      "${item['sure_dk']} dakika • ${item['yakilan_kalori']} kcal"),
                                ),
                              );
                            },
                          ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
