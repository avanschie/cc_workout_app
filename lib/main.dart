import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cc_workout_app/core/config/env_config.dart';
import 'package:cc_workout_app/features/lifts/screens/add_lift_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Debug: Check environment variables
  debugPrint('Supabase URL: ${EnvConfig.supabaseUrl}');
  debugPrint('Supabase configured: ${EnvConfig.isConfigured}');

  if (!EnvConfig.isConfigured) {
    debugPrint(
      'Warning: Supabase not configured via --dart-define. Using fallback values for local development.',
    );
  }

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl.isEmpty
        ? 'http://10.0.2.2:54321'
        : EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey.isEmpty
        ? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0'
        : EnvConfig.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Powerlifting Rep Max Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Powerlifting Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Powerlifting Rep Max Tracker',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Track your S/B/D lifts and view rep maxes'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddLiftScreen()),
          );
        },
        tooltip: 'Add Lift',
        child: const Icon(Icons.add),
      ),
    );
  }
}
