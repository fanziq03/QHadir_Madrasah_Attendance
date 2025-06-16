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
import 'package:madrasah_attendance/clerk/dashboard_charts/donut_chart.dart';
import 'package:madrasah_attendance/controller/auth_controller.dart';
import 'package:madrasah_attendance/login_new.dart';
import 'package:madrasah_attendance/teacher/circle_chart.dart';
import 'package:madrasah_attendance/teacher/class_attendance.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class DashboardClerk extends StatefulWidget {
  const DashboardClerk({super.key});

  @override
  State<DashboardClerk> createState() => _DashboardTeacherState();
}

class _DashboardTeacherState extends State<DashboardClerk> {
  String? _date;
  String? _name;
  String? _id;
  String? _image;
  String? _className;

  int _totalStudent = 0;
  int _totalClass = 0;
  int _totalStaff = 0;
  int _totalTeacher = 0;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _clerkStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _classStream;

  final authController = Get.find<AuthController>();

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _fetchTime();
    _initStreams().then((_){
      _fetchCounts();
      setState(() {
        _initialized = true;
      });
    });
  }

  Future<void> _fetchCounts() async {
    final studentSnapshot = await FirebaseFirestore.instance.collection('students').get();
    final classSnapshot = await FirebaseFirestore.instance.collection('classes').get();
    final staffSnapshot = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'clerk').get();
    final teacherSnapshot = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'teacher').get();

    setState(() {
      _totalStudent = studentSnapshot.docs.length;
      _totalClass = classSnapshot.docs.length;
      _totalStaff = staffSnapshot.docs.length;
      _totalTeacher = teacherSnapshot.docs.length;
    });
  }

  Future<void> _initStreams() async {
    String currentUserId = authController.getCurrentUserDocumentId();
    _clerkStream = FirebaseFirestore.instance
        .collection('users')
        .where("id", isEqualTo: currentUserId)
        .snapshots();

    await _clerkStream?.first.then((value) {
      QuerySnapshot querySnapshot = value;
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot document = querySnapshot.docs.first;
        setState(() {
          _name = document['name'];
          _id = document['id'];
        });
      }
    });

    setState(() {
      _initialized = true;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // BODY
      body: _initialized? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder(
                stream: _clerkStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    QuerySnapshot classSnapshot = snapshot.data!;
                    DocumentSnapshot classDoc = classSnapshot.docs.first;
                    return Row(
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
                                    backgroundImage: classDoc.get('image')!= null
                                    ? Image.network(classDoc['image'], fit: BoxFit.cover,).image
                                      : Image.network(
                                        "https://cdn-icons-png.flaticon.com/512/149/149071.png",
                                        fit: BoxFit.cover,
                                      ).image,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(
                  thickness: 4,
                  color: const Color.fromARGB(255, 2, 88, 96),
                  height: 1,
                ),
              ),

              const SizedBox(height: 8,),

              // Grid view of total student, total staff, total teacher, total class
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2, // number of columns
                childAspectRatio: 1.6 / 1, // width / height ratio
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 2, 88, 96),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$_totalStaff",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Total Staff",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 2, 88, 96),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$_totalTeacher",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Total Teacher",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 2, 88, 96),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$_totalClass",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Total Class",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 2, 88, 96),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$_totalStudent",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Total Student",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16,),

              // Chart
              DonutChart(),
            ],
          ),
        ),
      ) : Center(child: CircularProgressIndicator()),
    );
  }
}