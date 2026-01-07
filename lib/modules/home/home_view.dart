import 'package:flutter/material.dart';
import '../browse/browse_view.dart';
import '../saved_movies/saved_movies_view.dart'; // Import the new view

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  // Define the screens
  final List<Widget> _screens = [
    const BrowseView(),
    // Pass the specific type for each tab
    const SavedMoviesView(type: SavedListType.seen),
    const SavedMoviesView(type: SavedListType.watchlist),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use IndexedStack to keep the state of the pages alive 
      // (so you don't lose your scroll position when switching tabs)
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Seen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Watchlist',
          ),
        ],
      ),
    );
  }
}