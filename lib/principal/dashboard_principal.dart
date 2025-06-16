import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:madrasah_attendance/Widget/custom_shape/circular_container.dart';
import 'package:madrasah_attendance/about_page.dart';
import 'package:madrasah_attendance/controller/auth_controller.dart';
import 'package:madrasah_attendance/login_new.dart';
import 'package:madrasah_attendance/principal/class/class_view.dart';
import 'package:madrasah_attendance/principal/staff/staff_view.dart';
import 'package:madrasah_attendance/principal/student/student_view.dart';
import 'package:madrasah_attendance/principal/teacher/teacher_view.dart';
import 'package:madrasah_attendance/teacher/circle_chart.dart';
import 'package:madrasah_attendance/teacher/class_attendance.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class DashboardPrincipal extends StatefulWidget {
  const DashboardPrincipal({super.key});

  @override
  State<DashboardPrincipal> createState() => _DashboardTeacherState();
}

class _DashboardTeacherState extends State<DashboardPrincipal> {
  String? _date;
  String? _name;
  String? _id;
  String? _image;
  String? _className;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _teacherStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _classStream;

  final authController = Get.find<AuthController>();

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _fetchTime();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    String userId = authController.getCurrentUserDocumentId();
    if (userId.isNotEmpty) {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').where("id", isEqualTo: userId).get();
      if (userSnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = userSnapshot.docs.first;
        if (documentSnapshot.exists) {
          setState(() {
            _id = documentSnapshot.get('id');
            _name = documentSnapshot.get('name');
            _image = documentSnapshot.get('image');
          });
        }
      }
    }
  }

  Future<DocumentSnapshot?> _getDocumentSnapshot() async {
    String userId = authController.getCurrentUserDocumentId();
    if (userId.isNotEmpty) {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').where("id", isEqualTo: userId).get();
      if (userSnapshot.docs.isNotEmpty) {
        return userSnapshot.docs.first;
      }
    }
    return null;
  }

  void _fetchTime() {
    var now = DateTime.now();
    var dateFormat = DateFormat('E, d MMMM, yyyy');
    setState(() {
      _date = dateFormat.format(now);
    });
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 18) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }

  Future<int> _getStudentCount(String className) async {
    QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
       .collection('students')
       .where('class', isEqualTo: className)
       .get();
    return studentSnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // APPBAR
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 2, 88, 96),
        title: Text(
          "QHadir",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),

      // BODY
      body: FutureBuilder(
        future: _getDocumentSnapshot(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              DocumentSnapshot documentSnapshot = snapshot.data!;
                _id = documentSnapshot.get('id');
                _name = documentSnapshot.get('name');
                _image = documentSnapshot.get('image');
            }
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded( // Wrap with Expanded
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Dashboard",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      _getGreeting(),
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage: Image.network(
                                    _image??"https://cdn-icons-png.flaticon.com/512/149/149071.png",
                                    fit: BoxFit.cover,
                                  ).image,
                                )
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Divider(
                      thickness: 4,
                      color: const Color.fromARGB(255, 2, 88, 96),
                      height: 1,
                    ),
                  ),
            
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
            
                  // GridView
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2, // number of columns
                    childAspectRatio: 1 / 1, // width / height ratio
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => StaffView()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(255, 2, 88, 96),
                          ),
                          child: Center(
                            child: Text(
                              "Staff",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherView()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(255, 2, 88, 96),
                          ),
                          child: Center(
                            child: Text(
                              "Teacher",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ClassView()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(255, 2, 88, 96),
                          ),
                          child: Center(
                            child: Text(
                              "Class",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => StudentView()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(255, 2, 88, 96),
                          ),
                          child: Center(
                            child: Text(
                              "Student",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
      ),

      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                color: const Color.fromARGB(255, 2, 88, 96),
                padding: const EdgeInsets.all(12),
                height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 100,
                      width: 120,
                      child: Image.asset(
                        "assets/images/logoMadrasah.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            _name ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _id ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: const Color.fromARGB(255, 2, 88, 96),
                ),
                title: Text(
                  'About App',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 2, 88, 96),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.exit_to_app,
                  color: const Color.fromARGB(255, 2, 88, 96),
                ),
                title: Text(
                  'Log Out',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 2, 88, 96),
                  ),
                ),
                onTap: () {
                  authController.setCurrentUserDocumentId('');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginNew()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}