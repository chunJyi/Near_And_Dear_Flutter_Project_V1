import 'package:flutter/material.dart';
import 'package:near_and_dear_flutter_v1/model/current_user.dart';

class FriendList extends StatelessWidget {
  final List<FriendUser> friends;
  final String state;
  

  const FriendList({super.key, required this.friends, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          /// Header with title and add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Friend List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(onPressed: () {}, child: Text('Add')),
            ],
          ),
          SizedBox(height: 8),

          /// Scrollable Friend List
          SizedBox(
            height: 300, // Fixed height for the list
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: friends.map((friend) => _buildFriendTile(friend)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Friend List Item
  Widget _buildFriendTile(FriendUser friend) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(generateAvatarUrl(friend.friendName)),
      ),
      title: Text(friend.friendName),
      trailing: _buildTrailingIcons(state, friend),
    );
  }

  /// Function to conditionally return trailing widgets based on `state`
  Widget? _buildTrailingIcons(String state, FriendUser friend) {
    if (state == "pending") {
      return null; // No icons for pending state
    } else if (state == "requests") {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: () {
              _handleAccept(friend);
            },
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () {
              _handleReject(friend);
            },
          ),
        ],
      );
    } else {
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
              _handleLike(friend);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20), // Reduce size
            onPressed: () {
              _handleChat(friend);
            },
          ),
        ],
      );
    }
  }

  /// Action handlers
  void _handleLike(FriendUser friend) {
  }

  void _handleChat(FriendUser friend) {
  }

  void _handleAccept(FriendUser friend) {
  }

  void _handleReject(FriendUser friend) {
  }

    String generateAvatarUrl(String name) {
    return "https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random&color=fff&size=128";
  }
}
