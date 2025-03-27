import 'package:geocoding/geocoding.dart';

Future<String> getAddressFromLatLng(double latitude, double longitude) async {
  String addressString="Myanmar";
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
       addressString = "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    }
  } catch (e) {
    print("Error getting address: $e");
  }
  return addressString;
}