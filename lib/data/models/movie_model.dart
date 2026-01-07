import 'package:hive/hive.dart';

part 'movie_model.g.dart'; // This will be generated later

@HiveType(typeId: 0)
class Movie extends HiveObject {
  @HiveField(0)
  final int id; // TMDB ID

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String posterPath;

  @HiveField(3)
  final String? releaseDate;

  @HiveField(4)
  final double tmdbRating; // TMDB Average

  @HiveField(5)
  final List<String> genres; // Store genre names

  @HiveField(6)
  final String overview;

  // --- User Personal Data ---
  
  @HiveField(7)
  double? myRating; // 1-10

  @HiveField(8)
  bool isSeen;

  @HiveField(9)
  bool isWatchlist;

  @HiveField(10)
  String? notes;

  @HiveField(11)
  final bool isManuallyAdded; // To distinguish TMDB vs Custom movies

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    this.releaseDate,
    required this.tmdbRating,
    required this.genres,
    required this.overview,
    this.myRating,
    this.isSeen = false,
    this.isWatchlist = false,
    this.notes,
    this.isManuallyAdded = false,
  });

  // Factory to create from TMDB JSON
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'],
      tmdbRating: (json['vote_average'] ?? 0.0).toDouble(),
      genres: [], // We will handle genre mapping separately
      overview: json['overview'] ?? '',
    );
  }
}