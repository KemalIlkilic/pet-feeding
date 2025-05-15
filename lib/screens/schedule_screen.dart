import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Map<String, dynamic>> _schedules = [];
  final List<String> _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  Timer? _scheduleChecker;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
    _startScheduleChecker();
  }

  @override
  void dispose() {
    _scheduleChecker?.cancel();
    super.dispose();
  }

  void _startScheduleChecker() {
    _scheduleChecker = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkAndTriggerFeeding();
    });
  }

  void _checkAndTriggerFeeding() {
    final now = TimeOfDay.now();
    final today = DateTime.now();
    final weekday = (today.weekday % 7); // 0 = Sunday, 6 = Saturday

    for (var schedule in _schedules) {
      final TimeOfDay scheduledTime = schedule['time'];
      final List<bool> days = schedule['days'];
      final bool active = schedule['active'];
      final String? lastExecuted = schedule['lastExecuted'];
      final String id = schedule['id'];

      final nowString =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      if (active &&
          days[weekday] &&
          scheduledTime.hour == now.hour &&
          scheduledTime.minute == now.minute &&
          lastExecuted != nowString) {
        _triggerFeeding(id, nowString);
      }
    }
  }

  Future<void> _triggerFeeding(String scheduleId, String todayDate) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final db = FirebaseDatabase.instance;

    await db.ref('/commands/feedNow').set(true);
    await db
        .ref('schedules/${user.uid}/userSchedules/$scheduleId/lastExecuted')
        .set(todayDate);

    print("✅ Feeding triggered from schedule!");
  }

  void _loadSchedules() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dbRef =
        FirebaseDatabase.instance.ref('schedules/${user.uid}/userSchedules');
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        setState(() => _schedules = []);
        return;
      }

      final List<Map<String, dynamic>> loaded = [];
      data.forEach((key, value) {
        final v = Map<String, dynamic>.from(value);
        loaded.add({
          'id': key,
          'label': v['label'],
          'portion': v['portion'],
          'days': List<bool>.from(v['days']),
          'active': v['active'],
          'time': TimeOfDay(hour: v['hour'], minute: v['minute']),
          'lastExecuted': v['lastExecuted'],
        });
      });

      setState(() => _schedules = loaded);
    });
  }

  void _toggleScheduleActive(String id, bool newValue) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseDatabase.instance
        .ref('schedules/${user.uid}/userSchedules/$id')
        .update({'active': newValue});
  }

  void _deleteSchedule(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseDatabase.instance
        .ref('schedules/${user.uid}/userSchedules/$id')
        .remove();
  }

  void _addOrEditSchedule({Map<String, dynamic>? existing}) {
    showDialog(
      context: context,
      builder: (context) => _buildScheduleDialog(existing: existing),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    final time = schedule['time'] as TimeOfDay;
    final days = schedule['days'] as List<bool>;
    final label = schedule['label'];
    final portion = schedule['portion'];
    final active = schedule['active'];
    final id = schedule['id'];

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _addOrEditSchedule(existing: schedule),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteSchedule(id),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${time.hour}:${time.minute.toString().padLeft(2, '0')}'),
                Switch(
                  value: active,
                  onChanged: (value) => _toggleScheduleActive(id, value),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(7, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: days[i] ? Colors.black : Colors.grey[300],
                  ),
                  child: Text(
                    _dayLabels[i],
                    style:
                        TextStyle(color: days[i] ? Colors.white : Colors.black),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text('Portion: $portion g'),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleDialog({Map<String, dynamic>? existing}) {
    final isEditing = existing != null;
    final labelController =
        TextEditingController(text: existing?['label'] ?? '');
    final portionController =
        TextEditingController(text: existing?['portion']?.toString() ?? '30');
    TimeOfDay selectedTime =
        existing?['time'] ?? const TimeOfDay(hour: 12, minute: 0);
    List<bool> selectedDays =
        List<bool>.from(existing?['days'] ?? List.filled(7, true));

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Schedule' : 'New Schedule'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(labelText: 'Label'),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) setState(() => selectedTime = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(7, (i) {
                    return GestureDetector(
                      onTap: () =>
                          setState(() => selectedDays[i] = !selectedDays[i]),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              selectedDays[i] ? Colors.black : Colors.grey[300],
                        ),
                        child: Text(
                          _dayLabels[i],
                          style: TextStyle(
                              color: selectedDays[i]
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: portionController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Portion (g)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                final Map<String, dynamic> data = {
                  'label': labelController.text,
                  'portion': int.tryParse(portionController.text) ?? 30,
                  'hour': selectedTime.hour,
                  'minute': selectedTime.minute,
                  'days': selectedDays,
                  'active': true,
                  'lastExecuted': isEditing && existing?['lastExecuted'] != null
                      ? existing!['lastExecuted']
                      : null,
                };

                final dbRef = FirebaseDatabase.instance
                    .ref('schedules/${user.uid}/userSchedules');

                if (isEditing) {
                  await dbRef.child(existing!['id']).update(data);
                } else {
                  await dbRef.push().set(data);
                }

                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feeding Schedule')),
      body: _schedules.isEmpty
          ? const Center(child: Text('No schedules yet'))
          : ListView.builder(
              itemCount: _schedules.length,
              itemBuilder: (context, i) => _buildScheduleCard(_schedules[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditSchedule(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
