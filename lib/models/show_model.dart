class Show {
  final int id;
  final String name;
  final String? imageMedium;   
  final String? imageOriginal; 
  final double rating;
  final List<String> genres;
  final String summary;

  Show({
    required this.id,
    required this.name,
    this.imageMedium,
    this.imageOriginal,
    required this.rating,
    required this.genres,
    required this.summary,
  });

  /// --------------------------------------------------------------------------
  /// FACTORY CONSTRUCTOR: fromJson
  /// Membaca data Map JSON dari HTTP Response API TVMaze.
  /// Catatan penanganan null safety:
  /// - id: default 0 jika null
  /// - name: default 'No Title' jika null
  /// - image: di API berupa object {'medium': '...', 'original': '...'}
  /// - rating: di API berupa object {'average': 6.5}, harus dicek null-nya
  /// --------------------------------------------------------------------------
  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Title',
      // Mengambil link gambar dari nested object 'image'
      imageMedium: json['image']?['medium'],
      imageOriginal: json['image']?['original'],
      // Mengambil nilai rating 'average', jika null diset 0.0
      rating: (json['rating']?['average'] != null)
          ? (json['rating']['average'] as num).toDouble()
          : 0.0,
      // Mengambil daftar genre film (array string)
      genres: json['genres'] != null
          ? List<String>.from(json['genres'])
          : [],
      // Mengambil ringkasan/sinopsis film
      summary: json['summary'] ?? 'No summary available.',
    );
  }

  /// --------------------------------------------------------------------------
  /// toJson: Mengubah objek Show ke Map agar bisa disimpan ke database lokal Hive
  /// --------------------------------------------------------------------------
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageMedium': imageMedium,
        'imageOriginal': imageOriginal,
        'rating': rating,
        'genres': genres,
        'summary': summary,
      };

  /// --------------------------------------------------------------------------
  /// FACTORY CONSTRUCTOR: fromMap
  /// Membaca data yang sebelumnya disimpan di database lokal Hive (favoriteBox)
  /// --------------------------------------------------------------------------
  factory Show.fromMap(Map<dynamic, dynamic> map) {
    return Show(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      imageMedium: map['imageMedium'],
      imageOriginal: map['imageOriginal'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      genres: map['genres'] != null ? List<String>.from(map['genres']) : [],
      summary: map['summary'] ?? '',
    );
  }
}
