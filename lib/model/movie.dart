class Movie {
  final String title;
  final String releaseDate;
  final String overview;
  final String posterUrl;
  bool isFavorite;

  Movie({
    required this.title,
    required this.releaseDate,
    required this.overview,
    required this.posterUrl,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'releaseDate': releaseDate,
      'overview': overview,
      'posterUrl': posterUrl,
      'isFavorite': isFavorite,
    };
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
      releaseDate: json['releaseDate'],
      overview: json['overview'],
      posterUrl: json['posterUrl'],
      isFavorite: json['isFavorite'],
    );
  }
}
