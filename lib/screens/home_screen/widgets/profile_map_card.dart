import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:near_and_dear_flutter_v1/providers/user_provider.dart';
import 'package:provider/provider.dart';

class MapCard extends StatefulWidget {
  final LatLng initialPosition;
  final Function(GoogleMapController) onMapCreated;

  const MapCard({
    super.key,
    required this.initialPosition,
    required this.onMapCreated,
  });

  @override
  State<MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<MapCard> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(16.8409, 96.1735); // Default Yangon

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition;
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _currentPosition = position.target;
    });
  }

  void _moveToLocation(LatLng newPosition) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(newPosition),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user?.locationModel != null) {
      _currentPosition =
          LatLng(user!.locationModel.latitude, user.locationModel.longitude);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 12,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              widget.onMapCreated(controller);
            },
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            rotateGesturesEnabled: true,
            onCameraMove: _onCameraMove,
            markers: {
              Marker(
                markerId: const MarkerId('user_location'),
                position: _currentPosition,
                infoWindow: const InfoWindow(title: "Current Location"),
              ),
            },
          ),
        ],
      ),
    );
  }
}
