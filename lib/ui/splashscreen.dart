import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:gallery/ui/home.dart';

class Splash extends StatelessWidget {
  const Splash({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: AnimatedSplashScreen(
            splash: const Icon(Icons.home_filled, size: 200,), nextScreen: const Home(),
            ),
        ),
      ),
    );
  }
}