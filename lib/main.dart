import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_clouds/models/styles.dart';
import 'package:flutter_music_clouds/screens/splash_screen.dart';
import 'package:flutter_music_clouds/widgets/colorScheme.dart';
import 'firebase_options.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Music Clouds',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.transparent,
          appBarTheme: const AppBarTheme(
            // set app bar icon's color
            iconTheme: IconThemeData(color: darkFontGrey),
            // Set elevation
            elevation: 0.0,
            backgroundColor: Colors.transparent,
          ),
          fontFamily: regular,
        ),
        home: const SplashScreen(),
      );
    }
}
