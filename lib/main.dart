import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().initNotification();
  runApp(const WFHApp());
}

class WFHApp extends StatelessWidget {
  const WFHApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _location = "Unknown";
  String _battery = "Check Battery";
  final _goalController = TextEditingController();
  static const platform = MethodChannel('samples.flutter.dev/battery');
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  // R&U4: Native Battery Logic
  Future<void> _getBattery() async {
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      setState(() => _battery = "Battery: $result%");
      await analytics.logEvent(name: 'check_battery', parameters: {'battery_level': result});
    } catch (e) {
      setState(() => _battery = "Failed to get battery.");
    }
  }

  // R&U3: GPS Logic
  Future<void> _getLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position pos = await Geolocator.getCurrentPosition();
    setState(() => _location = "Lat: ${pos.latitude}, Lon: ${pos.longitude}");
    await analytics.logEvent(name: 'check_location');
  }

  // A&A3: Local Storage
  void _saveGoal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('work_goal', _goalController.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Goal Saved!")));
    await analytics.logEvent(name: 'save_goal');
  }

  void _loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _goalController.text = prefs.getString('work_goal') ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("WFH Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.map),
              title: Text(_location),
              onTap: _getLocation,
              tileColor: Colors.blue.withOpacity(0.1),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.battery_std),
              title: Text(_battery),
              onTap: _getBattery,
              tileColor: Colors.green.withOpacity(0.1),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _goalController,
              decoration: const InputDecoration(labelText: "Enter Daily Work Goal"),
            ),
            ElevatedButton(onPressed: _saveGoal, child: const Text("Save to Local Storage")),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.notifications_active),
              label: const Text("Test Activity Nudge"),
              onPressed: () {
                NotificationService().showNotification(
                  title: "WFH Alert",
                  body: "Time to stand up and stretch!",
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}