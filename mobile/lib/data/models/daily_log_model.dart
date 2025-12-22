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
      toplamKalori: json['toplam_kalori'] ?? 0,
      suTuketimi: json['su_tuketimi_ml'] ?? 0,
      yemekler: json['yemekler'] ?? [],
      aktiviteler: json['aktiviteler'] ?? [],
    );
  }
}
