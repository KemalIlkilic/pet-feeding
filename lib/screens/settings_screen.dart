import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_feeder_app/routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isAutomaticMode = true;
  bool _lowFoodNotification = true;
  bool _feedingSuccessNotification = true;
  bool _feedingFailureNotification = true;
  final _deviceIdController = TextEditingController(text: 'PFD-12345XYZ');
  bool _isConnected = true;

  @override
  void dispose() {
    _deviceIdController.dispose();
    super.dispose();
  }

  void _scanQrCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR code scanning not implemented yet')),
    );
  }

  void _linkDevice() {
    print('Linking device: ${_deviceIdController.text}');
    setState(() {
      _isConnected = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device linked successfully (simulated)')),
    );
  }

  Future<void> _sendPasswordResetEmail() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.email != null) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No logged-in user email found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          _buildSectionTitle('Device Management'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _deviceIdController,
                  decoration: InputDecoration(
                    labelText: 'Device ID',
                    hintText: 'Enter or scan device ID',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scanQrCode,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.check_circle : Icons.cancel,
                          color: _isConnected ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isConnected ? 'Connected' : 'Not Connected',
                          style: TextStyle(
                            color: _isConnected ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _linkDevice,
                      child: const Text('Link Device'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          _buildSectionTitle('Operating Mode'),
          SwitchListTile(
            title: const Text('Automatic Feeding Mode'),
            subtitle: Text(_isAutomaticMode
                ? 'Schedules are active'
                : 'Manual feeding only'),
            value: _isAutomaticMode,
            onChanged: (bool value) {
              setState(() {
                _isAutomaticMode = value;
              });
            },
            activeColor: Colors.black,
            secondary: const Icon(Icons.schedule),
          ),
          const Divider(height: 32),
          _buildSectionTitle('Notifications'),
          SwitchListTile(
            title: const Text('Low Food Alert'),
            value: _lowFoodNotification,
            onChanged: (bool value) {
              setState(() {
                _lowFoodNotification = value;
              });
            },
            activeColor: Colors.black,
            secondary: const Icon(Icons.warning_amber),
          ),
          SwitchListTile(
            title: const Text('Feeding Success'),
            value: _feedingSuccessNotification,
            onChanged: (bool value) {
              setState(() {
                _feedingSuccessNotification = value;
              });
            },
            activeColor: Colors.black,
            secondary: const Icon(Icons.check_circle_outline),
          ),
          SwitchListTile(
            title: const Text('Feeding Failure / Missed'),
            value: _feedingFailureNotification,
            onChanged: (bool value) {
              setState(() {
                _feedingFailureNotification = value;
              });
            },
            activeColor: Colors.black,
            secondary: const Icon(Icons.error_outline),
          ),
          const Divider(height: 32),
          _buildSectionTitle('Account'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _sendPasswordResetEmail,
          ),
          const Divider(height: 32),
          _buildSectionTitle('Help & Support'),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('FAQ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to FAQ
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_support_outlined),
            title: const Text('Contact Us'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to Contact
            },
          ),
          const Divider(height: 32),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Center(
              child: Text(
                'App Version 1.0.0 (Build 1)',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
