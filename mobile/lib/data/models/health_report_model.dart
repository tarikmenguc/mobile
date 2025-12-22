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
      id: json['_id']?.toString(), // Güvenli dönüşüm
      aiAnalizMetni: json['ai_analiz_metni']?.toString() ?? '',
      oneriler: json['oneriler'] != null
          ? (json['oneriler'] as List).map((e) => e.toString()).toList()
          : [],
      tarih: json['tarih']?.toString() ?? '',
    );
  }
}
