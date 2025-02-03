import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Screens/MenuBar/Payment/payment.dart';
import '../Screens/MenuBar/help.dart';
import '../Screens/MenuBar/messages.dart';
import '../Screens/MenuBar/settings.dart';
import '../Screens/MenuBar/trips.dart';

class MenuBarApp extends StatelessWidget {
  final String driverId;
  const MenuBarApp({required this.driverId, super.key});

  Future<double> calculateDriverRating() async {
    try {
      // Query trips for the given driver that have a valid rating
      final querySnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('driverId', isEqualTo: driverId) // Filter by driver ID
          .where('driverRating', isGreaterThan: 0) // Exclude trips without a valid rating
          .get();

      final trips = querySnapshot.docs;

      if (trips.isEmpty) {
        return 0.0; // No valid ratings found
      }

      // Sum up all valid ratings
      double totalRating = 0.0;
      int validRatingsCount = 0;

      for (var trip in trips) {
        if (trip['driverRating'] != null) {
          totalRating += trip['driverRating'].toDouble();
          validRatingsCount++;
        }
      }

      // Calculate the average
      final averageRating = totalRating / validRatingsCount;

      return averageRating;
    } catch (e) {
      print('Error calculating driver rating: $e');
      return 0.0; // Default to 0.0 in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menu items configuration
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.trip_origin,
        'title': 'Your Trips',
        'page': YourTripsPage(driverId: driverId),
      },
      {
        'icon': Icons.message,
        'title': 'Messages',
        'page': const MessagesPage(),
      },
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'page': const SettingsPage(),
      },
      {
        'icon': Icons.payment,
        'title': 'Payment',
        'page': const PaymentPage(),
      },
      {
        'icon': Icons.help,
        'title': 'Help',
        'page': const HelpPage(),
      },
    ];

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          _buildDrawerHeader(),

          // Menu Items
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return ListTile(
                  leading: Icon(item['icon']),
                  title: Text(item['title']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => item['page']),
                    );
                  },
                );
              },
            ),
          ),

          // Footer Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Legal', style: TextStyle(fontSize: 14)),
                SizedBox(height: 4),
                Text('v4.3712003', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Drawer Header
  Widget _buildDrawerHeader() {
    return FutureBuilder<double>(
      future: calculateDriverRating(), // Fetch the driver rating
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromRGBO(45, 62, 80, 1),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('images/customer.png'),
            ),
            accountName: Text(
              'Marwan Hazem',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              'Loading...',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          );
        }

        // Handle error state
        if (snapshot.hasError || !snapshot.hasData) {
          return const UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromRGBO(45, 62, 80, 1),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('images/customer.png'),
            ),
            accountName: Text(
              'Marwan Hazem',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              'Error',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          );
        }

        // Display the calculated rating
        final rating = snapshot.data!;
        return UserAccountsDrawerHeader(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(45, 62, 80, 1),
          ),
          currentAccountPicture: const CircleAvatar(
            backgroundImage: AssetImage('images/customer.png'),
          ),
          accountName: const Text(
            'Marwan Hazem',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          accountEmail: Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1), // Format the rating to 1 decimal place
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}