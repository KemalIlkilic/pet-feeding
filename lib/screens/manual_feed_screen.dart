import 'package:flutter/material.dart';
import 'dart:async'; // For Timer

class ManualFeedScreen extends StatefulWidget {
  const ManualFeedScreen({super.key});

  @override
  State<ManualFeedScreen> createState() => _ManualFeedScreenState();
}

class _ManualFeedScreenState extends State<ManualFeedScreen> {
  String _selectedPet = 'Whiskers';
  double _selectedPortion = 30.0; // Default portion in grams
  final double _minPortion = 10.0;
  final double _maxPortion = 100.0;
  final double _foodLevel = 0.65; // Mock food level (65%)
  String _statusMessage = 'Ready to feed';
  bool _isFeeding = false;
  String? _lastFeedTime;

  void _feedNow() {
    if (_isFeeding) return;

    setState(() {
      _isFeeding = true;
      _statusMessage = 'Dispensing ${_selectedPortion.toInt()}g...';
    });

    // Simulate feeding process
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _isFeeding = false;
        _statusMessage = 'Successfully dispensed ${_selectedPortion.toInt()}g';
        _lastFeedTime = TimeOfDay.now().format(context);
      });
      // Reset status message after a few seconds
      Timer(const Duration(seconds: 5), () {
        if (mounted) { // Check if the widget is still in the tree
          setState(() {
            _statusMessage = 'Ready to feed';
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Feeding'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pet selection
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: const Text('🐱', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedPet,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.arrow_drop_down),
                    onSelected: (String pet) {
                      setState(() {
                        _selectedPet = pet;
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return ['Whiskers', 'Buddy', 'Hoppy'].map((String pet) {
                        return PopupMenuItem<String>(
                          value: pet,
                          child: Text(pet),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Food Level Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storage, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Food Level: ${(_foodLevel * 100).toInt()}%',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _foodLevel,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _foodLevel > 0.2 ? Colors.black : Colors.red,
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Slider(
              value: _selectedPortion,
              min: _minPortion,
              max: _maxPortion,
              divisions: ((_maxPortion - _minPortion) / 5).toInt(), // Steps of 5g
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
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.restaurant, color: Colors.white),
              label: Text(_isFeeding ? 'Feeding...' : 'Feed Now'),
              onPressed: _isFeeding ? null : _feedNow,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Status Message
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 16,
                color: _isFeeding ? Colors.blue : (_statusMessage.startsWith('Success') ? Colors.green[700] : Colors.grey[700]),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(), // Pushes the last feed time to the bottom

            // Last Feed Time
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

