class FoodModel {
  final String isim;
  final int kalori;
  final String miktar;
  final Map<String, dynamic> makrolar;

  FoodModel({
    required this.isim,
    required this.kalori,
    required this.miktar,
    required this.makrolar,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      isim: json['isim'] ?? 'Bilinmeyen',
      kalori: json['kalori'] ?? 0,
      miktar: json['miktar'] ?? '1 Porsiyon',
      makrolar: json['makrolar'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isim': isim,
      'kalori': kalori,
      'miktar': miktar,
      'makrolar': makrolar,
    };
  }
}
