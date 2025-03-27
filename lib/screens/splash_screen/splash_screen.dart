import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:near_and_dear_flutter_v1/model/current_user.dart';
import 'package:near_and_dear_flutter_v1/providers/user_provider.dart';
import 'package:near_and_dear_flutter_v1/services/auth_checker_service.dart';
import 'package:near_and_dear_flutter_v1/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasError = false;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  /// Initializes SharedPreferences, loads user data, and starts location tracking.
  Future<void> _initializeUser() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userData = _getUserData();

      if (userData == null) {
        return _navigateToNextScreen();
      }

      // Fetch updated user details from Supabase
      CurrentUser user = CurrentUser.fromMap(userData);
      user = await SupabaseService.getUserDetailsObj(user.id);
      userProvider.setUser(user);

      if (mounted) _navigateToNextScreen();
    } catch (e) {
      debugPrint("Error loading user data: $e");
      if (mounted) setState(() => _hasError = true);
    }
  }

  /// Retrieves stored user data from SharedPreferences.
  Map<String, dynamic>? _getUserData() {
    final userString = _prefs?.getString("userData");
    return userString != null ? jsonDecode(userString) : null;
  }


  /// Navigates to AuthChecker to determine the next screen.
  void _navigateToNextScreen() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthChecker()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _buildBackgroundGradient(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(),
            _hasError ? _buildErrorUI() : _buildLoadingIndicator(),
            const SizedBox(height: 20),
            _buildAppTitle(),
          ],
        ),
      ),
    );
  }

  /// Returns the app's background gradient decoration.
  BoxDecoration _buildBackgroundGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFFFFF), // White
          Color(0xFFEFF6FF), // Light blue
        ],
      ),
    );
  }

  /// Builds the app logo widget.
  Widget _buildLogo() {
    return Expanded(
      flex: 3,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.asset(
            'assets/icons/app_icon.png',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  /// Shows a loading indicator while user data is being fetched.
  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: LinearProgressIndicator(
        backgroundColor: const Color.fromARGB(255, 0, 8, 255).withOpacity(0.3),
        valueColor:
            const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 255, 4, 4)),
        minHeight: 2,
      ),
    );
  }

  /// Displays an error message with a retry button.
  Widget _buildErrorUI() {
    return Column(
      children: [
        const Text(
          "Failed to load user data. Please try again.",
          style: TextStyle(color: Colors.red, fontSize: 14),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _initializeUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text("Try Again"),
        ),
      ],
    );
  }

  /// Displays the app title.
  Widget _buildAppTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: Text(
        'Find Lovely',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
