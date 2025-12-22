class UserModel {
  final String id;
  final String adSoyad;
  final String email;
  final int yas;
  final int kilo;
  final int boy;
  final String cinsiyet; // erkek/kadin
  final String hareketSeviyesi;
  final String hedef;
  final int bmr;

  UserModel({
    required this.id,
    required this.adSoyad,
    required this.email,
    required this.yas,
    required this.kilo,
    required this.boy,
    required this.cinsiyet,
    required this.hareketSeviyesi,
    required this.hedef,
    required this.bmr,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      adSoyad: json['ad_soyad'] ?? '',
      email: json['email'] ?? '',
      yas: json['yas'] ?? 0,
      kilo: json['kilo'] ?? 0,
      boy: json['boy'] ?? 0,
      cinsiyet: json['cinsiyet'] ?? 'erkek',
      hareketSeviyesi: json['hareket_seviyesi'] ?? 'az',
      hedef: json['hedef'] ?? 'korumak',
      bmr: json['bmr'] ?? 2000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'ad_soyad': adSoyad,
      'email': email,
      'yas': yas,
      'kilo': kilo,
      'boy': boy,
      'cinsiyet': cinsiyet,
      'hareket_seviyesi': hareketSeviyesi,
      'hedef': hedef,
      'bmr': bmr,
    };
  }
}
