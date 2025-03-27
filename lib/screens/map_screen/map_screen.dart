import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:near_and_dear_flutter_v1/model/current_user.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  final FriendUser friendUser;
  const MapScreen({super.key, required this.friendUser});

  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // ignore: unused_field
  late GoogleMapController _mapController;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  bool _isExpanded = false;
  late LatLng friendLocation;
  final CurrentUser friend = CurrentUser.createLoginUser();
  MapType _currentMapType = MapType.normal; // Default Map Type

  final List<FriendUser> _friends = CurrentUser.createLoginUser()
      .friends
      .where((friend) => friend.userState == UserState.FRIEND)
      .toList();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      // Handle denied permission
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permission is required!")),
      );
    }
  }

  void _toggleBottomSheet() {
    _sheetController.animateTo(
      _isExpanded ? 0.2 : 0.5,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _changeMapType(MapType mapType) {
    setState(() {
      _currentMapType = mapType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<MapType>(
            icon: Icon(Icons.more_vert), // Map type selector button
            onSelected: _changeMapType,
            itemBuilder: (context) => [
              PopupMenuItem(value: MapType.normal, child: Text("Normal")),
              PopupMenuItem(value: MapType.satellite, child: Text("Satellite")),
              PopupMenuItem(value: MapType.hybrid, child: Text("Hybrid")),
              PopupMenuItem(value: MapType.terrain, child: Text("Terrain")),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMapWidget(
            initialPosition: LatLng(40.7128, -74.0060),
            mapType: _currentMapType,
            onMapCreated: (controller) => _mapController = controller,
            friend: friend,
          ),
          DraggableSheetWidget(
            sheetController: _sheetController,
            isExpanded: _isExpanded,
            toggleBottomSheet: _toggleBottomSheet,
            friends: _friends,
          ),
        ],
      ),
    );
  }
}

class GoogleMapWidget extends StatelessWidget {
  final LatLng initialPosition;
  final MapType mapType;
  final Function(GoogleMapController) onMapCreated;
  final CurrentUser friend;

  const GoogleMapWidget({
    super.key,
    required this.initialPosition,
    required this.mapType,
    required this.onMapCreated,
    required this.friend,
  });

  Set<Marker> _createMarkers() {
    return {
      Marker(
        markerId: MarkerId(friend.name),
        position: LatLng(
            friend.locationModel.latitude, friend.locationModel.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: friend.name,
          snippet: friend.email,
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initialPosition, zoom: 12),
      markers: _createMarkers(),
      onMapCreated: onMapCreated,
      mapType: mapType,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}

class DraggableSheetWidget extends StatelessWidget {
  final DraggableScrollableController sheetController;
  final bool isExpanded;
  final VoidCallback toggleBottomSheet;
  final List<FriendUser> friends;

  const DraggableSheetWidget({
    super.key,
    required this.sheetController,
    required this.isExpanded,
    required this.toggleBottomSheet,
    required this.friends,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: 0.2,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return GestureDetector(
          onVerticalDragUpdate: (details) {
            double newSize = sheetController.size -
                (details.primaryDelta! / MediaQuery.of(context).size.height);
            sheetController.jumpTo(newSize.clamp(0.2, 0.8));
          },
          child: Container(
            padding: EdgeInsets.only(top: 1, left: 10, right: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Column(
              children: [
                Center(
                  child: IconButton(
                    icon: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                    ),
                    onPressed: toggleBottomSheet,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          FriendTileWidget(friend: friends[index],context: context),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FriendTileWidget extends StatelessWidget {
  final FriendUser friend;
  final BuildContext context;

  const FriendTileWidget({super.key, required this.friend,required this.context});

    String generateAvatarUrl(String name) {
    return "https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random&color=fff&size=128";
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 0, horizontal: 5), // Maintain spacing
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
        leading: CircleAvatar(
          radius: 18, // Reduce avatar size
          backgroundImage: NetworkImage(generateAvatarUrl(friend.friendName)),
        ),
        title: Text(
          friend.friendName,
          style: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14, // Reduce text size
          ),
        ),
        trailing: _buildTrailingIcons(friend)
      ),
    );
  }

  Widget? _buildTrailingIcons( FriendUser friend) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Image.asset(
            'assets/icons/pin_map.png',
            width: 20, // Reduce size
            height: 20,
          ),
          onPressed: () {
            // _handleLike(friend);
          },
        ),
        IconButton(
          icon: const Icon(Icons.content_paste_search,
              color: Color.fromARGB(255, 42, 13, 224), size: 25), // Reduce size
          onPressed: () {
            _showFriendDialog(friend) ;
            // _handleChat(friend);
          },
        ),
      ],
    );
  }


void _showFriendDialog(FriendUser friend) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(generateAvatarUrl(friend.friendName)),
              ),
              SizedBox(height: 10),
              Text(friend.friendName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(friend.friendName, style: TextStyle(color: Colors.grey)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.favorite_border, color: Colors.black54),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.chat_bubble_outline, color: Colors.black54),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
  
}
