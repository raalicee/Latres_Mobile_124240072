import 'dart:convert';
import 'package:http/http.dart' as http;
import 'show_model.dart';

/// [FITUR: API SERVICE]
/// Class ini bertugas menangani seluruh komunikasi jaringan (HTTP Request)
/// ke REST API TVMaze (https://www.tvmaze.com/api).

class ApiService {
  static const String baseUrl = 'https://api.tvmaze.com';

  /// 1. MENGAMBIL DAFTAR FILM / SHOWS (GET /shows)
  /// Digunakan pada HomeScreen untuk menampilkan grid daftar film.
  static Future<List<Show>> fetchShows() async {
    // Mengirim HTTP GET request ke URL: https://api.tvmaze.com/shows
    final response = await http.get(Uri.parse('$baseUrl/shows'));

    // Mengecek apakah server merespon dengan status code 200 (OK/Berhasil)
    if (response.statusCode == 200) {
      // Mengubah string mentah JSON menjadi List of dynamic Maps
      List<dynamic> body = jsonDecode(response.body);

      // Mapping setiap item JSON ke dalam objek Model `Show`
      return body.map((dynamic item) => Show.fromJson(item)).toList();
    } else {
      // Jika status code bukan 200 (misal: 404, 500), lempar error
      throw Exception('Gagal memuat daftar shows (Status: ${response.statusCode})');
    }
  }

  /// 2. MENGAMBIL DETAIL FILM BERDASARKAN ID (GET /shows/{id})
  /// Digunakan pada DetailScreen ketika pengguna menekan salah satu film.
  static Future<Show> fetchShowDetail(int id) async {
    // Mengirim HTTP GET request ke URL: https://api.tvmaze.com/shows/{id}
    final response = await http.get(Uri.parse('$baseUrl/shows/$id'));

    // Cek status code 200 (Berhasil)
    if (response.statusCode == 200) {
      // Mengubah JSON string menjadi Map dan langsung mem-parsing ke objek Show
      return Show.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal memuat detail show (Status: ${response.statusCode})');
    }
  }
}
