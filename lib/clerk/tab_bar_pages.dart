import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:madrasah_attendance/about_page.dart';
import 'package:madrasah_attendance/clerk/class_list.dart';
import 'package:madrasah_attendance/clerk/dashboard_clerk.dart';
import 'package:madrasah_attendance/controller/auth_controller.dart';
import 'package:madrasah_attendance/login_new.dart';

class TabBarPages extends StatefulWidget {
  const TabBarPages({super.key});

  @override
  State<TabBarPages> createState() => _TabBarPagesState();
}

class _TabBarPagesState extends State<TabBarPages> with SingleTickerProviderStateMixin{
  String? _name;
  String? _id;
  String? _image;

  late TabController _tabController;

  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _fetchUsernameAndProfile();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _fetchUsernameAndProfile() async { 
    String currentUserId = authController.getCurrentUserDocumentId();
    FirebaseFirestore.instance.collection('users').where("id", isEqualTo: currentUserId).get().then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        setState(() {
          _name = documentSnapshot['name'];
          _id = documentSnapshot['id'];
          _image = documentSnapshot['image'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Tab(text: 'Dashboard'),
                  Tab(text: 'Classes'),
                ],
              ),
          ),
        ),
      ),

      body: TabBarView(
          controller: _tabController,
          children: [
            // Dashboard
            DashboardClerk(),
            // List kelas
            ClassList(),
          ],
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