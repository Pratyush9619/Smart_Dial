import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final bool isWithinRadius;
  final String address;
  final double latitude;
  final double longitude;

  LocationResult(
    this.isWithinRadius,
    this.address,
    this.latitude,
    this.longitude,
  );
}

class LocationService {
  static double officeLat = 0.0;
  static double officeLng = 0.0;
  static double radius = 0.0;
  static double currentLat = 0.0;
  static double currentLng = 0.0;
  static Future<LocationResult> getLocation() async {
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied.");
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        "Location permission permanently denied. Enable it from Settings.",
      );
    }

    final Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Store current location
    currentLat = pos.latitude;
    currentLng = pos.longitude;

    print("Current Latitude: ${pos.latitude}");
    print("Current Longitude: ${pos.longitude}");

    final distance = Geolocator.distanceBetween(
      currentLat,
      currentLng,
      officeLat,
      officeLng,
    );

    final placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );

    final address = "${placemarks.first.locality}, ${placemarks.first.country}";

    return LocationResult(
      distance <= radius,
      address,
      pos.latitude,
      pos.longitude,
    );
  }
}
