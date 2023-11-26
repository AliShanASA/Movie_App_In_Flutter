import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/model/movie.dart';

class MovieService {
  static Future<List<Movie>> fetchMovies() async {
    const url =
        'https://api.themoviedb.org/3/account/20734507/favorite/movies?language=en-US&page=1&sort_by=created_at.asc';
    final uri = Uri.parse(url);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwN2FkZTliOTJmOTMwNTAyMTIwYjZiMGExNzVkNDVlNCIsInN1YiI6IjY1NWUwNjhjZTk0MmVlMDEzOGM2MWQzNSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.M_bwKDWPRFBf7CGCYRQTUCZvSSwaxiMJQFU4mCz_AVk',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final results = json['results'];

        List<Movie> moviesList = results.map<Movie>((e) {
          return Movie(
            title: e['original_title'],
            releaseDate: e['release_date'],
            overview: e['overview'],
            posterUrl: e['poster_path'],
          );
        }).toList();

        return moviesList;
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
    return [];
  }
}
