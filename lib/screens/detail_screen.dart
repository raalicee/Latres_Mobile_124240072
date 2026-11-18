import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/show_model.dart';
import '../models/api_service.dart';

class DetailScreen extends StatefulWidget {
  final int showId; // Menerima parameter ID film dari halaman pemanggil
  const DetailScreen({super.key, required this.showId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Show> futureShowDetail;
  bool isFavorite = false; // Status apakah film ini sudah ada di favorit
  late Box favoriteBox;

  @override
  void initState() {
    super.initState();
    // Memanggil API detail film berdasarkan ID
    futureShowDetail = ApiService.fetchShowDetail(widget.showId);
    // Mengakses box database Hive 'favorites'
    favoriteBox = Hive.box('favorites');
    // Mengecek apakah film ini sudah pernah difavoritkan sebelumnya
    checkFavorite();
  }

  /// [FITUR: CEK STATUS FAVORIT DI HIVE]
  /// Mengecek apakah ID film ada dalam key box favorites
  void checkFavorite() {
    setState(() {
      isFavorite = favoriteBox.containsKey(widget.showId);
    });
  }

  /// [FITUR: TAMBAH / HAPUS FAVORIT (TOGGLE HIVE)]
  /// - Jika sudah ada di favorit: hapus data dari Hive.
  /// - Jika belum ada: simpan data film (toJson) ke Hive dengan key ID film.
  void toggleFavorite(Show show) {
    if (isFavorite) {
      favoriteBox.delete(widget.showId); // Menghapus dari database lokal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dihapus dari Favorit'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      favoriteBox.put(widget.showId, show.toJson()); // Menyimpan ke database lokal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ditambahkan ke Favorit'),
          duration: Duration(seconds: 1),
        ),
      );
    }
    checkFavorite(); // Update tampilan ikon hati
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      // FutureBuilder untuk memuat data detail film dari API
      body: FutureBuilder<Show>(
        future: futureShowDetail,
        builder: (context, snapshot) {
          // Kondisi 1: Loading API
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            );
          }
          // Kondisi 2: Error API
          else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          // Kondisi 3: Data kosong
          else if (!snapshot.hasData) {
            return const Center(
              child: Text('Data tidak ditemukan',
                  style: TextStyle(color: Colors.white)),
            );
          }

          final show = snapshot.data!;

          // Menggunakan CustomScrollView agar tampilan header gambar dapat bergeser elegan (Sliver)
          return CustomScrollView(
            slivers: [
              // Header gambar poster ukuran besar (imageOriginal)
              SliverAppBar(
                backgroundColor: const Color(0xFF121212),
                iconTheme: const IconThemeData(color: Colors.white),
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: show.imageOriginal != null
                      ? Image.network(
                          show.imageOriginal!,
                          fit: BoxFit.cover,
                        )
                      : Container(color: Colors.grey),
                ),
              ),
              // Bagian Konten Rincian Film
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Film
                      Text(
                        show.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Rating Bintang
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            show.rating > 0 ? show.rating.toString() : '-',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Daftar Genre Film (dipisahkan dengan koma)
                      Text(
                        show.genres.isNotEmpty
                            ? show.genres.join(', ')
                            : 'Genre: -',
                        style: const TextStyle(color: Color(0xFFE50914)),
                      ),
                      const SizedBox(height: 16),

                      // Baris Tombol Aksi (Tombol Nonton & Tombol Favorit)
                      Row(
                        children: [
                          // Tombol Nonton
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE50914),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {},
                              icon: const Icon(Icons.play_arrow,
                                  color: Colors.white),
                              label: const Text(
                                'Nonton',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Tombol Ikon Favorit (Toggle Simpan/Hapus di Hive)
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF1E1E1E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                            ),
                            onPressed: () => toggleFavorite(show),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Judul Bagian Sinopsis
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Sinopsis Film
                      // [CATATAN RESPONSI]: Di API TVMaze, field 'summary' berisi tag HTML. Regex di bawah berfungsi membersihkan tag HTML tsb.
                      Text(
                        show.summary.replaceAll(RegExp(r'<[^>]*>'), ''),
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
