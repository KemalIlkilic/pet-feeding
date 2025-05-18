import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class ManualFeedScreen extends StatefulWidget {
  const ManualFeedScreen({super.key});

  @override
  State<ManualFeedScreen> createState() => _ManualFeedScreenState();
}

class _ManualFeedScreenState extends State<ManualFeedScreen> {
  double _selectedPortion = 40.0;
  final double _minPortion = 40.0;
  final double _maxPortion = 240.0;
  bool _isFeeding = false;
  String? _lastFeedTime;
  double _foodLevelPercent = 100;

  final databaseRef = FirebaseDatabase.instance.ref();

  void _feedNow() async {
    if (_isFeeding) return;

    setState(() {
      _isFeeding = true;
    });

    int repetitions = (_selectedPortion ~/ 40);

    for (int i = 0; i < repetitions; i++) {
      try {
        await databaseRef.child('commands').update({'feedNow': true});
        print('✅ Sent feed command (${i + 1}/$repetitions)');
      } catch (e) {
        print('❌ Failed to send feed command: $e');
      }
      await Future.delayed(const Duration(seconds: 2));
    }

    double newLevel = _foodLevelPercent - 5;
    if (newLevel < 0) newLevel = 0;

    try {
      await databaseRef.child('status/foodLevel').set(newLevel);
      setState(() {
        _foodLevelPercent = newLevel;
      });
    } catch (e) {
      print('❌ Failed to update food level: $e');
    }

    setState(() {
      _isFeeding = false;
      _lastFeedTime = TimeOfDay.now().format(context);
    });
  }

  void _refillFood() async {
    try {
      await databaseRef.child('status/foodLevel').set(100);
      setState(() {
        _foodLevelPercent = 100;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food level refilled to 100%')),
      );
    } catch (e) {
      print('❌ Failed to reset food level: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    databaseRef.child('status/foodLevel').onValue.listen((event) {
      final value = event.snapshot.value;
      if (value != null) {
        final level = double.tryParse(value.toString());
        if (level != null && level >= 0 && level <= 100) {
          setState(() {
            _foodLevelPercent = level;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double foodLevelFraction = _foodLevelPercent / 100;

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
                  'Food Level: ${_foodLevelPercent.toInt()}%',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: foodLevelFraction.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _foodLevelPercent > 20 ? Colors.black : Colors.red,
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
                color: Colors.black,
              ),
            ),
            Slider(
              value: _selectedPortion,
              min: _minPortion,
              max: _maxPortion,
              divisions: ((_maxPortion - _minPortion) ~/ 40),
              label: '${_selectedPortion.round()} g',
              onChanged: (double value) {
                setState(() {
                  _selectedPortion = value;
                });
              },
              activeColor: Colors.black,
              inactiveColor: Colors.grey[300],
            ),
            const SizedBox(height: 30),

            // Circular Feed Now Button
            Center(
              child: SizedBox(
                width: 240,
                height: 240,
                child: ElevatedButton(
                  onPressed: _isFeeding ? null : _feedNow,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.black,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isFeeding
                          ? const SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 50,
                            ),
                      const SizedBox(height: 10),
                      Text(
                        _isFeeding ? 'Feeding...' : 'Feed Now',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Refill Button Always Visible
            ElevatedButton.icon(
              onPressed: _refillFood,
              icon: const Icon(Icons.refresh),
              label: const Text('Refill Food'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),

            if (_lastFeedTime != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0, top: 10),
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
