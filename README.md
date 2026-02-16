# MyMovies

A Flutter app for discovering movies from **The Movie Database (TMDB)** and keeping track of what you’ve seen and what you want to watch. You can browse and search TMDB, save movies to Seen or Watchlist, rate and add notes, and even add custom movies that aren’t on TMDB.

---

## Features

### Browse
- **Trending** — Weekly trending movies from TMDB (default tab).
- **Search** — Search TMDB by title with debounced input.
- **Filters** — Sort by Most Popular, Top Rated, or Newest Releases; filter by genre and year; toggle **Include adult content** on or off. Filters are applied via a bottom sheet (filter icon in the app bar).
- **Pagination** — Infinite scroll and pull-to-refresh.

### Movie detail
- Poster (TMDB image or local file for custom movies), title, release date, overview.
- **Seen** / **Watchlist** — Mark as seen or add to watchlist; state is persisted locally.
- **My rating** — Personal 1–10 rating with a star control.
- **Notes** — Optional notes stored with the movie.

### Saved lists (bottom nav)
- **Seen** — All movies you’ve marked as seen.
- **Watchlist** — Movies you want to watch.
- **Search** — Filter saved movies by title.
- **Sort** — Alphabetical, My Rating, TMDB Rating, or Date Added.

### Add custom movie
- Add movies not on TMDB: poster (image picker), title, release date, your rating, and notes.
- Custom entries appear in Seen/Watchlist and movie detail like TMDB movies, with local poster and “Custom Entry” where TMDB rating would be.

---

## Tech stack

| Area | Technology |
|------|------------|
| **Framework** | Flutter (Dart 3.10+) |
| **State management & routing** | [GetX](https://pub.dev/packages/get) — reactive state (`Obx`), dependency injection (`Get.put`, `Get.find`), navigation |
| **HTTP** | [Dio](https://pub.dev/packages/dio) — TMDB API calls |
| **Local storage** | [Hive](https://pub.dev/packages/hive) — offline persistence for saved movies (Seen, Watchlist, ratings, notes) |
| **Environment** | [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) — API key and base URL from `.env` |
| **UI** | Material Design (dark theme), [cached_network_image](https://pub.dev/packages/cached_network_image), [flutter_rating_bar](https://pub.dev/packages/flutter_rating_bar), [image_picker](https://pub.dev/packages/image_picker) |

---

## Project structure

```
lib/
├── main.dart                 # App entry, Hive/GetX init, .env load
├── data/
│   ├── models/
│   │   └── movie_model.dart  # Movie model (TMDB + local fields), Hive adapter
│   └── services/
│       ├── api_service.dart  # TMDB API (trending, search, discover, genres)
│       └── storage_service.dart  # Hive CRUD for saved movies
├── global/
│   └── widgets/
│       └── movie_card.dart   # Grid card (poster, title, rating)
└── modules/
    ├── home/
    │   └── home_view.dart    # Bottom nav (Browse | Seen | Watchlist)
    ├── browse/
    │   ├── browse_view.dart  # Search, filters, grid, pull-to-refresh
    │   └── browse_controller.dart
    ├── movie_detail/
    │   ├── movie_detail_view.dart
    │   └── movie_detail_controller.dart
    ├── saved_movies/
    │   └── saved_movies_view.dart  # Seen / Watchlist lists
    └── add_movie/
        ├── add_movie_view.dart
        └── add_movie_controller.dart
```

---

## Setup

1. **Clone and install**
   ```bash
   cd MyMovies-Flutter
   flutter pub get
   ```

2. **TMDB API key**
   - Get an API key from [TMDB](https://www.themoviedb.org/settings/api).
   - Create `assets/.env` with:
     ```env
     TMDB_API_KEY=your_api_key_here
     BASE_URL=https://api.themoviedb.org/3
     ```
   - Ensure `assets/.env` is listed under `flutter.assets` in `pubspec.yaml` (it is by default).

3. **Run**
   ```bash
   flutter run
   ```
