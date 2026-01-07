import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mymovies/data/services/api_service.dart';
import 'package:mymovies/data/services/storage_service.dart';
import 'package:mymovies/modules/home/home_view.dart';
import 'data/models/movie_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");
  await Hive.initFlutter();
  Hive.registerAdapter(MovieAdapter());
  await Hive.openBox<Movie>('moviesBox');

  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => ApiService().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MyMovie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.redAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      // We will set up routes later, for now just a placeholder
      home: const HomeView(),
    );
  }
}