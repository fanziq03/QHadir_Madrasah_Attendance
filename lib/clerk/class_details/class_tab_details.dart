import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:madrasah_attendance/about_page.dart';
import 'package:madrasah_attendance/clerk/class_details/class_report.dart';
import 'package:madrasah_attendance/clerk/class_details/class_students.dart';
import 'package:madrasah_attendance/clerk/class_details/class_teacher.dart';
import 'package:madrasah_attendance/clerk/class_list.dart';
import 'package:madrasah_attendance/clerk/dashboard_clerk.dart';
import 'package:madrasah_attendance/controller/auth_controller.dart';
import 'package:madrasah_attendance/login_new.dart';

class ClassTabDetails extends StatefulWidget {
  final String className;
  
  const ClassTabDetails({super.key, required this.className});

  @override
  State<ClassTabDetails> createState() => _TabBarPagesState();
}

class _TabBarPagesState extends State<ClassTabDetails> with SingleTickerProviderStateMixin{
  String? _name;
  String? _id;
  String? _image;
  late String _className;

  late TabController _tabController;

  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _className = widget.className;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 2, 88, 96),
        title: Text(
          "$_className",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Container(
            color: Colors.white,
            child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.teal,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: Colors.teal, width: 3),
                  insets: EdgeInsets.fromLTRB(80, 0, 80, 0),
                ),
                tabs: [
                  Tab(text: 'Teacher'),
                  Tab(text: 'Student'),
                  Tab(text: 'Report'),
                ],
              ),
          ),
        ),
      ),

      body: TabBarView(
          controller: _tabController,
          children: [
            // Teacher
            ClassTeacher(className: _className),
            // List kelas
            ClassStudents(className: _className),
            // Report
            ClassReport(className: _className),
          ],
        ),
    );
  }
}