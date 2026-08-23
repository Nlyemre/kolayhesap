class IslemModel {
  final String id;
  final String baslik;
  final double miktar;
  final DateTime tarih;
  final String kategori;
  final bool giderMi;
  final String? not;

  IslemModel({
    required this.id,
    required this.baslik,
    required this.miktar,
    required this.tarih,
    required this.kategori,
    required this.giderMi,
    this.not,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baslik': baslik,
      'miktar': miktar,
      'tarih': tarih.toIso8601String(),
      'kategori': kategori,
      'giderMi': giderMi,
      'not': not,
    };
  }

  factory IslemModel.fromMap(Map<String, dynamic> map) {
    try {
      final miktar = (map['miktar'] as num).toDouble();
      if (miktar <= 0) throw Exception('Miktar pozitif olmalı');

      final tarih = DateTime.parse(map['tarih'].toString());
      final now = DateTime.now();

      if (tarih.isAfter(now)) {
        throw Exception('Gelecek tarihli işlem olamaz');
      }

      return IslemModel(
        id:
            map['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        baslik: map['baslik']?.toString() ?? '',
        miktar: miktar,
        tarih: tarih,
        kategori: map['kategori']?.toString() ?? 'Diğer',
        giderMi: map['giderMi'] == true,
        not: map['not']?.toString(),
      );
    } catch (e) {
      throw Exception('IslemModel oluşturulamadı: $e');
    }
  }
}
