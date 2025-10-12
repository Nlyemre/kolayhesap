import 'package:flutter/material.dart';

class Kategori {
  final String ad;
  final IconData ikon;

  final bool giderKategorisi;

  const Kategori({
    required this.ad,
    required this.ikon,

    required this.giderKategorisi,
  });
}

final List<Kategori> giderKategorileri = [
  const Kategori(
    ad: 'Market',
    ikon: Icons.shopping_cart,
    giderKategorisi: true,
  ),
  const Kategori(ad: 'Fatura', ikon: Icons.receipt, giderKategorisi: true),
  const Kategori(
    ad: 'Ulaşım',
    ikon: Icons.directions_car,
    giderKategorisi: true,
  ),
  const Kategori(ad: 'Eğlence', ikon: Icons.movie, giderKategorisi: true),
  const Kategori(ad: 'Restoran', ikon: Icons.restaurant, giderKategorisi: true),
  const Kategori(
    ad: 'Sağlık',
    ikon: Icons.medical_services,
    giderKategorisi: true,
  ),
  const Kategori(ad: 'Giyim', ikon: Icons.shopping_bag, giderKategorisi: true),
  const Kategori(ad: 'Eğitim', ikon: Icons.school, giderKategorisi: true),
  const Kategori(ad: 'Seyahat', ikon: Icons.flight, giderKategorisi: true),
  const Kategori(ad: 'Ev', ikon: Icons.home, giderKategorisi: true),
  const Kategori(ad: 'Spor', ikon: Icons.sports, giderKategorisi: true),
  const Kategori(ad: 'Kişisel Bakım', ikon: Icons.spa, giderKategorisi: true),
  const Kategori(
    ad: 'Hediye',
    ikon: Icons.card_giftcard,
    giderKategorisi: true,
  ),
  const Kategori(
    ad: 'Elektronik',
    ikon: Icons.electrical_services,

    giderKategorisi: true,
  ),
  const Kategori(ad: 'Sigorta', ikon: Icons.security, giderKategorisi: true),
  const Kategori(ad: 'Yatırım', ikon: Icons.trending_up, giderKategorisi: true),
  const Kategori(ad: 'Bağış', ikon: Icons.favorite, giderKategorisi: true),
  const Kategori(ad: 'Çocuk', ikon: Icons.child_care, giderKategorisi: true),
  const Kategori(ad: 'Pet', ikon: Icons.pets, giderKategorisi: true),
  const Kategori(ad: 'Diğer', ikon: Icons.more_horiz, giderKategorisi: true),
];

final List<Kategori> gelirKategorileri = [
  const Kategori(ad: 'Maaş', ikon: Icons.work, giderKategorisi: false),
  const Kategori(ad: 'Freelance', ikon: Icons.computer, giderKategorisi: false),
  const Kategori(
    ad: 'Yatırım Getirisi',
    ikon: Icons.trending_up,

    giderKategorisi: false,
  ),
  const Kategori(
    ad: 'Kira Geliri',
    ikon: Icons.home_work,
    giderKategorisi: false,
  ),
  const Kategori(
    ad: 'Hediye',
    ikon: Icons.card_giftcard,
    giderKategorisi: false,
  ),
  const Kategori(ad: 'Bonus', ikon: Icons.star, giderKategorisi: false),
  const Kategori(ad: 'Satış', ikon: Icons.sell, giderKategorisi: false),
  const Kategori(ad: 'Faiz', ikon: Icons.money, giderKategorisi: false),
  const Kategori(ad: 'Bağış', ikon: Icons.favorite, giderKategorisi: false),
  const Kategori(ad: 'Diğer', ikon: Icons.more_horiz, giderKategorisi: false),
];
