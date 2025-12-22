class HealthReportModel {
  final String? id;
  final String aiAnalizMetni;
  final List<String> oneriler;
  final String? tarih;

  HealthReportModel({
    this.id,
    required this.aiAnalizMetni,
    required this.oneriler,
    this.tarih,
  });

  factory HealthReportModel.fromJson(Map<String, dynamic> json) {
    return HealthReportModel(
      id: json['_id'],
      aiAnalizMetni: json['ai_analiz_metni'] ?? '',
      oneriler:
          json['oneriler'] != null ? List<String>.from(json['oneriler']) : [],
      tarih: json['tarih'] ?? '',
    );
  }
}
