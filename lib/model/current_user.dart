

import 'package:near_and_dear_flutter_v1/model/location_model.dart';

class CurrentUser {
  String id;
  String name;
  String email;
  String avatar_url;
  String created_at;
    final String? updated_at; // New field
  LocationModel locationModel;
  List<FriendUser> friends;

  CurrentUser({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar_url,
    required this.created_at,
    required this.updated_at,
    required this.locationModel,
    required this.friends,
  });

  /// Static location for login user (Yangon, Myanmar)
  static final LocationModel yangonLocation = LocationModel(
    latitude: 16.8409,
    longitude: 96.1735,
    address: "Yangon, Myanmar",
  );

  factory CurrentUser.fromMap(Map<String, dynamic> data) {
  return CurrentUser(
    id: data['userID'] ?? '',
    name: data['name'] ?? '',
    email: data['email'] ?? '',
    avatar_url: data['avatar_url'] ?? '',
    created_at: data['created_at'] ?? '',
    updated_at: data['updated_at'] ?? '',
    locationModel: data['location_model'] != null 
        ? LocationModel.fromJson((data['location_model']) as Map<String, dynamic>) 
               : yangonLocation, // Default location if null
    friends: [], // Assuming this will be populated later
  );
}

  /// Factory method to create a `loginUser` instance with friends, requests, and pending lists
  factory CurrentUser.createLoginUser() {
    List<FriendUser> friendsList = List.generate(10, (index) {
      return FriendUser(
          friendId: (index + 1).toDouble(), // ✅ Corrected double type
          friendName: "Friend ${index + 1}",
          userState: UserState.FRIEND,
          profileImageUrl: "");
    });

    return CurrentUser(
      id: "1",
      name: "John Doe",
      email: "johndoe@example.com",
      avatar_url: "https://ui-avatars.com/api/?name=John+Doe",
      locationModel: yangonLocation,
      created_at: "sldfslfj",
      updated_at: 'saffsfsd',
      friends: friendsList,
    );
  }

    /// Create a copy of the user with updated fields
  CurrentUser copyWith({
    LocationModel? locationModel,
    String? updated_at,
  }) {
    return CurrentUser(
      id: id,
      name: name,
      email: email,
      avatar_url: avatar_url,
      created_at: created_at, // Keep original created_at
      updated_at: updated_at ?? this.updated_at,
      locationModel: locationModel ?? this.locationModel,
      friends: friends,
    );
  }
}

/// Friend User Model
class FriendUser {
  double friendId; // ✅ Changed from `Double` to `double`
  String friendName;
  UserState userState;
  String profileImageUrl;

  FriendUser(
      {required this.friendId,
      required this.friendName,
      required this.userState,
      required this.profileImageUrl});
}

enum UserState {
  // ignore: constant_identifier_names
  FRIEND('FRIEND', 'User is a friend'),
  // ignore: constant_identifier_names
  REQUEST('REQUEST', 'User has sent a request'),
  // ignore: constant_identifier_names
  PENDING('PENDING', 'Request is pending');

  final String name;
  final String description;

  const UserState(this.name, this.description);

  static UserState fromName(String name) {
    return UserState.values.firstWhere((state) => state.name == name,
        orElse: () => throw ArgumentError('Invalid name: $name'));
  }
}
