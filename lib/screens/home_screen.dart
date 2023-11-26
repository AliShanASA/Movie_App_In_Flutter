import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:movie_app/model/movie.dart';
import 'package:movie_app/screens/favorite_movie_screen.dart';
import 'package:movie_app/service/movie_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movie>> futureMovies;
  int favoriteCount = 0;
  List<Movie> favoriteMovies = [];

  @override
  void initState() {
    super.initState();
    futureMovies = MovieService.fetchMovies();
    _loadFavoriteCount();
  }

  Future<void> _loadFavoriteCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteCount = prefs.getInt('favoriteCount') ?? 0;
    });
  }

  Future<void> _saveFavoriteCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('favoriteCount', favoriteCount);
  }

  Future<void> _saveFavoriteData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('favoriteCount', favoriteCount);
    _saveFavoriteMoviesToPrefs(prefs);
  }

  void _saveFavoriteMoviesToPrefs(SharedPreferences prefs) {
    for (int i = 0; i < favoriteMovies.length; i++) {
      String key = 'favoriteMovie_$i';
      String movieJson = jsonEncode(favoriteMovies[i].toJson());
      prefs.setString(key, movieJson);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movies',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoriteMoviesScreen(
                      favoriteCount: favoriteCount,
                    ),
                  ));
            },
            icon: Stack(
              children: [
                const Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 40, 78, 41),
                    radius: 8,
                    child: Text(
                      favoriteCount.toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Movie>>(
        future: futureMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No movies found.'),
            );
          } else {
            return movieListWidget(snapshot.data!);
          }
        },
      ),
    );
  }

  Widget movieListWidget(List<Movie> movies) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 170).floor();
    double aspectRatio;
    if (screenWidth > 500) {
      aspectRatio = screenWidth / (crossAxisCount * 360);
    } else {
      aspectRatio = screenWidth / (crossAxisCount * 330);
    }

    return Container(
      margin: const EdgeInsets.all(8),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 10,
          childAspectRatio: aspectRatio,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w500${movies[index].posterUrl}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        movies[index].title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
          
                      // Release Date
                      Text(
                        'Release Date: ${movies[index].releaseDate}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
          
                      // Shortened Overview
                      Text(
                        'Overview: ${_truncateOverview(movies[index].overview)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Expand Icon
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  IconButton(
                    icon: const Icon(Icons.expand_more),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Overview'),
                            content: Text(movies[index].overview),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      movies[index].isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: movies[index].isFavorite ? Colors.green : null,
                    ),
                    onPressed: () {
                      setState(() {
                        movies[index].isFavorite = !movies[index].isFavorite;
                        _updateFavoriteCount(
                            movies[index].isFavorite, movies[index]);
                      });
                    },
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  String _truncateOverview(String overview) {
    return overview.length > 20 ? '${overview.substring(0, 20)}...' : overview;
  }

  void _updateFavoriteCount(bool isFavorite, Movie movie) {
    setState(() {
      favoriteCount += isFavorite ? 1 : -1;
      if (isFavorite) {
        favoriteMovies.add(movie);
      } else {
        favoriteMovies.removeWhere((m) => m.title == movie.title);
      }
    });
    _saveFavoriteCount();
    _saveFavoriteData();
  }
}
