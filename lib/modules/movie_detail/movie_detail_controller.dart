import 'package:get/get.dart';
import '../../data/models/movie_model.dart';
import '../../data/services/storage_service.dart';

class MovieDetailController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  
  // The movie passed from the previous screen
  late Movie movie;
  
  // Observables for UI state
  var isSeen = false.obs;
  var isWatchlist = false.obs;
  var userRating = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Get arguments passed from navigation
    if (Get.arguments is Movie) {
      movie = Get.arguments;
      checkLocalStatus();
    }
  }

  void checkLocalStatus() {
    // Check if this movie exists in our local DB
    final storedMovie = _storage.getMovie(movie.id);
    if (storedMovie != null) {
      // If it exists, use the stored data (it might have notes/ratings)
      movie = storedMovie;
      isSeen(movie.isSeen);
      isWatchlist(movie.isWatchlist);
      userRating(movie.myRating ?? 0.0);
    }
  }

  void toggleSeen() {
    isSeen.toggle();
    movie.isSeen = isSeen.value;
    _save();
  }

  void toggleWatchlist() {
    isWatchlist.toggle();
    movie.isWatchlist = isWatchlist.value;
    _save();
  }

  void updateRating(double rating) {
    userRating(rating);
    movie.myRating = rating;
    _save();
  }

  void _save() {
    _storage.saveMovie(movie);
    // Notify user lightly
    Get.rawSnackbar(message: "Saved", duration: const Duration(milliseconds: 800));
  }
}