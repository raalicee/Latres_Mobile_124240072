import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/show_model.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Box favoriteBox;

  @override
  void initState() {
    super.initState();
    // Membuka reference ke box Hive 'favorites'
    favoriteBox = Hive.box('favorites');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Daftar Favorit',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      // [FITUR: VALUE LISTEN ABLE BUILDER]
      // Mendengarkan setiap perubahan (tambah, edit, hapus) pada database Hive
      body: ValueListenableBuilder(
        valueListenable: favoriteBox.listenable(),
        builder: (context, Box box, _) {
          // Kondisi jika database favorit masih kosong
          if (box.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada favorit.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          // Menampilkan daftar favorit dalam ListView
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              // Mengambil data dari Hive berdasarkan index
              var showData = box.getAt(index);
              // Mengubah kembali data Map dari Hive ke model Show
              Show show = Show.fromMap(Map.from(showData));

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  // Thumbnail gambar film
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: show.imageMedium != null
                        ? Image.network(
                            show.imageMedium!,
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                          )
                        : Container(width: 50, color: Colors.grey),
                  ),
                  // Judul film
                  title: Text(
                    show.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Rating bintang
                  subtitle: Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        show.rating > 0 ? show.rating.toString() : '-',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  // [FITUR: HAPUS DARI FAVORIT]
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      // Menghapus data dari Hive berdasarkan key (show.id)
                      box.delete(show.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dihapus dari Favorit'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  // Navigasi ke DetailScreen saat item ditekan
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(showId: show.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
