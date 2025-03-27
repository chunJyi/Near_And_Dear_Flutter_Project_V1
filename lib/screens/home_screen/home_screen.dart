import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:near_and_dear_flutter_v1/providers/user_provider.dart';
import 'package:provider/provider.dart';

import 'widgets/friend_list.dart';
import 'widgets/friends_section.dart';
import 'widgets/profile_card.dart';
import 'widgets/profile_map_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.95);
  // ignore: unused_field
  GoogleMapController? _mapController;
  static final LatLng _initialPosition = LatLng(16.8409, 96.1735);
  String selectedTab = 'friends';

  @override
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Near & Dear',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              child: PageView(
                controller: _pageController,
                children: [
                  ProfileCard(),
                  MapCard(
                      initialPosition: _initialPosition,
                      onMapCreated: (controller) =>
                          _mapController = controller),
                ],
              ),
            ),
            SizedBox(height: 16),

            FriendsSection(),

            SizedBox(height: 16),

            // Tabs Section
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Centers and reduces space
              children: [
                _buildTabButton('Friends', 'friends'),
                const SizedBox(width: 8), // Adjust spacing as needed
                _buildTabButton('Request', 'requests'),
                const SizedBox(width: 8),
                _buildTabButton('Pending', 'pending'),
              ],
            ),

            SizedBox(height: 16),

            // Dynamic Friend List
            FriendList(friends: user!.friends, state: selectedTab),
          ],
        ),
      ),
    );
  }

  /// **Tab Button Builder**
  Widget _buildTabButton(String text, String tab) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedTab = tab;
        });
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor:
            selectedTab == tab ? Colors.blue : Colors.grey.shade300,
        foregroundColor: selectedTab == tab ? Colors.white : Colors.black,
      ),
      child: Text(text),
    );
  }
}
