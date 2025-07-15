import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  String? _selectedGender;
  String? _selectedSport;
  String? _selectedPosition;

  bool _isLoading = true;
  bool _hasProfile = false;
  Map<String, dynamic>? _profileData;

  final List<String> _sports = ['Cricket', 'Football'];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  final Map<String, List<String>> _positions = {
    'Cricket': ['Batsman', 'Bowler', 'All-rounder'],
    'Football': ['Forward', 'Midfielder', 'Defender', 'Goalkeeper'],
  };

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          _hasProfile = true;
          _profileData = doc.data();
        });
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedGender != null &&
        _selectedSport != null &&
        _selectedPosition != null) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': _nameController.text.trim(),
          'age': _ageController.text.trim(),
          'gender': _selectedGender,
          'sport': _selectedSport,
          'position': _selectedPosition,
        });

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the details')),
      );
    }
  }

  Widget _profileItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value ?? '-'),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.green, width: 1.8),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    if (_hasProfile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Your Profile'),
          backgroundColor: Colors.green,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile Summary',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  const Divider(thickness: 1.5),
                  _profileItem('Name', _profileData?['name']),
                  _profileItem('Age', _profileData?['age']),
                  _profileItem('Gender', _profileData?['gender']),
                  _profileItem('Preferred Sport', _profileData?['sport']),
                  _profileItem('Position', _profileData?['position']),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Let us know more about you!',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Name', Icons.person),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Age', Icons.calendar_today),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your age' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    items: _genders
                        .map((gender) => DropdownMenuItem(
                            value: gender, child: Text(gender)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedGender = val),
                    decoration: _inputDecoration('Gender', Icons.wc),
                    validator: (value) =>
                        value == null ? 'Please select your gender' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedSport,
                    items: _sports
                        .map((sport) =>
                            DropdownMenuItem(value: sport, child: Text(sport)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSport = val;
                        _selectedPosition = null;
                      });
                    },
                    decoration:
                        _inputDecoration('Preferred Sport', Icons.sports),
                    validator: (value) =>
                        value == null ? 'Please select your sport' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedPosition,
                    items: (_positions[_selectedSport] ?? [])
                        .map((position) => DropdownMenuItem(
                              value: position,
                              child: Text(position),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedPosition = val),
                    decoration:
                        _inputDecoration('Position', Icons.sports_baseball),
                    validator: (value) =>
                        value == null ? 'Please select your position' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Submit & Continue',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
