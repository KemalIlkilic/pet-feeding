import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedPet = 'Whiskers';
  String _selectedFilter = 'Last 7 Days'; // Default filter

  // Mock data for feeding history
  final List<Map<String, dynamic>> _feedingHistory = [
    {'id': 1, 'pet': 'Whiskers', 'type': 'Scheduled', 'label': 'Breakfast', 'portion': 30, 'time': DateTime.now().subtract(const Duration(hours: 3)), 'status': 'Completed'},
    {'id': 2, 'pet': 'Whiskers', 'type': 'Manual', 'label': 'Snack', 'portion': 15, 'time': DateTime.now().subtract(const Duration(hours: 8)), 'status': 'Completed'},
    {'id': 3, 'pet': 'Buddy', 'type': 'Scheduled', 'label': 'Lunch', 'portion': 50, 'time': DateTime.now().subtract(const Duration(days: 1, hours: 2)), 'status': 'Completed'},
    {'id': 4, 'pet': 'Whiskers', 'type': 'Scheduled', 'label': 'Dinner', 'portion': 35, 'time': DateTime.now().subtract(const Duration(days: 1, hours: 14)), 'status': 'Completed'},
    {'id': 5, 'pet': 'Whiskers', 'type': 'Scheduled', 'label': 'Breakfast', 'portion': 30, 'time': DateTime.now().subtract(const Duration(days: 1, hours: 26)), 'status': 'Completed'},
    {'id': 6, 'pet': 'Buddy', 'type': 'Manual', 'label': 'Treat', 'portion': 10, 'time': DateTime.now().subtract(const Duration(days: 2, hours: 5)), 'status': 'Completed'},
    {'id': 7, 'pet': 'Whiskers', 'type': 'Scheduled', 'label': 'Dinner', 'portion': 35, 'time': DateTime.now().subtract(const Duration(days: 2, hours: 14)), 'status': 'Missed'},
    {'id': 8, 'pet': 'Whiskers', 'type': 'Scheduled', 'label': 'Breakfast', 'portion': 30, 'time': DateTime.now().subtract(const Duration(days: 2, hours: 26)), 'status': 'Completed'},
    // Add more mock data as needed
  ];

  // Mock data for weekly summary
  final Map<String, dynamic> _weeklySummary = {
    'totalFeedings': 25,
    'totalPortion': 750, // in grams
    'scheduled': 20,
    'manual': 5,
    'missed': 1,
  };

  List<Map<String, dynamic>> get _filteredHistory {
    // Filter history based on selected pet and filter criteria
    // For simplicity, only filtering by pet for now
    return _feedingHistory.where((entry) => entry['pet'] == _selectedPet).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeding History'),
      ),
      body: Column(
        children: [
          // Pet selection
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: Text(_selectedPet == 'Whiskers' ? '🐱' : (_selectedPet == 'Buddy' ? '🐶' : '🐰'), style: const TextStyle(fontSize: 20)),
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

          // Weekly Summary Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly Summary', // TODO: Make date range dynamic
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem('Total Feedings', _weeklySummary['totalFeedings'].toString()),
                        _buildSummaryItem('Total Portion', '${_weeklySummary['totalPortion']}g'),
                        _buildSummaryItem('Missed', _weeklySummary['missed'].toString(), color: Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filters and Export
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: ['Last 7 Days', 'Last 30 Days', 'All Time'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFilter = newValue!;
                      // TODO: Implement actual filtering logic based on date
                    });
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.download, color: Colors.black),
                  label: const Text('Export Data', style: TextStyle(color: Colors.black)),
                  onPressed: () {
                    // TODO: Implement data export logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export functionality not implemented yet')),
                    );
                  },
                ),
              ],
            ),
          ),

          // History List
          Expanded(
            child: _filteredHistory.isEmpty
                ? Center(
                    child: Text(
                      'No feeding history found for $_selectedPet.',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: _filteredHistory.length,
                    itemBuilder: (context, index) {
                      final entry = _filteredHistory[index];
                      return _buildHistoryItem(entry);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> entry) {
    final DateTime time = entry['time'];
    final String formattedTime = '${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}';
    final String formattedDate = '${time.month}/${time.day}/${time.year}';
    final bool isMissed = entry['status'] == 'Missed';

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isMissed ? Colors.red[100] : Colors.grey[200],
          child: Icon(
            entry['type'] == 'Manual' ? Icons.touch_app : Icons.schedule,
            size: 20,
            color: isMissed ? Colors.red : Colors.black,
          ),
        ),
        title: Text(
          '${entry['label']} (${entry['type']})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$formattedDate at $formattedTime'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry['portion']}g',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              entry['status'],
              style: TextStyle(
                fontSize: 12,
                color: isMissed ? Colors.red : Colors.green[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

