import 'package:flutter/material.dart';
import 'dart:async'; // For Timer
import 'package:firebase_database/firebase_database.dart';

class ManualFeedScreen extends StatefulWidget {
  const ManualFeedScreen({super.key});

  @override
  State<ManualFeedScreen> createState() => _ManualFeedScreenState();
}

class _ManualFeedScreenState extends State<ManualFeedScreen> {
  double _selectedPortion = 30.0;
  final double _minPortion = 10.0;
  final double _maxPortion = 100.0;
  bool _isFeeding = false;
  String? _lastFeedTime;
  String _sensorStatus = "HIGH"; // Default to high

  final databaseRef = FirebaseDatabase.instance.ref();

  void _feedNow() async {
    if (_isFeeding) return;

    setState(() {
      _isFeeding = true;
    });

    try {
      await databaseRef.child('commands').update({'feedNow': true});
    } catch (e) {
      print('Failed to send command: $e');
    }

    Timer(const Duration(seconds: 3), () {
      setState(() {
        _isFeeding = false;
        _lastFeedTime = TimeOfDay.now().format(context);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // Listen for sensor status changes
    databaseRef.child('status/sensorStatus').onValue.listen((event) {
      final value = event.snapshot.value;
      if (value != null && value.toString() == "LOW_FOOD") {
        setState(() {
          _sensorStatus = "LOW";
        });
      } else {
        setState(() {
          _sensorStatus = "HIGH";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isFoodLow = _sensorStatus == "LOW";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Feeding'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Food Level Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storage, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Food Level: ${isFoodLow ? "Low" : "High"}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: isFoodLow ? 0.0 : 1.0,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isFoodLow ? Colors.red : Colors.black,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 40),

            // Portion Size Selection
            const Text(
              'Select Portion Size',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '${_selectedPortion.toInt()} g',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Slider(
              value: _selectedPortion,
              min: _minPortion,
              max: _maxPortion,
              divisions: ((_maxPortion - _minPortion) / 5).toInt(),
              label: '${_selectedPortion.round()} g',
              onChanged: (double value) {
                setState(() {
                  _selectedPortion = value;
                });
              },
              activeColor: Colors.black,
              inactiveColor: Colors.grey[300],
            ),
            const SizedBox(height: 40),

            // Feed Now Button
            ElevatedButton.icon(
              icon: _isFeeding
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.restaurant, color: Colors.white),
              label: Text(_isFeeding ? 'Feeding...' : 'Feed Now'),
              onPressed: _isFeeding ? null : _feedNow,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                textStyle:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Spacer(),

            if (_lastFeedTime != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Last manual feed: $_lastFeedTime',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
