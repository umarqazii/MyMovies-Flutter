// lib/data/services/api_service.dart

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie_model.dart';

class ApiService extends GetxService {
  final Dio _dio = Dio();
  
  final String _apiKey = dotenv.env['TMDB_API_KEY']!;
  final String _baseUrl = dotenv.env['BASE_URL']!;


  Future<ApiService> init() async {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.queryParameters = {
      'api_key': _apiKey,
      'language': 'en-US',
      'include_adult': 'true', // Safety first
    };
    return this;
  }

  // Helper to standardise response
  List<Movie> _parseResponse(Response response) {
    if (response.statusCode == 200) {
      final List results = response.data['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    }
    return [];
  }

  // 1. Get Trending (Supports Pagination)
  Future<List<Movie>> getTrendingMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/trending/movie/week',
        queryParameters: {'page': page},
      );
      return _parseResponse(response);
    } catch (e) {
      print("Error fetching trending: $e");
      return [];
    }
  }

  // 2. Search (Supports Pagination)
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/search/movie',
        queryParameters: {'query': query, 'page': page},
      );
      return _parseResponse(response);
    } catch (e) {
      return [];
    }
  }

  // 3. Discover (For Filters: Genres, Year, Sort)
  Future<List<Movie>> discoverMovies({
    int page = 1,
    String? sortBy, // e.g., 'vote_average.desc'
    String? year,
    String? withGenres, // Comma separated IDs
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page};
      if (sortBy != null) params['sort_by'] = sortBy;
      if (year != null) params['primary_release_year'] = year;
      if (withGenres != null) params['with_genres'] = withGenres;

      final response = await _dio.get('/discover/movie', queryParameters: params);
      return _parseResponse(response);
    } catch (e) {
      return [];
    }
  }
  
  // 4. Get Genres List (For the Filter UI)
  Future<Map<int, String>> getGenres() async {
    try {
      final response = await _dio.get('/genre/movie/list');
      if (response.statusCode == 200) {
        final List genres = response.data['genres'];
        // Convert to Map {28: "Action", 35: "Comedy"}
        return {for (var g in genres) g['id']: g['name']};
      }
      return {};
    } catch (e) {
      return {};
    }
  }
}