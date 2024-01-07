import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_tutorial/views/auth_screen/login_screen.dart';
// import 'package:firebase_tutorial/consts/consts.dart';
// import 'package:firebase_tutorial/views/home_screen/home.dart';
// import 'package:firebase_tutorial/views/widgets_common/applogo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_clouds/models/Const.dart';
import 'package:flutter_music_clouds/screens/LoginScreen.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Màn Splash 3s
  changeScreen() {
    Future.delayed(
      const Duration(seconds: 3),
      () {
        /// Su dung GetX
        // Get.to(() => const LoginScreen());
        auth.authStateChanges().listen((User? user) {
          if (user == null && mounted) {
            Get.to(() => const LoginScreen());
          } else {
            Get.to(() => const LoginScreen());
          }
        });
      },
    );
  }

  @override
  void initState() {
    changeScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      body: const Center(child: Text('Welcome to Music Clouds')),
    );
  }
}
