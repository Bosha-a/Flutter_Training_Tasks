import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetDataScreen extends StatelessWidget {
  const ResetDataScreen({super.key});

  Future<void> _resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Data')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Reset all app data'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _resetData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data reset complete')),
                );
              },
              child: const Text('Reset Data'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
