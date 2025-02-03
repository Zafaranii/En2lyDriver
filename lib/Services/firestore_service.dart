import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../Models/trip_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload an image to Firebase Storage and return its URL
  Future<String?> uploadImage(File imageFile, String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Save trip data to Firestore
  Future<void> saveTripData(Trip tripModel) async {
    try {
      await _firestore.collection('trips').add(tripModel.toMap());
      print('Trip data saved successfully.');
    } catch (e) {
      print('Error saving trip data: $e');
    }
  }

  // Process items, upload photos, and save trip
  Future<void> processAndSaveTrip({
    required String pickupTitle,
    required String dropoffTitle,
    required double price,
    required String paymentMethod,
    required LatLng pickupLocation,
    required LatLng dropoffLocation,
    required int noOfItems,
    required String customerCreatedById,
    required List<Map<String, dynamic>> itemsWithImages,
  }) async {
    List<Map<String, dynamic>> items = [];

    // Loop through each item, upload its photo, and save data
    for (int i = 0; i < noOfItems; i++) {
      File? image = itemsWithImages[i]['image'];
      String? imageUrl;

      if (image != null) {
        imageUrl = await uploadImage(image, 'item_images/item_${DateTime.now().millisecondsSinceEpoch}.jpg');
      }

      items.add({
        'name': itemsWithImages[i]['name'],
        'height': itemsWithImages[i]['height'],
        'width': itemsWithImages[i]['width'],
        'length': itemsWithImages[i]['length'],
        'imageUrl': imageUrl ?? '',
      });
    }
    String tripStatus= 'pending';
    // Create TripModel
    Trip tripModel = Trip(
      pickupTitle: pickupTitle,
      dropoffTitle: dropoffTitle,
      price: price,
      paymentMethod: paymentMethod,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      noOfItems: noOfItems,
      customerCreatedById: customerCreatedById,
      tripStatus: 'pending',
      items: items,
    );

    // Save to Firestore
    await saveTripData(tripModel);
  }
}