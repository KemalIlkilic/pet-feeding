import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class PetProfileScreen extends StatefulWidget {
  final String? petName; // Argument passed from ProfileScreen

  const PetProfileScreen({super.key, this.petName});

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditingBasicInfo = false;
  bool _isEditingFeedingPrefs = false;
  bool _isEditingHealthMetrics = false;
  bool _isLoading = true;


  // Mock data - replace with actual data fetching based on widget.petName
  final _nameController = TextEditingController(text: 'Whiskers');
  final _ageController = TextEditingController(text: '3');
  final _typeController = TextEditingController(text: 'Cat');
  final _breedController = TextEditingController(text: 'Domestic Shorthair');
  final _weightController = TextEditingController(text: '4.5');
  final _genderController = TextEditingController(text: 'Male');

  final _foodTypeController = TextEditingController(text: 'Dry Kibble');
  final _dailyPortionsController = TextEditingController(text: '3');
  final _portionSizeController = TextEditingController(text: '30');
  final _specialDietController = TextEditingController(text: '');

  final _weightTrendController = TextEditingController(text: 'Stable');
  final _consumptionController = TextEditingController(text: '90');
  final _vetVisitController = TextEditingController(text: '2025-03-15');

  @override
  void initState() {
    super.initState();
    // If petName is provided, load the actual pet data
    if (widget.petName != null) {
  print("Loading data for pet: ${widget.petName}");
  print("🐾 widget.petName: ${widget.petName}");

  _loadPetData(); // 🔥 this fetches the data from Firestore
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _typeController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _genderController.dispose();
    _foodTypeController.dispose();
    _dailyPortionsController.dispose();
    _portionSizeController.dispose();
    _specialDietController.dispose();
    _weightTrendController.dispose();
    _consumptionController.dispose();
    _vetVisitController.dispose();
    super.dispose();
  }

  void _toggleEditBasicInfo() {
    setState(() {
      _isEditingBasicInfo = !_isEditingBasicInfo;
    });
  }

  void _toggleEditFeedingPrefs() {
    setState(() {
      _isEditingFeedingPrefs = !_isEditingFeedingPrefs;
    });
  }

  void _toggleEditHealthMetrics() {
    setState(() {
      _isEditingHealthMetrics = !_isEditingHealthMetrics;
    });
  }

  void _saveChanges() async {
  if (_formKey.currentState!.validate()) {
    try {
      await _saveToFirestore();

      setState(() {
        _isEditingBasicInfo = false;
        _isEditingFeedingPrefs = false;
        _isEditingHealthMetrics = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet profile saved to Firestore')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    }
  }
}

  Future<void> _saveToFirestore() async {
  final user = FirebaseAuth.instance.currentUser;

  final docId = widget.petName ?? _nameController.text;
  final petDoc = FirebaseFirestore.instance.collection('pets').doc(docId);

  await petDoc.set({
    'name': _nameController.text,
    'age': _ageController.text,
    'type': _typeController.text,
    'breed': _breedController.text,
    'weight': _weightController.text,
    'gender': _genderController.text,
    'foodType': _foodTypeController.text,
    'dailyPortions': _dailyPortionsController.text,
    'portionSize': _portionSizeController.text,
    'specialDiet': _specialDietController.text,
    'weightTrend': _weightTrendController.text,
    'consumption': _consumptionController.text,
    'vetVisit': _vetVisitController.text,
    'updatedBy': user?.uid ?? "anonymous",
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> _loadPetData() async {
  try {
    if (widget.petName == null) {
      print("⚠️ widget.petName is null");
      setState(() => _isLoading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('pets')
        .doc(widget.petName)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      _ageController.text = data['age'] ?? '';
      _typeController.text = data['type'] ?? '';
      _breedController.text = data['breed'] ?? '';
      _weightController.text = data['weight'] ?? '';
      _genderController.text = data['gender'] ?? '';
      _foodTypeController.text = data['foodType'] ?? '';
      _dailyPortionsController.text = data['dailyPortions'] ?? '';
      _portionSizeController.text = data['portionSize'] ?? '';
      _specialDietController.text = data['specialDiet'] ?? '';
      _weightTrendController.text = data['weightTrend'] ?? '';
      _consumptionController.text = data['consumption'] ?? '';
      _vetVisitController.text = data['vetVisit'] ?? '';
    } else {
      print("⚠️ No document found for: ${widget.petName}");
    }
  } catch (e) {
    print("🔥 Error loading pet data: $e");
  }

  setState(() {
    _isLoading = false; // Always clear loading
  });
}

  @override
Widget build(BuildContext context) {
  if (_isLoading) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: Text('${_nameController.text}\'s Profile'),
    ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet Photo and Name
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 75,
                          backgroundColor: Colors.grey[300],
                          child: const Text('🐱', style: TextStyle(fontSize: 60)),
                          // TODO: Add image loading/selection
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.black,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                              onPressed: () { /* TODO: Implement photo upload */ },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _nameController.text,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_typeController.text} • ${_breedController.text}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Basic Information Card
              _buildInfoCard(
                title: 'Basic Information',
                isEditing: _isEditingBasicInfo,
                onEditToggle: _toggleEditBasicInfo,
                viewContent: Column(
                  children: [
                    _buildViewRow('Name', _nameController.text),
                    _buildViewRow('Age', '${_ageController.text} years'),
                    _buildViewRow('Type', _typeController.text),
                    _buildViewRow('Breed', _breedController.text),
                    _buildViewRow('Weight', '${_weightController.text} kg'),
                    _buildViewRow('Gender', _genderController.text),
                  ],
                ),
                editContent: Column(
                  children: [
                    _buildEditField('Name', _nameController),
                    _buildEditField('Age (years)', _ageController, keyboardType: TextInputType.number),
                    _buildEditField('Type', _typeController), // Consider Dropdown
                    _buildEditField('Breed', _breedController),
                    _buildEditField('Weight (kg)', _weightController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                    _buildEditField('Gender', _genderController), // Consider Dropdown
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Feeding Preferences Card
              _buildInfoCard(
                title: 'Feeding Preferences',
                isEditing: _isEditingFeedingPrefs,
                onEditToggle: _toggleEditFeedingPrefs,
                viewContent: Column(
                  children: [
                    _buildViewRow('Food Type', _foodTypeController.text),
                    _buildViewRow('Daily Portions', '${_dailyPortionsController.text} meals'),
                    _buildViewRow('Portion Size', '${_portionSizeController.text}g per meal'),
                    _buildViewRow('Special Diet', _specialDietController.text.isEmpty ? 'None' : _specialDietController.text),
                  ],
                ),
                editContent: Column(
                  children: [
                    _buildEditField('Food Type', _foodTypeController), // Consider Dropdown
                    _buildEditField('Daily Portions', _dailyPortionsController, keyboardType: TextInputType.number),
                    _buildEditField('Portion Size (g)', _portionSizeController, keyboardType: TextInputType.number),
                    _buildEditField('Special Diet Notes', _specialDietController, hint: 'Enter any special dietary needs'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Health Metrics Card
              _buildInfoCard(
                title: 'Health Metrics',
                isEditing: _isEditingHealthMetrics,
                onEditToggle: _toggleEditHealthMetrics,
                viewContent: Column(
                  children: [
                    _buildHealthMetricRow(Icons.monitor_weight, 'Weight Trend', '${_weightTrendController.text} (${_weightController.text} kg)'),
                    _buildHealthMetricRow(Icons.restaurant_menu, 'Avg. Daily Consumption', '${_consumptionController.text}g per day'),
                    _buildHealthMetricRow(Icons.event, 'Last Vet Visit', _vetVisitController.text),
                  ],
                ),
                editContent: Column(
                  children: [
                    _buildEditField('Weight Trend', _weightTrendController), // Consider Dropdown
                    _buildEditField('Avg. Daily Consumption (g)', _consumptionController, keyboardType: TextInputType.number),
                    _buildEditField('Last Vet Visit', _vetVisitController, keyboardType: TextInputType.datetime, hint: 'YYYY-MM-DD'),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Save Button (only show if any section is being edited)
              if (_isEditingBasicInfo || _isEditingFeedingPrefs || _isEditingHealthMetrics)
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Save Changes'),
                ),
              const SizedBox(height: 20),

              // Add Another Pet Button
              Center(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text('Add Another Pet', style: TextStyle(color: Colors.black)),
                  onPressed: () { /* TODO: Implement add pet logic */ },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required bool isEditing,
    required VoidCallback onEditToggle,
    required Widget viewContent,
    required Widget editContent,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: onEditToggle,
                  child: Text(
                    isEditing ? 'Cancel' : 'Edit',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            isEditing ? editContent : viewContent,
          ],
        ),
      ),
    );
  }

  Widget _buildViewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        ),
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildHealthMetricRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

