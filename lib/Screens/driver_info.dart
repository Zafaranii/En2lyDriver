import 'package:en2lydriver/Screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/driver_model.dart';

class PersonalIdApp extends StatelessWidget {
  final String phoneNum;
  const PersonalIdApp({super.key, required this.phoneNum});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver Registration',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: PersonalIdPage(phoneNum: phoneNum),
    );
  }
}

class PersonalIdPage extends StatefulWidget {
  final String phoneNum;
  const PersonalIdPage({required this.phoneNum, super.key});

  @override
  State<PersonalIdPage> createState() => _PersonalIdPageState();
}

class _PersonalIdPageState extends State<PersonalIdPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _regNumberController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();

  String? _selectedCarType;
  final List<String> _carTypes = [
    'Chevorlet',
    'Dodge',
    'Ford',
    'Isuzu',
    'Suzuki',
    'Other',

  ];

  bool _validateFields() {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _regNumberController.text.trim().isEmpty ||
        _idNumberController.text.trim().isEmpty ||
        _carModelController.text.trim().isEmpty ||
        _selectedCarType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields with valid data')),
      );
      return false;
    }
    return true;
  }

  Future<void> _saveData() async {
    if (!_validateFields()) return;

    try {
      // Get the current user's UID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final uid = user.uid;

      // Create a Driver instance
      final driver = Driver.New(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        regNumber: _regNumberController.text.trim(),
        idNumber: _idNumberController.text.trim(),
        carType: _selectedCarType!,
        carModel: _carModelController.text.trim(),
        phoneNumber: widget.phoneNum,
        driverId: uid, // Set driverId as Firebase Auth UID
      );

      // Save the driver data to Firestore using UID as the document ID
      await FirebaseFirestore.instance.collection('drivers').doc(uid).set(driver.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saved successfully!')),
      );

      // Navigate to the next screen with the driver object
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePageWidget(driver: driver),
        ),
      );

      // Clear the fields after saving
      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }

  void _clearFields() {
    _firstNameController.clear();
    _lastNameController.clear();
    _regNumberController.clear();
    _idNumberController.clear();
    _carModelController.clear();
    setState(() {
      _selectedCarType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: const Color(0xFF2D3E50),
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  "First Name",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter first name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Last Name",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter last name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Registration Number",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _regNumberController,
                  decoration: InputDecoration(
                    hintText: 'ABC123456',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Personal Id Number",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _idNumberController,
                  decoration: InputDecoration(
                    hintText: 'XXXXXXXXXXXXXXXX',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Car Type",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCarType,
                  items: _carTypes.map((String carType) {
                    return DropdownMenuItem<String>(
                      value: carType,
                      child: Text(carType),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCarType = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Select car type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Car Model",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _carModelController,
                  decoration: InputDecoration(
                    hintText: 'Enter car model',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D3E50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}