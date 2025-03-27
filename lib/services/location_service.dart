import 'dart:async';
import 'package:location/location.dart';
import 'package:near_and_dear_flutter_v1/model/location_model.dart';
import 'package:near_and_dear_flutter_v1/services/address_service.dart';

class LocationService {
  final Location location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  Future<bool> requestPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check permission status
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    return true;
  }

  Future<LocationModel?> getCurrentLocation() async {
    final permissionGranted = await requestPermission();
    if (!permissionGranted) return null;

    final locationData = await location.getLocation();
    return _convertToLocationModel(locationData);
  }

  void startListening(Function(LocationModel) onLocationChanged) async {
    final permissionGranted = await requestPermission();
    if (!permissionGranted) return;

    _locationSubscription?.cancel(); // Cancel previous subscription if exists

    _locationSubscription = location.onLocationChanged.listen((locationData) async {
      final locationModel = await _convertToLocationModel(locationData);
      if (locationModel != null) {
        onLocationChanged(locationModel);
      }
    });
  }

  void stopListening() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Future<LocationModel?> _convertToLocationModel(LocationData locationData) async {
    final latitude = locationData.latitude;
    final longitude = locationData.longitude;

    if (latitude == null || longitude == null) return null;

    final address = await getAddressFromLatLng(latitude, longitude);

    return LocationModel(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }
}
