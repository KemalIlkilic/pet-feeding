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
  final _nameController = TextEditingController(text: 'User Name');
  final _emailController = TextEditingController(text: 'user@example.com');
  final _phoneController = TextEditingController(text: '+0 00 000 0000');
  bool _isEditing = false;

  final List<Map<String, dynamic>> _pets = [
    {'name': 'Whiskers', 'type': 'Cat', 'icon': '🐱'},
    {'name': 'Buddy', 'type': 'Dog', 'icon': '🐶'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      print('Saving profile...');
      print('Name: ${_nameController.text}');
      print('Email: ${_emailController.text}');
      print('Phone: ${_phoneController.text}');
      _toggleEdit();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
    }
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
        actions: [
          TextButton(
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
            child: Text(
              _isEditing ? 'Save' : 'Edit',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
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
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.black,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                onPressed: () {},
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _isEditing
                        ? SizedBox(
                            width: 200,
                            child: TextFormField(
                              controller: _nameController,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                hintText: 'Enter your name',
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                          )
                        : Text(
                            _nameController.text,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text('Account Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildInfoField(
                label: 'Full Name',
                controller: _nameController,
                isEditing: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              _buildInfoField(
                label: 'Email Address',
                controller: _emailController,
                isEditing: _isEditing,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              _buildInfoField(
                label: 'Phone Number',
                controller: _phoneController,
                isEditing: _isEditing,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              const Text('My Pets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              const Text('Account Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Account'),
                      content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      final user = FirebaseAuth.instance.currentUser;

                      if (user != null) {
                        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                        await user.delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Account deleted successfully')),
                        );
                        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                      }
                    } catch (e) {
                      print('Delete failed: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete account: $e')),
                      );
                    }
                  }
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
    required bool isEditing,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 5),
        isEditing
            ? TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                validator: validator,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  border: OutlineInputBorder(),
                ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(controller.text, style: const TextStyle(fontSize: 16)),
              ),
      ],
    );
  }
}
