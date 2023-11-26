import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/movie.dart';

class FavoriteMoviesScreen extends StatefulWidget {
  final int favoriteCount;

  const FavoriteMoviesScreen({
    Key? key,
    required this.favoriteCount,
  }) : super(key: key);

  @override
  State<FavoriteMoviesScreen> createState() => FavoriteMoviesScreenState();
}

class FavoriteMoviesScreenState extends State<FavoriteMoviesScreen> {
  List<Movie> favoriteMovies = [];
  int favoriteCount = 0;

  @override
  void initState() {
    super.initState();
    favoriteCount = widget.favoriteCount;
    _loadFavoriteMoviesFromPrefs();
  }

  Future<void> _loadFavoriteMoviesFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      favoriteMovies = _loadFavoriteMovies(prefs);
    });
  }

  List<Movie> _loadFavoriteMovies(SharedPreferences prefs) {
    List<Movie> favoriteMovies = [];
    for (int i = 0; i < favoriteCount; i++) {
      String key = 'favoriteMovie_$i';
      String movieJson = prefs.getString(key) ?? '';
      if (movieJson.isNotEmpty) {
        Map<String, dynamic> movieData = jsonDecode(movieJson);
        favoriteMovies.add(Movie.fromJson(movieData));
      }
    }
    return favoriteMovies;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorite Movies',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: favoriteMovies.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Row(
              children: [
                // Image on the left side
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://image.tmdb.org/t/p/w500${favoriteMovies[index].posterUrl}',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Add some spacing
                // Title in the center
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        favoriteMovies[index].title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Add Spacer to push the release date to the hard right
                // Release Date on the hard right
                const Spacer(),

                Column(
                  children: [
                    const Text(
                      'Release Date',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      favoriteMovies[index].releaseDate,
                      style: const TextStyle(fontSize: 12),
                    )
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
