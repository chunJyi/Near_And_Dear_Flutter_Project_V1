import 'package:flutter/material.dart';
import 'package:near_and_dear_flutter_v1/providers/user_provider.dart';
import 'package:near_and_dear_flutter_v1/screens/splash_screen/splash_screen.dart';
import 'package:near_and_dear_flutter_v1/services/background_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

const supabaseUrl = 'https://bbdadykysfweivoqcrap.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJiZGFkeWt5c2Z3ZWl2b3FjcmFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMwNzQ1MzMsImV4cCI6MjA1ODY1MDUzM30.VLJiw_CcFT54PZHQzyW_du8gno6NZshu80O8tYkgbLA';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundService.initializeService();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
