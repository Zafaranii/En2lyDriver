import 'package:latlong2/latlong.dart';

class Trip {
  late String pickupTitle;
  late String dropoffTitle;
  late double price;
  late String paymentMethod;
  late LatLng pickupLocation;
  late LatLng dropoffLocation;
  late int noOfItems;
  String? driverAssignedId;
  late String customerCreatedById;
  late String tripStatus;
  late List<Map<String, dynamic>> items;

  Trip.New();

  Trip({
    required this.pickupTitle,
    required this.dropoffTitle,
    required this.price,
    required this.paymentMethod,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.noOfItems,
    this.driverAssignedId,
    required this.customerCreatedById,
    required this.tripStatus,
    required this.items,
  });

  factory Trip.fromMap(Map<String, dynamic> data) {
    return Trip(
      pickupTitle: data['pickupTitle'] as String? ?? '',
      dropoffTitle: data['dropoffTitle'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: data['paymentMethod'] as String? ?? '',
      pickupLocation: data['pickupLocation'] != null
          ? LatLng(
        (data['pickupLocation']['latitude'] as num).toDouble(),
        (data['pickupLocation']['longitude'] as num).toDouble(),
      )
          : LatLng(0.0, 0.0), // Default value if pickupLocation is null
      dropoffLocation: data['dropoffLocation'] != null
          ? LatLng(
        (data['dropoffLocation']['latitude'] as num).toDouble(),
        (data['dropoffLocation']['longitude'] as num).toDouble(),
      )
          : LatLng(0.0, 0.0), // Default value if dropoffLocation is null
      noOfItems: data['noOfItems'] as int? ?? 0,
      driverAssignedId: data['driverAssignedId'] as String?,
      customerCreatedById: data['customerCreatedById'] as String? ?? '',
      tripStatus: data['tripStatus'] as String? ?? '',
      items: data['items'] != null
          ? (data['items'] as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pickupTitle': pickupTitle,
      'dropoffTitle': dropoffTitle,
      'price': price,
      'paymentMethod': paymentMethod,
      'pickupLocation': {
        'latitude': pickupLocation.latitude,
        'longitude': pickupLocation.longitude,
      },
      'dropoffLocation': {
        'latitude': dropoffLocation.latitude,
        'longitude': dropoffLocation.longitude,
      },
      'noOfItems': noOfItems,
      'driverAssignedId': driverAssignedId,
      'customerCreatedById': customerCreatedById,
      'tripStatus': tripStatus,
      'items': items,
    };
  }
}