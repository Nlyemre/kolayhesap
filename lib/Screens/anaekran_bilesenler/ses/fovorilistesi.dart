import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';

class FavoriListesi extends StatefulWidget {
  final List<Map<String, dynamic>> favorites;
  final Function(Map<String, dynamic>) onFavoriteSelected;
  final Function(int) onFavoriteDeleted;

  const FavoriListesi({
    super.key,
    required this.favorites,
    required this.onFavoriteSelected,
    required this.onFavoriteDeleted,
  });

  @override
  State<FavoriListesi> createState() => _FavoriListesiState();
}

class _FavoriListesiState extends State<FavoriListesi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favori Listesi"),

        leading: const BackButton(color: Renk.pastelKoyuMavi),
      ),
      body:
          widget.favorites.isEmpty
              ? const Center(child: Text('Henüz favori eklenmedi'))
              : Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: widget.favorites.length,
                        separatorBuilder: (context, index) {
                          if (widget.favorites.length > 2 && index == 1) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: RepaintBoundary(child: YerelReklamiki()),
                            );
                          }
                          return const SizedBox(height: 1);
                        },
                        itemBuilder: (context, index) {
                          final fav = widget.favorites[index];
                          return _buildFavoriteKard(fav, index);
                        },
                      ),
                    ),
                  ),
                  const RepaintBoundary(child: BannerReklamiki()),
                ],
              ),
    );
  }

  Widget _buildFavoriteKard(Map<String, dynamic> fav, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: CizgiliCerceve(
        golge: 5,
        backgroundColor: Renk.acikgri,
        child: GestureDetector(
          onTap: () {
            widget.onFavoriteSelected(fav);
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        fav['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Renk.pastelKoyuMavi,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Color.fromARGB(166, 244, 67, 54),
                      ),
                      onPressed: () {
                        // Silme işlemi ve state güncelleme
                        setState(() {
                          widget.onFavoriteDeleted(index);
                        });
                      },
                    ),
                  ],
                ),

                _buildDetailRow(
                  Icons.waves,
                  'Frekans',
                  '${fav['frequency'].toStringAsFixed(1)} Hz',
                ),
                _buildDetailRow(
                  Icons.volume_up,
                  'Ses Seviyesi',
                  '${fav['volume'].toStringAsFixed(0)}%',
                ),
                _buildDetailRow(
                  Icons.timer,
                  'Süre',
                  '${fav['duration'].toStringAsFixed(0)} sn',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Renk.pastelKoyuMavi),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
