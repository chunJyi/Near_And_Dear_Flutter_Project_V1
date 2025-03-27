import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:near_and_dear_flutter_v1/screens/home_screen/home_screen.dart';
import 'package:near_and_dear_flutter_v1/services/location_service.dart';
import 'package:near_and_dear_flutter_v1/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final supabase = Supabase.instance.client;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    serverClientId:
        '121998306121-g9islk1i2h8q0uphih4s54r0cq6nhdu1.apps.googleusercontent.com',
  );
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.signedIn) {
        _handleUserSignIn();
      }
    });
  }

  Future<void> _handleUserSignIn() async {
    setState(() => _isLoading = true);
    final user = supabase.auth.currentUser;
    if (user != null) {
      await _saveUserToDatabase(user);
      _navigateToHome();
    }
    setState(() => _isLoading = false);
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  Future<void> _saveUserToDatabase(User user) async {
    final locationService = LocationService();
    final currentLocation = await locationService.getCurrentLocation();

    final userData = {
      'userID': user.id,
      'email': user.email,
      'name': user.userMetadata?['full_name'] ?? '',
      'avatar_url': user.userMetadata?['avatar_url'] ?? '',
      'created_at': DateTime.now().toIso8601String(),
      'location_model': currentLocation?.toJson(),
    };
    await SupabaseService().saveUserLocation(userData);
    // Save userData in SharedPreferences
    await saveData("userData", jsonEncode(userData));
  }

  Future<void> saveData(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> getData(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(key);
    print(value);
  }

  void _signInWithApple() {
    // Implement Apple Sign-In
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Near & Dear',
                style: TextStyle(fontSize: 50, fontFamily: 'Italianno'),
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        _buildSignInButton(
                          onPressed: _googleSignIn,
                          icon: Image.asset('assets/icons/google_symbol.png',
                              height: 24),
                          label: 'Continue with Google',
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          borderColor: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        _buildSignInButton(
                          onPressed: _signInWithApple,
                          icon: const Icon(Icons.apple, size: 24),
                          label: 'Continue with Apple',
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                      ],
                    ),
              const SizedBox(height: 20),
              _buildTermsAndPrivacyText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton({
    required VoidCallback onPressed,
    required Widget icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    Color? borderColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: borderColor != null
              ? BorderSide(color: borderColor)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTermsAndPrivacyText() {
    return const Text.rich(
      TextSpan(
        text: 'By clicking continue, you agree to our ',
        style: TextStyle(fontSize: 12, color: Colors.grey),
        children: [
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<void> _googleSignIn() async {
    try {
      setState(() => _isLoading = true);
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('No Access Token or ID Token found.');
      }

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
