import 'dart:io'; // <--- Added for File support
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/movie_model.dart';
import '../../data/services/storage_service.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({super.key, required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final StorageService storage = Get.find<StorageService>();

    // --- NEW LOGIC START ---
    // Determine which widget to show (Network Image vs Local File)
    Widget imageWidget;

    if (movie.isManuallyAdded && movie.posterPath.isNotEmpty) {
      // Case 1: Custom Movie with Local Image
      imageWidget = Image.file(
        File(movie.posterPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.white54),
        ),
      );
    } else if (movie.isManuallyAdded && movie.posterPath.isEmpty) {
      // Case 2: Custom Movie but NO Image selected
      imageWidget = Container(
        color: Colors.grey[800],
        child: const Icon(Icons.movie, size: 40, color: Colors.white24),
      );
    } else {
      // Case 3: TMDB Movie (Network Image)
      final posterUrl = 'https://image.tmdb.org/t/p/w500${movie.posterPath}';
      imageWidget = CachedNetworkImage(
        imageUrl: posterUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey[900]),
        errorWidget: (context, url, error) =>
            Container(color: Colors.grey[800], child: const Icon(Icons.error)),
      );
    }
    // --- NEW LOGIC END ---

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // 1. The Background Card
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageWidget, // <--- Use the variable we created above
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),

          // 2. The Quick Action Overlay (Top Right)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GetBuilder<StorageService>(
                builder: (controller) {
                  final isSeen = storage.isSeen(movie.id);
                  final isWatchlist = storage.isWatchlist(movie.id);

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Watchlist Button
                      InkWell(
                        onTap: () async {
                          movie.isWatchlist = !isWatchlist;
                          await storage.saveMovie(movie);

                          Get.snackbar(
                            "Updated",
                            "${movie.title} ${movie.isWatchlist ? 'added to' : 'removed from'} Watchlist",
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 1),
                            isDismissible: true,
                          );

                          controller.update();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            isWatchlist
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isWatchlist
                                ? Colors.blueAccent
                                : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      // Seen Button
                      InkWell(
                        onTap: () async {
                          if (isSeen) {
                            // CASE 1: REMOVING (Show Confirmation Dialog)
                            Get.dialog(
                              AlertDialog(
                                backgroundColor: Colors.grey[900],
                                title: const Text(
                                  "Remove from Seen?",
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: Text(
                                  "Are you sure you want to remove '${movie.title}' from your Seen history?",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(), // Cancel
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      // Confirm Removal
                                      movie.isSeen = false;
                                      await storage.saveMovie(movie);

                                      Get.back(); // Close Dialog
                                      controller.update(); // Refresh UI

                                      Get.snackbar(
                                        "Removed",
                                        "${movie.title} removed from Seen list",
                                        snackPosition: SnackPosition.BOTTOM,
                                        duration: const Duration(seconds: 1),
                                      );
                                    },
                                    child: const Text(
                                      "Remove",
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // CASE 2: ADDING (Do it immediately)
                            movie.isSeen = true;
                            await storage.saveMovie(movie);

                            controller.update(); // Refresh UI

                            Get.snackbar(
                              "Updated",
                              "${movie.title} marked as Seen",
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 1),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            isSeen
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: isSeen ? Colors.greenAccent : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
