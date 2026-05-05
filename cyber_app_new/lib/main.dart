import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/landing_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool isLoggedIn = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future checkLogin() async {

    final prefs = await SharedPreferences.getInstance();

    isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

    setState(() {
      isLoading = false;
    });

  }

  @override
  Widget build(BuildContext context) {

    if(isLoading){

      return const MaterialApp(

        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),

      );

    }

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      theme: ThemeData.dark().copyWith(

        scaffoldBackgroundColor: const Color(0xff020617),
        primaryColor: Colors.greenAccent,

      ),

      home: const LandingScreen(),

    );

  }

}