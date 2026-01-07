import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/movie_model.dart';

class StorageService extends GetxController {
  late Box<Movie> _box;

  Future<StorageService> init() async {
    _box = Hive.box<Movie>('moviesBox');
    return this;
  }

  // --- CREATE / UPDATE ---
  
  // Save or Update a movie
  Future<void> saveMovie(Movie movie) async {
    // We use the movie ID as the key for easy retrieval
    await _box.put(movie.id, movie);
    update();
  }

  // --- READ ---

  // Get all movies (for Seen/Watchlist tabs)
  List<Movie> getAllMovies() {
    return _box.values.toList();
  }

  // Get specific movie to check if it's already saved
  Movie? getMovie(int id) {
    return _box.get(id);
  }

  // Helper: Check if a movie is in Watchlist
  bool isWatchlist(int id) {
    final movie = _box.get(id);
    return movie?.isWatchlist ?? false;
  }

  // Helper: Check if a movie is Seen
  bool isSeen(int id) {
    final movie = _box.get(id);
    return movie?.isSeen ?? false;
  }

  // --- DELETE ---
  
  Future<void> deleteMovie(int id) async {
    await _box.delete(id);
  }
  
  // Clear all data (useful for settings/debugging)
  Future<void> clearAll() async {
    await _box.clear();
  }
}