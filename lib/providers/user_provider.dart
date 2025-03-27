import 'package:flutter/foundation.dart';
import 'package:near_and_dear_flutter_v1/model/current_user.dart';
import 'package:near_and_dear_flutter_v1/model/location_model.dart';

class UserProvider with ChangeNotifier {
  CurrentUser? _user;

  CurrentUser? get user => _user;

  // Set User Data (e.g., after login or fetching from database)
  void setUser(CurrentUser userModel) {
    _user = userModel;
    notifyListeners();
  }

  // Update specific fields (e.g., changing name or avatar)
  void updateUser({String? name, String? avatarUrl, LocationModel? location}) {
    if (_user != null) {
      _user = CurrentUser(
        id: _user!.id,
        name: name ?? _user!.name,
        email: _user!.email,
        avatar_url: avatarUrl ?? _user!.avatar_url,
        created_at: _user!.created_at,
        updated_at: _user!.updated_at,
        locationModel: location ?? _user!.locationModel,
        friends: _user!.friends,
      );
      notifyListeners();
    }
  }

  // Logout (Clear user data)
  void logout() {
    _user = null;
    notifyListeners();
  }
}
