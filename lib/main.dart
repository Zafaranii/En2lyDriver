import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:en2lydriver/Models/driver_model.dart';
import 'package:en2lydriver/Screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Models/customer_model.dart';
import 'Screens/map_screen.dart';
import 'Screens/tst0.dart';
import 'Screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print('Firebase initialized successfully');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), // Start with the SplashScreen
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3)); // Show splash screen for 3 seconds
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Landing1Page()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/logo.png', // Add your image here
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              const Text(
                'انقلي',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Landing1Page extends StatelessWidget {
  Landing1Page({super.key});

  // Check if the user is logged in and fetch driver data
  Future<Driver?> _getLoggedInDriver() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch driver data
      final snapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();
        return Driver.New(
          firstName: data?['firstName'] ?? '',
          lastName: data?['lastName'] ?? '',
          regNumber: data?['regNumber'] ?? '',
          idNumber: data?['idNumber'] ?? '',
          carType: data?['carType'] ?? '',
          carModel: data?['carModel'] ?? '',
          driverId : user.uid,
          phoneNumber: data?['phoneNumber'] ?? ''
        );
      }
    }

    return null; // User is not logged in or no data found
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<Driver?>(
        future: _getLoggedInDriver(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Log the error for debugging
            print('Error fetching driver data: ${snapshot.error}');
            return const LandingPage(); // Redirect to login/landing page
          }

          final driver = snapshot.data;
          if (driver != null) {
            // If logged in and driver data is available, navigate to HomePage
            return HomePageWidget(driver: driver);
          }
          else {
            // Otherwise, redirect to login/landing page
            return const LandingPage();
          }
        },
      ),
    );
  }
}