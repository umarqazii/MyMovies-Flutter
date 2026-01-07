import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'browse_controller.dart';
import '../../global/widgets/movie_card.dart';
import '../../modules/movie_detail/movie_detail_view.dart';

class BrowseView extends StatelessWidget {
  const BrowseView({super.key});

  @override
  Widget build(BuildContext context) {
    final BrowseController controller = Get.put(BrowseController());

    return Scaffold(
      // Use AppBar for the Search Bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            onChanged: (val) {
              Future.delayed(const Duration(milliseconds: 500), () {
                 controller.onSearchChanged(val);
              });
            },
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Search TMDB...',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.movies.isEmpty) {
          // Wrap empty state in RefreshIndicator too so users can retry
          return RefreshIndicator(
            onRefresh: controller.refreshMovies,
            child: ListView(
              children: const [
                SizedBox(height: 200),
                Center(child: Text("No movies found.")),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              // --- ADDED REFRESH INDICATOR HERE ---
              child: RefreshIndicator(
                onRefresh: controller.refreshMovies,
                color: Colors.redAccent,
                backgroundColor: Colors.grey[900],
                child: GridView.builder(
                  // physics ensures you can pull down even if the list is short
                  physics: const AlwaysScrollableScrollPhysics(), 
                  controller: controller.scrollController, 
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: controller.movies.length,
                  itemBuilder: (context, index) {
                    return MovieCard(
                      movie: controller.movies[index],
                      onTap: () => Get.to(() => const MovieDetailView(), arguments: controller.movies[index]),
                    );
                  },
                ),
              ),
            ),
            // Bottom Loading Indicator for Pagination
            if (controller.isLoadingMore.value)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
          ],
        );
      }),
    );
  }

  // --- Filter UI Bottom Sheet (Unchanged) ---
  void _showFilterBottomSheet(BuildContext context, BrowseController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Filters", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const Divider(color: Colors.grey),
              
              const Text("Sort By", style: TextStyle(color: Colors.grey)),
              Obx(() => DropdownButton<String>(
                value: controller.selectedSort.value,
                dropdownColor: Colors.grey[800],
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'popularity.desc', child: Text("Most Popular")),
                  DropdownMenuItem(value: 'vote_average.desc', child: Text("Top Rated")),
                  DropdownMenuItem(value: 'primary_release_date.desc', child: Text("Newest Releases")),
                ],
                onChanged: (val) => controller.selectedSort.value = val!,
              )),
              
              const SizedBox(height: 10),

              const Text("Genre", style: TextStyle(color: Colors.grey)),
              Obx(() => DropdownButton<int>(
                value: controller.selectedGenreId.value,
                dropdownColor: Colors.grey[800],
                isExpanded: true,
                items: [
                   const DropdownMenuItem(value: 0, child: Text("All Genres")),
                   ...controller.genreMap.entries.map((e) => 
                     DropdownMenuItem(value: e.key, child: Text(e.value))
                   ),
                ],
                onChanged: (val) => controller.selectedGenreId.value = val!,
              )),

              const SizedBox(height: 10),

              const Text("Year", style: TextStyle(color: Colors.grey)),
              Obx(() => TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: controller.selectedYear.value.isEmpty ? "Enter Year (e.g. 2023)" : controller.selectedYear.value,
                ),
                onChanged: (val) => controller.selectedYear.value = val,
              )),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.resetFilters,
                      child: const Text("Reset"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: controller.applyFilters,
                      child: const Text("Apply"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}