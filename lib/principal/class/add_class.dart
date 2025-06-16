import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:madrasah_attendance/Widget/input_field.dart';

class AddClass extends StatefulWidget {
  const AddClass({super.key});

  @override
  State<AddClass> createState() => _AddStaffState();
}

class _AddStaffState extends State<AddClass> {
  final _classNameController = TextEditingController();

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
          "Add Class",
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
            child: Column(
              children: [
                InputField(
                  title: 'Class Name',
                  hint: 'Enter class name',
                  controller: _classNameController,
                ),
                //SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_classNameController.text.isEmpty) {
            _showSnackBar('Please fill all fields');
          } else {
            // Save data to Firestore
            final FirebaseFirestore _firestore = FirebaseFirestore.instance;
            await _firestore.collection('classes').add({
              'className': _classNameController.text,
            });

            _showSnackBar('Class added successfully');
            Navigator.pop(context);
          }
        },
        backgroundColor: const Color.fromARGB(255, 2, 88, 96),
        child: Icon(
          Icons.upload,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}