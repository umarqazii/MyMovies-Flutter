import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/movie_model.dart';
import '../../data/services/api_service.dart';

enum BrowseMode { trending, search, filter }

class BrowseController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // UI State
  var movies = <Movie>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs; // For bottom spinner

  // Logic State
  BrowseMode _currentMode = BrowseMode.trending;
  int _currentPage = 1;
  String _searchQuery = '';
  
  // Filter State
  var selectedYear = ''.obs;
  var selectedSort = 'popularity.desc'.obs;
  var selectedGenreId = 0.obs;
  Map<int, String> genreMap = {}; // Loaded on init

  // Scroll Controller
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _loadGenres();
    refreshMovies();

    // Listen to scroll to trigger pagination
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore.value) {
        loadMore();
      }
    });
  }

  Future<void> _loadGenres() async {
    genreMap = await _apiService.getGenres();
  }

  // --- Main Fetch Methods ---

  // Called when Pull-to-Refresh or initial load
  Future<void> refreshMovies() async {
    isLoading(true);
    _currentPage = 1;
    movies.clear();
    
    await _fetchData();
    isLoading(false);
  }

  // Called when scrolling down
  Future<void> loadMore() async {
    isLoadingMore(true);
    _currentPage++;
    await _fetchData();
    isLoadingMore(false);
  }

  // Internal Router to choose the right API call
  Future<void> _fetchData() async {
    List<Movie> newMovies = [];

    switch (_currentMode) {
      case BrowseMode.trending:
        newMovies = await _apiService.getTrendingMovies(page: _currentPage);
        break;
      case BrowseMode.search:
        newMovies = await _apiService.searchMovies(_searchQuery, page: _currentPage);
        break;
      case BrowseMode.filter:
        newMovies = await _apiService.discoverMovies(
          page: _currentPage,
          year: selectedYear.value.isEmpty ? null : selectedYear.value,
          sortBy: selectedSort.value,
          withGenres: selectedGenreId.value == 0 ? null : selectedGenreId.value.toString(),
        );
        break;
    }

    if (_currentPage == 1) {
      movies.assignAll(newMovies);
    } else {
      movies.addAll(newMovies);
    }
  }

  // --- Actions ---

  void onSearchChanged(String query) {
    if (query.isEmpty) {
      _currentMode = BrowseMode.trending;
      refreshMovies();
    } else {
      // Debounce logic can be added here, for now direct call
      _currentMode = BrowseMode.search;
      _searchQuery = query;
      refreshMovies();
    }
  }
  
  void applyFilters() {
    _currentMode = BrowseMode.filter;
    // Clear search query if we are filtering
    _searchQuery = ''; 
    Get.back(); // Close bottom sheet
    refreshMovies();
  }

  void resetFilters() {
    selectedYear.value = '';
    selectedSort.value = 'popularity.desc';
    selectedGenreId.value = 0;
    _currentMode = BrowseMode.trending;
    Get.back();
    refreshMovies();
  }
}