import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:madrasah_attendance/Widget/input_field.dart';

class AddTeacher extends StatefulWidget {
  const AddTeacher({super.key});

  @override
  State<AddTeacher> createState() => _AddStaffState();
}

class _AddStaffState extends State<AddTeacher> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  File? _image;

  bool _obscureText = true;

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
          "Add Teacher",
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
                InputField(
                  title: 'Password',
                  hint: 'Enter password',
                  controller: _passwordController,
                  obscureText: _obscureText,
                  onToggleObscureText: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final ImagePicker _picker = ImagePicker();
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    setState(() {
                      if (image!= null) {
                        _image = File(image.path);
                      } else {
                        _image = null;
                      }
                    });
                  },
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.teal),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _image != null
                          ? Image.file(_image!)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera, size: 40, color: Colors.teal),
                                const SizedBox(height: 10,),
                                Text(
                                  'Select an Image',
                                  style: TextStyle(
                                    color: Colors.teal,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_nameController.text.isEmpty || _idController.text.isEmpty || _passwordController.text.isEmpty) {
            _showSnackBar('Please fill all fields');
          } else if (_image == null) {
            _showSnackBar('Please select an image');
          } else {
            final ref = FirebaseStorage.instance.ref().child('profile_Image').child('${DateTime.now().millisecondsSinceEpoch}.jpg');
            await ref.putFile(_image!);
            final imageUrl = await ref.getDownloadURL();

            // Save data to Firestore
            final FirebaseFirestore _firestore = FirebaseFirestore.instance;
            await _firestore.collection('users').add({
              'name': _nameController.text,
              'id': _idController.text,
              'password': _passwordController.text,
              'image': imageUrl,
              'role': "teacher",
              'assignedClass': null,
            });

            _showSnackBar('Teacher added successfully');
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