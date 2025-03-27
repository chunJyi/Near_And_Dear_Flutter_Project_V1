
import 'package:flutter/foundation.dart';
import 'package:near_and_dear_flutter_v1/main.dart';
import 'package:near_and_dear_flutter_v1/model/current_user.dart';

class SupabaseService {

   // Fetch user details from Supabase
 static Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    final response = await supabase
        .from('loginUser')
        .select()
        .eq('userID', userId)
        .single();
    
    return response;
  }

   static Future<CurrentUser> getUserDetailsObj(String userId) async {
    final response = await supabase
        .from('loginUser')
        .select()
        .eq('userID', userId)
        .single();
    
    return CurrentUser.fromMap(response);
  }


  Future<void> saveUserLocation(Map<String, dynamic> userData) async {
    try {
      await supabase.from('loginUser').upsert(userData);
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

static Future<void> updateUserLocation(CurrentUser user) async {
  try {
    await supabase.from('loginUser').update({
      'location_model': user.locationModel.toJson(),
      'updated_at': DateTime.now().toIso8601String(), // Update timestamp
    }).eq('userID', user.id);
    print("✅ User location & updated_at updated successfully.");
  } catch (e) {
    print("❌ Error updating location: $e");
  }
}

}
