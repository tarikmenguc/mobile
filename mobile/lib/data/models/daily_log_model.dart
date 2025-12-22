class DailyLogModel {
  final String date;
  final int toplamKalori;
  final int suTuketimi;
  final List<dynamic> yemekler;
  final List<dynamic> aktiviteler;

  DailyLogModel({
    required this.date,
    required this.toplamKalori,
    required this.suTuketimi,
    required this.yemekler,
    required this.aktiviteler,
  });

  factory DailyLogModel.fromJson(Map<String, dynamic> json) {
    return DailyLogModel(
      date: json['date'] ?? '',
      toplamKalori: int.tryParse(json['toplam_kalori'].toString()) ?? 0,
      suTuketimi: int.tryParse(json['su_tuketimi_ml'].toString()) ?? 0,
      yemekler: json['yemekler'] ?? [],
      aktiviteler: (json['aktiviteler'] as List?)
              ?.map((e) => Activity.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Activity {
  final String isim;
  final int sureDk;
  final int yakilanKalori;

  Activity(
      {required this.isim, required this.sureDk, required this.yakilanKalori});

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      isim: json['isim'] ?? 'Bilinmeyen Aktivite',
      sureDk: int.tryParse(json['sure_dk'].toString()) ?? 0,
      yakilanKalori: int.tryParse(json['yakilan_kalori'].toString()) ?? 0,
    );
  }
}
