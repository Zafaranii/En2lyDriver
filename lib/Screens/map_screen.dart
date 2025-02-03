import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:en2lydriver/Screens/home_page.dart';
import 'package:en2lydriver/Screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../Models/driver_model.dart';
import '../Models/trip_model.dart';
import '../Services/location_service.dart';
import '../Services/nomination_service.dart';
import '../Widgets/menu_bar.dart';
import 'search_page.dart';
import 'package:http/http.dart' as http;
class MapScreen extends StatefulWidget {
  final Trip trip;
  final Driver driver;
  final String tripId;
  const MapScreen({required this.tripId,required this.driver,required this.trip, super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final NominatimService _nominatimService = NominatimService();

  LatLng? _currentLocation;
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  List<LatLng> _routePoints = [];
  bool _rideStarted = false; // Track if the ride has started

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _pickupLocation = widget.trip.pickupLocation;
    _dropoffLocation = widget.trip.dropoffLocation;
    _drawRoute();
  }

  Future<void> _initializeLocation() async {
    final location = await _locationService.getCurrentLocation();
    if (location != null) {
      final currentLatLng = LatLng(location.latitude!, location.longitude!);
      setState(() {
        _currentLocation = currentLatLng;
        _mapController.move(_currentLocation!, 15.0);
      });
    }
  }

  Future<void> _drawRoute() async {
    if (_pickupLocation == null || _dropoffLocation == null) return;

    final start = _pickupLocation!;
    final end = _dropoffLocation!;

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf6248c0cf752d62b24795a583a130fff52fce&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coords = data['features'][0]['geometry']['coordinates'];
        setState(() {
          _routePoints = coords.map((coord) => LatLng(coord[1], coord[0])).toList();
        });
      } else {
        print('Failed to fetch route: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  void _toggleRideState() async {
    if (_rideStarted) {
      try {
        // Update Firestore fields
        await FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripId)
            .update({'tripStatus': 'finished'});

        print("Firestore update successful!");

        // Navigate to the homepage
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePageWidget(driver: widget.driver)),
              (route) => false,
        );
      } catch (e) {
        print("Error updating Firestore: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update trip status.')),
        );
      }
    } else {
      // Start the ride
      setState(() {
        _rideStarted = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Map Screen'),
        ),
        drawer:  MenuBarApp(driverId : widget.driver.driverId! ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation ?? LatLng(30.0444, 31.2357),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://basemaps.cartocdn.com/rastertiles/voyager_nolabels/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                if (_pickupLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pickupLocation!,
                        width: 80.0,
                        height: 80.0,
                        child: const Icon(Icons.location_on,
                            color: Colors.blue, size: 40.0),
                      ),
                    ],
                  ),
                if (_dropoffLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _dropoffLocation!,
                        width: 80.0,
                        height: 80.0,
                        child: const Icon(Icons.location_on,
                            color: Colors.red, size: 40.0),
                      ),
                    ],
                  ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
              ],
            ),
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: widget.trip.pickupTitle,
                      prefixIcon: const Icon(Icons.my_location),
                      filled: true,
                      fillColor: Colors.white,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: widget.trip.dropoffTitle,
                      prefixIcon: const Icon(Icons.location_on),
                      filled: true,
                      fillColor: Colors.white,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: _toggleRideState,
                child: Text(_rideStarted ? "End Ride" : "I've Arrived"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}