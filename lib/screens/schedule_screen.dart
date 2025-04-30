import 'package:flutter/material.dart';
import 'package:pet_feeder_app/routes.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Mock data for feeding schedules
  final List<Map<String, dynamic>> _schedules = [
    {
      'id': 1,
      'time': TimeOfDay(hour: 7, minute: 30),
      'days': [true, true, true, true, true, true, true], // All days
      'portion': 30,
      'active': true,
      'label': 'Breakfast',
    },
    {
      'id': 2,
      'time': TimeOfDay(hour: 12, minute: 0),
      'days': [true, true, true, true, true, false, false], // Weekdays only
      'portion': 25,
      'active': true,
      'label': 'Lunch',
    },
    {
      'id': 3,
      'time': TimeOfDay(hour: 18, minute: 30),
      'days': [true, true, true, true, true, true, true], // All days
      'portion': 35,
      'active': true,
      'label': 'Dinner',
    },
  ];

  // Selected pet
  String _selectedPet = 'Whiskers';

  // Day labels for schedule
  final List<String> _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  void _addNewSchedule() {
    // Show dialog to create a new schedule
    showDialog(
      context: context,
      builder: (context) => _buildScheduleDialog(),
    );
  }

  void _editSchedule(Map<String, dynamic> schedule) {
    // Show dialog to edit an existing schedule
    showDialog(
      context: context,
      builder: (context) => _buildScheduleDialog(schedule: schedule),
    );
  }

  void _deleteSchedule(int id) {
    // Show confirmation dialog before deleting
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this feeding schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _schedules.removeWhere((schedule) => schedule['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Schedule deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleScheduleActive(int id, bool newValue) {
    setState(() {
      final scheduleIndex = _schedules.indexWhere((schedule) => schedule['id'] == id);
      if (scheduleIndex != -1) {
        _schedules[scheduleIndex]['active'] = newValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeding Schedule'),
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

          // Schedule list
          Expanded(
            child: _schedules.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No feeding schedules yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _addNewSchedule,
                          child: const Text('Add Your First Schedule'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = _schedules[index];
                      return _buildScheduleCard(schedule);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _schedules.isNotEmpty
          ? FloatingActionButton(
              onPressed: _addNewSchedule,
              backgroundColor: Colors.black,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    final TimeOfDay time = schedule['time'];
    final List<bool> days = schedule['days'];
    final int portion = schedule['portion'];
    final bool active = schedule['active'];
    final String label = schedule['label'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.schedule, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: active,
                  onChanged: (value) => _toggleScheduleActive(schedule['id'], value),
                  activeColor: Colors.black,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Days',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(7, (index) {
                        return Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: days[index] ? Colors.black : Colors.grey[200],
                          ),
                          child: Center(
                            child: Text(
                              _dayLabels[index],
                              style: TextStyle(
                                color: days[index] ? Colors.white : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Portion',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$portion g',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _editSchedule(schedule),
                  child: const Text('Edit', style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () => _deleteSchedule(schedule['id']),
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleDialog({Map<String, dynamic>? schedule}) {
    // If schedule is provided, we're editing, otherwise creating new
    final bool isEditing = schedule != null;

    // Form controllers
    final labelController = TextEditingController(text: isEditing ? schedule!['label'] : '');
    final portionController = TextEditingController(text: isEditing ? schedule!['portion'].toString() : '30');

    // Time and days
    TimeOfDay selectedTime = isEditing ? schedule!['time'] : const TimeOfDay(hour: 12, minute: 0);
    List<bool> selectedDays = isEditing ? List<bool>.from(schedule!['days']) : List.filled(7, true);

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Feeding Schedule' : 'New Feeding Schedule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Label (e.g., Breakfast, Lunch)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Time picker
                const Text('Feeding Time', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')} ${selectedTime.hour >= 12 ? 'PM' : 'AM'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Days selection
                const Text('Repeat on Days', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDays[index] = !selectedDays[index];
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectedDays[index] ? Colors.black : Colors.grey[200],
                        ),
                        child: Center(
                          child: Text(
                            _dayLabels[index],
                            style: TextStyle(
                              color: selectedDays[index] ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Portion size
                TextField(
                  controller: portionController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Portion Size (g)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate inputs
                if (labelController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a label')),
                  );
                  return;
                }

                if (portionController.text.isEmpty || int.tryParse(portionController.text) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid portion size')),
                  );
                  return;
                }

                if (!selectedDays.contains(true)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select at least one day')),
                  );
                  return;
                }

                // Create or update schedule
                final newSchedule = {
                  'id': isEditing ? schedule!['id'] : DateTime.now().millisecondsSinceEpoch,
                  'time': selectedTime,
                  'days': selectedDays,
                  'portion': int.parse(portionController.text),
                  'active': isEditing ? schedule!['active'] : true,
                  'label': labelController.text,
                };

                setState(() {
                  if (isEditing) {
                    final index = _schedules.indexWhere((s) => s['id'] == schedule!['id']);
                    if (index != -1) {
                      _schedules[index] = newSchedule;
                    }
                  } else {
                    _schedules.add(newSchedule);
                  }
                });

                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }
}
