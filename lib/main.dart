import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await Supabase.initialize(
      url: 'https://ymetwejpcfjfugghjlcw.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InltZXR3ZWpwY2ZqZnVnZ2hqbGN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg1OTg0MDcsImV4cCI6MjA2NDE3NDQwN30.7tQHUBt-hk5G0DN1ex3n_m3l5jiiVxWTfmQ7rJVnNDk');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Ari-W9500-Display'),
      home: const SplashScreen(),
    );
  }
}
