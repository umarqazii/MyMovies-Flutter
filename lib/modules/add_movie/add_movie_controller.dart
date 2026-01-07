import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/movie_model.dart';
import '../../data/services/storage_service.dart';
import 'dart:math';

class AddMovieController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();

  // Form Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController(); // acts as overview
  
  // State
  var selectedImagePath = ''.obs;
  var userRating = 0.0.obs;
  var isSeen = true.obs; // Default to seen

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImagePath.value = image.path;
    }
  }

void saveMovie() async {
    // 1. debug print to check if button works
    print("Save button pressed");

    // 2. Validate Title
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        "Required", 
        "Please enter a movie title", 
        backgroundColor: Colors.redAccent, 
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // 3. Generate ID
      final int newId = Random().nextInt(0xFFFFFFFF);

      // 4. Create Movie Object
      final newMovie = Movie(
        id: newId,
        title: titleController.text.trim(),
        posterPath: selectedImagePath.value, 
        overview: notesController.text.isEmpty ? "No description added." : notesController.text,
        tmdbRating: 0.0, 
        genres: ['Custom'],
        releaseDate: DateTime.now().toString().split(' ')[0],
        isManuallyAdded: true, 
        isSeen: isSeen.value,
        isWatchlist: !isSeen.value,
        myRating: userRating.value,
        notes: notesController.text,
      );

      print("Movie object created: ${newMovie.title}");

      // 5. Save to Hive
      await _storage.saveMovie(newMovie);
      print("Saved to Hive successfully");

      // 6. Close the screen
      Get.back();
      
      Get.snackbar("Success", "Movie added to library!");
      
    } catch (e) {
      // 7. CATCH ERRORS
      print("ERROR SAVING MOVIE: $e");
      Get.snackbar(
        "Error", 
        "Could not save movie: $e", 
        backgroundColor: Colors.red, 
        colorText: Colors.white
      );
    }
  }
}