class User {
  final int id;
  final String ad;
  final String soyad;
  final String eposta;

  User({required this.id, required this.ad, required this.soyad, required this.eposta});

  String get adSoyad => '$ad $soyad';

  factory User.fromJson(Map<String, dynamic> json) {
    final nameParts = (json['ad_soyad'] as String? ?? '').split(' ');
    return User(
      id: json['id'],
      ad: nameParts.isNotEmpty ? nameParts.first : '',
      soyad: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
      eposta: json['eposta'],
    );
  }
}
