import 'package:flutter/material.dart';
import 'package:pet_feeder_app/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  final List<Map<String, dynamic>> _pets = [
    {'name': 'Whiskers', 'type': 'Cat', 'icon': '🐱'},
    {'name': 'Buddy', 'type': 'Dog', 'icon': '🐶'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = doc.data();
        if (data != null) {
          setState(() {
            _nameController.text = data['fullName'] ?? '';
            _emailController.text = data['email'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _navigateToPetProfile(String petName) {
    Navigator.pushNamed(context, AppRoutes.petProfile, arguments: petName);
  }

  void _addPet() {
    print('Add new pet clicked');
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(Icons.person, size: 60, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _nameController.text,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Account Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildInfoField(
                label: 'Full Name',
                controller: _nameController,
              ),
              const SizedBox(height: 15),
              _buildInfoField(
                label: 'Email Address',
                controller: _emailController,
              ),
              const SizedBox(height: 30),
              const Text(
                'My Pets',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pets.length,
                itemBuilder: (context, index) {
                  final pet = _pets[index];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: Text(pet['icon'], style: const TextStyle(fontSize: 20)),
                      ),
                      title: Text(pet['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(pet['type']),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _navigateToPetProfile(pet['name']),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Center(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text('Add New Pet', style: TextStyle(color: Colors.black)),
                  onPressed: _addPet,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Account Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                onTap: () {
                  print('Delete account clicked');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            controller.text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}