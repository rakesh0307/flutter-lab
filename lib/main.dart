import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/add_video_screen.dart';
import 'screens/search_screen.dart';
import 'screens/edit_video_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Handle Firebase initialization error gracefully
    debugPrint('Firebase initialization error: $e');
  }
  runApp(const VideoStreamingApp());
}

class VideoStreamingApp extends StatelessWidget {
  const VideoStreamingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Streaming',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/home': (context) => const VideoStreamingHomeScreen(),
        '/add': (context) => const AddVideoScreen(),
        '/search': (context) => const SearchScreen(),
        '/edit': (context) => const EditVideoScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    setState(() {
      _isLoggedIn = userId != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn ? const VideoStreamingHomeScreen() : const LoginScreen();
  }
}

class VideoStreamingHomeScreen extends StatelessWidget {
  const VideoStreamingHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Streaming'),
        backgroundColor: const Color(0xFF2196F3),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Video Streaming',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/add'),
              child: const Text('Add Video'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/search'),
              child: const Text('Browse Videos'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/edit'),
              child: const Text('Edit Videos'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/'),
              child: const Text('Login (Already logged in)'),
            ),
          ],
        ),
      ),
    );
  }
}
