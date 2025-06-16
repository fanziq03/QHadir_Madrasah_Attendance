import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:madrasah_attendance/Widget/input_field.dart';
import 'package:madrasah_attendance/clerk/tab_bar_pages.dart';
import 'package:madrasah_attendance/controller/auth_controller.dart';
import 'package:madrasah_attendance/principal/dashboard_principal.dart';
import 'package:madrasah_attendance/teacher/dashboard_teacher.dart';

class LoginNew extends StatefulWidget {
  const LoginNew({super.key});

  @override
  State<LoginNew> createState() => _LoginNewState();
}

class _LoginNewState extends State<LoginNew> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

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

  Future<void> _loginUser() async {
    try {
      String id = _idController.text.trim();
      String password = _passwordController.text.trim();

      if (id.isEmpty || password.isEmpty) {
        _showSnackBar('Please fill in all fields');
        return;
      }

      // Check the user's role in Firestore
      FirebaseFirestore.instance.collection('users').where('id', isEqualTo: id).where('password', isEqualTo: password).get().then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          String firestoreRole = querySnapshot.docs.first.get('role');
          if (firestoreRole != null) {

            final authController = Get.find<AuthController>();
            authController.setCurrentUserDocumentId(id); //Akan simpan ID ni

            // Login successful, navigate to the each UI
            final Map<String, Widget> dashboardMap = {
              'clerk': TabBarPages(),
              'teacher': DashboardTeacher(),
              'principal': DashboardPrincipal(),
            };
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => dashboardMap[firestoreRole]!),
            );
          } else {
            // Role not found, show an error message
            _showSnackBar('Role not found');
          }
        } else {
          // User not found in Firestore, show an error message
          _showSnackBar('User not found');
        }
      });
    } catch (e) {
      // Handle errors
      _showSnackBar('An error occurred');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 2, 88, 96),
                  Colors.teal
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  'assets/images/logo_madrasah.png',
                  height: 180, // Adjust the height
                  width: 180, // Adjust the width
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              ),
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView( // Add SingleChildScrollView
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      InputField(
                        title: "ID Number",
                        titleColor: Colors.black,
                        hint: "Enter your ID number",
                        hintColor: Colors.black.withOpacity(0.6),
                        controller: _idController,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      InputField(
                        title: "Password",
                        titleColor: Colors.black,
                        hint: "Enter your password",
                        hintColor: Colors.black.withOpacity(0.6),
                        obscureText: _obscureText,
                        controller: _passwordController,
                        onToggleObscureText: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        }
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      const Text(
                        'Forgot your password?\n\nContact the principal to solve this problem',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.teal
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      GestureDetector(
                        onTap: _loginUser,
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 2, 88, 96),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}