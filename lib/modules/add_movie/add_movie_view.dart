import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'add_movie_controller.dart';

class AddMovieView extends StatelessWidget {
  const AddMovieView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddMovieController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Custom Movie"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Picker
            Center(
              child: GestureDetector(
                onTap: controller.pickImage,
                child: Obx(() {
                  bool hasImage = controller.selectedImagePath.value.isNotEmpty;
                  return Container(
                    width: 150,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                      image: hasImage 
                        ? DecorationImage(
                            image: FileImage(File(controller.selectedImagePath.value)),
                            fit: BoxFit.cover
                          )
                        : null,
                    ),
                    child: hasImage 
                      ? null 
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.white54),
                            SizedBox(height: 8),
                            Text("Add Poster", style: TextStyle(color: Colors.white54)),
                          ],
                        ),
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 30),

            // 2. Title Input
            TextField(
              controller: controller.titleController,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                labelText: "Movie Title",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.movie),
              ),
            ),

            const SizedBox(height: 20),

            // 3. Status Toggle (Seen / Watchlist)
            Obx(() => Row(
              children: [
                const Text("Status: ", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("Seen"),
                  selected: controller.isSeen.value,
                  onSelected: (val) => controller.isSeen.value = true,
                  selectedColor: Colors.redAccent,
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("Watchlist"),
                  selected: !controller.isSeen.value,
                  onSelected: (val) => controller.isSeen.value = false,
                  selectedColor: Colors.blueAccent,
                ),
              ],
            )),

            const SizedBox(height: 20),

            // 4. Rating (Only visible if Seen)
            Obx(() {
              if (!controller.isSeen.value) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("My Rating", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    itemCount: 10,
                    itemSize: 30,
                    itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (rating) => controller.userRating.value = rating,
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),

            // 5. Notes / Overview
            TextField(
              controller: controller.notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Notes / Description",
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            // 6. Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: controller.saveMovie,
                icon: const Icon(Icons.save),
                label: const Text("Save Movie", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}