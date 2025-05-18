import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_feeder_app/routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _selectedPetId = '';
  String _userName = '';
  String _nextFeedingTime = 'No schedule yet';
  String _nextFeedingLabel = '—';

  @override
  void initState() {
    super.initState();
    _loadUserPet();
    _loadUserName();
    _loadNextFeedingTime();
  }

  void _loadUserPet() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('pets')
        .where('updatedBy', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _selectedPetId = snapshot.docs.first.id;
      });
    }
  }

  void _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      setState(() {
        _userName = doc.data()?['fullName'] ?? '';
      });
    }
  }

  void _loadNextFeedingTime() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dbRef =
        FirebaseDatabase.instance.ref('schedules/${user.uid}/userSchedules');

    final snapshot = await dbRef.get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      TimeOfDay? nextTime;
      String? nextLabel;

      for (final entry in data.entries) {
        final schedule = Map<String, dynamic>.from(entry.value);
        if (schedule['active'] == true) {
          final hour = schedule['hour'];
          final minute = schedule['minute'];
          final label = schedule['label'] ?? 'Scheduled Feed';

          final scheduledTime = TimeOfDay(hour: hour, minute: minute);
          if (nextTime == null ||
              scheduledTime.hour < nextTime.hour ||
              (scheduledTime.hour == nextTime.hour &&
                  scheduledTime.minute < nextTime.minute)) {
            nextTime = scheduledTime;
            nextLabel = label;
          }
        }
      }

      if (nextTime != null) {
        final formattedTime = nextTime.format(context);
        setState(() {
          _nextFeedingTime = formattedTime;
          _nextFeedingLabel = nextLabel ?? 'Scheduled Feed';
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.pushNamed(context, AppRoutes.schedule);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.history);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.settings);
        break;
    }
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, AppRoutes.profile);
  }

  void _navigateToPetProfile() {
    Navigator.pushNamed(context, AppRoutes.petProfile,
        arguments: _selectedPetId);
  }

  void _navigateToManualFeed() {
    Navigator.pushNamed(context, AppRoutes.manualFeed);
  }

  Future<void> _goLive() async {
    final url = 'http://192.168.8.104';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _navigateToProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Welcome, ${_userName.isNotEmpty ? _userName : 'User'}!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select Pet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pets')
                    .where('updatedBy',
                        isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  final pets = snapshot.data!.docs;
                  return SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final petDoc = pets[index];
                        final pet = petDoc.data() as Map<String, dynamic>;
                        final petId = petDoc.id;
                        final petName = pet['name'] ?? '';
                        final petIcon = pet['icon'] ?? '🐾';
                        final isSelected = petId == _selectedPetId;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPetId = petId;
                            });
                          },
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected
                                  ? Border.all(color: Colors.black, width: 2)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(petIcon,
                                        style: const TextStyle(fontSize: 30)),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(petName,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildNextFeedingCard(),
              const SizedBox(height: 16),
              _buildLiveMonitoringCard(),
              const SizedBox(height: 24),
              const Text('Quick Actions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionButton(
                      icon: Icons.pets,
                      label: 'Pet Profile',
                      onTap: _navigateToPetProfile),
                  _buildQuickActionButton(
                      icon: Icons.restaurant,
                      label: 'Feed Now',
                      onTap: _navigateToManualFeed),
                  _buildQuickActionButton(
                      icon: Icons.history,
                      label: 'History',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.history)),
                  _buildQuickActionButton(
                      icon: Icons.settings,
                      label: 'Settings',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.settings)),
                ],
              ),
              const SizedBox(height: 24),
              _buildActivityHeader(),
              const SizedBox(height: 8),
              _buildActivityItem(
                  icon: Icons.restaurant,
                  title: 'Breakfast',
                  description: '1 portion dispensed',
                  time: '7:30 AM',
                  status: 'Completed'),
              const Divider(),
              _buildActivityItem(
                  icon: Icons.schedule,
                  title: 'Schedule Updated',
                  description: 'Added dinner at 6:30 PM',
                  time: 'Yesterday'),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToManualFeed,
        backgroundColor: Colors.black,
        child: const Icon(Icons.restaurant, color: Colors.white),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildNextFeedingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.grey[200], shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.schedule, size: 24)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_nextFeedingTime,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(_nextFeedingLabel,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMonitoringCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Live Monitoring',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _goLive,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam),
                    SizedBox(width: 10),
                    Text('Go Live',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
                child: Text('Monitor your pet in real-time',
                    style: TextStyle(fontSize: 14, color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Recent Activity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.history),
          child: const Text('View All', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String description,
    required String time,
    String? status,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              if (status != null)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(status,
                      style: TextStyle(fontSize: 10, color: Colors.green[700])),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
