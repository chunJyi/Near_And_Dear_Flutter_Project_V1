import 'package:flutter/material.dart';
import 'package:near_and_dear_flutter_v1/model/current_user.dart';
import 'package:near_and_dear_flutter_v1/providers/user_provider.dart';
import 'package:near_and_dear_flutter_v1/screens/map_screen/map_screen.dart';
import 'package:provider/provider.dart';

class FriendsSection extends StatelessWidget {
  const FriendsSection({super.key, });

  String generateAvatarUrl(String name) {
    return "https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random&color=fff&size=128";
  }

  void _openMap(BuildContext context, FriendUser friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(friendUser: friend), // Navigate to map
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align content to start
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Friends',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Align(
            alignment: Alignment.centerLeft, // Ensures left alignment
            child: Row(
              children: user!.friends.map((friend) {
                bool hasImage = friend.profileImageUrl.isNotEmpty;

                String avatarUrl = hasImage
                    ? friend.profileImageUrl
                    : generateAvatarUrl(friend.friendName);

                return Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                  
                      GestureDetector(
                        onTap: () => _openMap(context, friend), // Click action
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(avatarUrl),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(friend.friendName,
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
