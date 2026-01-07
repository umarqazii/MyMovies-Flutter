import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mymovies/modules/add_movie/add_movie_view.dart';
import '../../data/models/movie_model.dart';
import '../../data/services/storage_service.dart';
import '../../global/widgets/movie_card.dart';
import '../movie_detail/movie_detail_view.dart';

enum SavedListType { seen, watchlist }

class SavedMoviesView extends StatefulWidget {
  final SavedListType type;
  
  const SavedMoviesView({super.key, required this.type});

  @override
  State<SavedMoviesView> createState() => _SavedMoviesViewState();
}

class _SavedMoviesViewState extends State<SavedMoviesView> {
  // Default sort order
  String _sortOption = 'Alphabetical'; 
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    // MOVED GetBuilder TO TOP: Allows us to calculate count for the AppBar
    return GetBuilder<StorageService>(
      builder: (storage) {
        // 1. Fetch and Filter by Type (Seen vs Watchlist)
        var allMovies = storage.getAllMovies();
        var typeList = allMovies.where((m) {
          return widget.type == SavedListType.seen ? m.isSeen : m.isWatchlist;
        }).toList();

        // 2. Calculate Total Count (Before search/sort)
        final int totalCount = typeList.length;
        
        // 3. Define Title with Count
        final String baseTitle = widget.type == SavedListType.seen ? "Seen" : "My Watchlist";
        final String fullTitle = "$baseTitle ($totalCount)";

        // 4. Apply Search Filter (for the body view)
        var displayList = List<Movie>.from(typeList);
        if (_searchQuery.isNotEmpty) {
          displayList = displayList.where((m) => 
            m.title.toLowerCase().contains(_searchQuery)
          ).toList();
        }

        // 5. Apply Sorting
        if (_sortOption == 'Alphabetical') {
          displayList.sort((a, b) => a.title.compareTo(b.title));
        } else if (_sortOption == 'My Rating') {
          displayList.sort((a, b) => (b.myRating ?? 0).compareTo(a.myRating ?? 0));
        } else if (_sortOption == 'TMDB Rating') {
          displayList.sort((a, b) => b.tmdbRating.compareTo(a.tmdbRating));
        } else {
          // Default: Date Added (Newest first)
          displayList = displayList.reversed.toList();
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: _isSearching 
              ? TextField(
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Search title...", 
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white54)
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.toLowerCase();
                    });
                  },
                )
              : Text(fullTitle), // <--- Using the new title with count
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) _searchQuery = ''; // Clear search on close
                  });
                },
              ),
              // Sorting Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (value) {
                  setState(() {
                    _sortOption = value;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'Date Added', child: Text('Date Added')),
                  const PopupMenuItem(value: 'My Rating', child: Text('My Rating')),
                  const PopupMenuItem(value: 'TMDB Rating', child: Text('TMDB Rating')),
                  const PopupMenuItem(value: 'Alphabetical', child: Text('A-Z')),
                ],
              ),
            ],
          ),
          body: displayList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.type == SavedListType.seen ? Icons.visibility_off : Icons.bookmark_border,
                        size: 64, color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty 
                            ? "No matching movies found." 
                            : (widget.type == SavedListType.seen ? "No movies seen yet." : "Your watchlist is empty."),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, 
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final movie = displayList[index];
                    return MovieCard(
                      movie: movie,
                      onTap: () {
                         Get.to(() => const MovieDetailView(), arguments: movie);
                      },
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.redAccent,
            child: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => const AddMovieView());
            },
          ),
        );
      },
    );
  }
}