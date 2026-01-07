import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'movie_detail_controller.dart';

class MovieDetailView extends StatelessWidget {
  const MovieDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MovieDetailController());
    final movie = controller.movie;

    // --- NEW LOGIC START ---
    // Decide which image widget to show in the header
    Widget headerImage;

    if (movie.isManuallyAdded && movie.posterPath.isNotEmpty) {
      // Case 1: Custom Movie (Local File)
      headerImage = Image.file(
        File(movie.posterPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[900],
          child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.white24)),
        ),
      );
    } else if (movie.isManuallyAdded && movie.posterPath.isEmpty) {
      // Case 2: Custom Movie (No Image)
      headerImage = Container(
        color: Colors.grey[900],
        child: const Center(child: Icon(Icons.movie, size: 60, color: Colors.white24)),
      );
    } else {
      // Case 3: TMDB Movie (Network)
      headerImage = CachedNetworkImage(
        imageUrl: 'https://image.tmdb.org/t/p/w500${movie.posterPath}',
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.black),
        errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
      );
    }
    // --- NEW LOGIC END ---

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Parallax Header with Poster
          SliverAppBar(
            expandedHeight: 400.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Use the widget we determined above
                  headerImage,
                  
                  // Gradient for text readability
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Buttons Row
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: Icons.check_circle,
                        label: "Seen",
                        isActive: controller.isSeen.value,
                        onTap: controller.toggleSeen,
                        activeColor: Colors.greenAccent,
                      ),
                      _ActionButton(
                        icon: Icons.bookmark,
                        label: "Watchlist",
                        isActive: controller.isWatchlist.value,
                        onTap: controller.toggleWatchlist,
                        activeColor: Colors.blueAccent,
                      ),
                    ],
                  )),
                  
                  const Divider(height: 30, color: Colors.grey),

                  // Overview
                  const Text("Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(movie.overview, style: const TextStyle(color: Colors.white70, height: 1.5)),
                  
                  const SizedBox(height: 20),

                  // Release Date & TMDB Rating
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(movie.releaseDate ?? 'Unknown Date', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 20),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 5),
                      // Conditional text for TMDB rating (Custom movies have 0.0)
                      Text(
                         movie.isManuallyAdded ? "Custom Entry" : "TMDB: ${movie.tmdbRating}", 
                         style: const TextStyle(color: Colors.grey)
                      ),
                    ],
                  ),

                  const Divider(height: 30, color: Colors.grey),

                  // Personal Rating Section
                  const Text("My Rating", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Center(
                    child: Obx(() => RatingBar.builder(
                      initialRating: controller.userRating.value,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 10, // 1-10 Scale
                      itemSize: 25,
                      itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) {
                        controller.updateRating(rating);
                      },
                    )),
                  ),
                  
                  const SizedBox(height: 50), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widget for Buttons (Unchanged)
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;

  const _ActionButton({
    required this.icon, required this.label, required this.isActive, required this.onTap, required this.activeColor
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? activeColor.withOpacity(0.2) : Colors.grey[800],
        foregroundColor: isActive ? activeColor : Colors.white,
      ),
      icon: Icon(icon, color: isActive ? activeColor : Colors.white),
      label: Text(label),
    );
  }
}