import 'package:en2lydriver/Models/driver_model.dart';
import 'package:en2lydriver/Models/trip_model.dart';
import 'package:en2lydriver/Screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Widgets/menu_bar.dart';

class HomePageWidget extends StatefulWidget {
  final Driver driver;
  const HomePageWidget({super.key, required this.driver});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  Set<String> declinedTrips = {}; // Track declined trips

  void _declineTrip(String tripId) {
    setState(() {
      declinedTrips.add(tripId);
    });
  }

  void _acceptTrip(Map<String, dynamic> tripData, String tripId) async {
    try {
      print("Raw trip data: $tripData");

      // Map trip data to Trip object
      final Trip trip = Trip.fromMap(tripData);
      print("Mapped Trip: ${trip.toString()}");

      // Update Firestore fields
      print("Updating Firestore for trip ID: $tripId...");
      await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
        'driverAssignedId': widget.driver.driverId ,
        'tripStatus': 'attended',
      });
      print("Firestore update successful!");

      // Navigate to map screen
      print("Navigating to Map Screen...");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(trip: trip, driver: widget.driver, tripId : tripId),
        ),
      );
    } catch (e) {
      print("Error accepting trip: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
              MediaQuery.of(context).size.height * 0.15), // 15% screen height
          child: AppBar(
            title: const SizedBox.shrink(),
            backgroundColor: const Color.fromRGBO(45, 62, 80, 1),
            flexibleSpace: const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Offered Trips',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        drawer:  MenuBarApp(driverId : widget.driver.driverId! ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('trips')
              .where('tripStatus', isEqualTo: 'pending') // Only fetch pending trips
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No trips available"));
            }

            final trips = snapshot.data!.docs
                .where((doc) => !declinedTrips.contains(doc.id)) // Exclude declined trips
                .toList();

            if (trips.isEmpty) {
              return const Center(child: Text("No trips available"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final tripData = trips[index].data() as Map<String, dynamic>;
                final tripId = trips[index].id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trip Info
                      Row(
                        children: [
                          Icon(Icons.camera_alt, size: 100, color: Colors.grey[300]),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              'Customer: ${tripData['customerCreatedById'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: tripData['pickupTitle'] ?? 'Unknown Pickup',
                          labelStyle: const TextStyle(color: Colors.white),
                          border: const OutlineInputBorder(borderSide: BorderSide.none),
                          filled: true,
                          fillColor: const Color.fromRGBO(45, 62, 80, 1),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: tripData['dropoffTitle'] ?? 'Unknown Destination',
                          labelStyle: const TextStyle(color: Colors.white),
                          border: const OutlineInputBorder(borderSide: BorderSide.none),
                          filled: true,
                          fillColor: const Color.fromRGBO(45, 62, 80, 1),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Offered: ${tripData['price']} EGP - ${tripData['paymentMethod']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _declineTrip(tripId);
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.red,
                              minimumSize: const Size(150, 50),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const Text('Decline',
                                style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _acceptTrip(tripData, tripId);
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.green,
                              minimumSize: const Size(150, 50),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const Text('Accept',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}