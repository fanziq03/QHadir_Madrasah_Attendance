import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:madrasah_attendance/Widget/input_field.dart';

class AddStudent extends StatefulWidget {
  const AddStudent({super.key});

  @override
  State<AddStudent> createState() => _AddStaffState();
}

class _AddStaffState extends State<AddStudent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  String _gender = 'male';

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 2, 88, 96),
        title: Text(
          "Add Student",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                InputField(
                  title: 'Name',
                  hint: 'Enter name',
                  controller: _nameController,
                ),
                SizedBox(height: 16),
                InputField(
                  title: 'ID Number',
                  hint: 'Enter ID number',
                  controller: _idController,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Radio(
                      value: 'male',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value as String;
                        });
                      }
                    ),
                    Text(
                      "Male"
                    ),
                    Radio(
                      value: 'female',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value as String;
                        });
                      }
                    ),
                    Text(
                      "Female"
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_nameController.text.isEmpty || _idController.text.isEmpty) {
            _showSnackBar('Please fill all fields');
          } else {
            // Save data to Firestore
            final FirebaseFirestore _firestore = FirebaseFirestore.instance;
            await _firestore.collection('students').add({
              'name': _nameController.text,
              'id': _idController.text,
              'gender': _gender,
              'status': "present",
              "class": null,
            });

            _showSnackBar('Student added successfully');
            Navigator.pop(context);
          }
        },
        backgroundColor: const Color.fromARGB(255, 2, 88, 96),
        child: Icon(
          Icons.upload,
          color: Colors.white,
          size: 30,
        ),
      )
    );
  }
}