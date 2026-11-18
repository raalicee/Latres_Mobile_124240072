import 'package:flutter/material.dart';
import '../models/show_model.dart';
import '../models/api_service.dart';
import 'detail_screen.dart';

/// Menampilkan daftar film dalam bentuk 2-column GridView secara dinamis dari REST API TVMaze
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variabel penampung hasil pemanggilan data API secara asynchronous
  late Future<List<Show>> futureShows;

  @override
  void initState() {
    super.initState();
    // Memanggil API saat pertama kali halaman dibuka
    futureShows = ApiService.fetchShows();
  }

  /// [FITUR: PULL TO REFRESH]
  /// Fungsi untuk memuat ulang daftar film saat user menarik layar ke bawah
  Future<void> _refreshShows() async {
    setState(() {
      futureShows = ApiService.fetchShows();
    });
    await futureShows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [PENYESUAIAN WARNA] Background layar utama 
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Menghilangkan tombol back default
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Skuy Nonton!',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      // [FITUR: FUTURE BUILDER]
      // Menghandle 3 kondisi: Loading, Error, dan Data Berhasil Dimuat
      body: FutureBuilder<List<Show>>(
        future: futureShows,
        builder: (context, snapshot) {
          // 1. KONDISI LOADING: Saat aplikasi masih menunggu respon dari API
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            );
          }
          // 2. KONDISI ERROR: Jika jaringan gagal atau endpoint bermasalah
          else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi Kesalahan: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          // 3. KONDISI KOSONG: Jika respon berhasil namun datanya kosong
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Tidak ada data', style: TextStyle(color: Colors.white)),
            );
          }

          // 4. KONDISI BERHASIL: Data film sudah siap ditampilkan
          final shows = snapshot.data!;

          // [PERHITUNGAN ASPEK RASIO GRID AGAR GAMBAR TIDAK TERPOTONG & TIDAK KEBESARAN]
          final screenWidth = MediaQuery.of(context).size.width;
          const double horizontalPadding = 14; 
          const double crossAxisSpacing = 14;  
          // Lebar masing-masing card di layar
          final double cardWidth =
              (screenWidth - (horizontalPadding * 2) - crossAxisSpacing) / 2;

          const double posterAspectRatio = 210 / 295;
          final double imageHeight = cardWidth / posterAspectRatio;

          const double infoHeight = 58;

          final double totalCardHeight = imageHeight + infoHeight;

          final double childAspectRatio = cardWidth / totalCardHeight;

          return RefreshIndicator(
            color: const Color(0xFFE50914), // Warna putaran loading refresh (Merah)
            backgroundColor: const Color(0xFF1E1E1E),
            onRefresh: _refreshShows,
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: 8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // [PENYESUAIAN] Jumlah kolom (2 kolom)
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: 14, // Jarak vertikal antar baris card
              ),
              itemCount: shows.length,
              itemBuilder: (context, index) {
                final show = shows[index];
                return GestureDetector(
                  // [FITUR: NAVIGASI KE DETAIL SCREEN]
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(showId: show.id),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C), // Warna kartu abu-abu charcoal
                      borderRadius: BorderRadius.circular(16), // Sudut melengkung
                    ),
                    clipBehavior: Clip.antiAlias, // Memotong gambar agar mengikuti lekukan card
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // [FITUR: POSTER FILM DENGAN INDIKATOR LOADING GAMBAR]
                        AspectRatio(
                          aspectRatio: posterAspectRatio,
                          child: show.imageMedium != null
                              ? Image.network(
                                  show.imageMedium!,
                                  fit: BoxFit.cover,
                                  // Loading builder saat file gambar sedang diunduh
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: const Color(0xFF242424),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: const Color(0xFFE50914),
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  // Tampilan jika link gambar gagal dibuka/error
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: const Color(0xFF383838),
                                    child: const Icon(Icons.movie,
                                        color: Colors.grey),
                                  ),
                                )
                              : Container(
                                  color: const Color(0xFF383838),
                                  child: const Icon(Icons.movie,
                                      color: Colors.grey),
                                ),
                        ),
                        // [FITUR: TEKS INFO (JUDUL & RATING BINTANG)]
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Judul Film (1 baris dengan titik-titik jika panjang)
                              Text(
                                show.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Baris Rating Bintang Kuning
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    show.rating > 0
                                        ? show.rating.toString()
                                        : '-',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
