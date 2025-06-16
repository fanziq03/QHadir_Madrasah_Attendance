import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:madrasah_attendance/principal/class/add_class.dart';
import 'package:madrasah_attendance/principal/class/class_details.dart';
import 'package:madrasah_attendance/principal/teacher/add_teacher.dart';
import 'package:lottie/lottie.dart'; // Add this import

class ClassView extends StatefulWidget {
  const ClassView({super.key});

  @override
  State<ClassView> createState() => _StaffViewState();
}

class _StaffViewState extends State<ClassView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 2, 88, 96),
        title: Text(
          "Class",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('classes').orderBy("className").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Text('Loading....');
                    default:
                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  'assets/lottie/cat.json',
                                  width: 200,
                                  height: 200,
                                  repeat: true,
                                  fit: BoxFit.contain,
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          "No classes available!",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          "\n\nSeems like no classes have been created yet..",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot document = snapshot.data!.docs[index];
                            return FutureBuilder(
                              future: _getTeacherName(document['className']),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Card(
                                    color: Colors.teal,
                                    child: ListTile(
                                      title: Text(
                                        document['className'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                      ),
                                      subtitle: Text(
                                        snapshot.data ?? "",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                      ),
                                      onTap: (){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ClassDetails(className: document['className']),
                                          )
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return Card(
                                    color: Colors.teal,
                                    child: ListTile(
                                      title: Text(
                                        document['className'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                      ),
                                      subtitle: Text(
                                        "No teacher assigned yet",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                      ),
                                      onTap: (){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ClassDetails(className: document['className']),
                                          )
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        );
                      }
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddClass(),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 2, 88, 96),
        child: Icon(
         Icons.add,
          color: Colors.white,
          size: 34,
        ),
      ),
    );
  }

  Future<String?> _getTeacherName(String className) async {
    QuerySnapshot teachers = await _firestore.collection('users').where('role', isEqualTo: 'teacher').get();
    for (var teacher in teachers.docs) {
      if (teacher['assignedClass'] == className) {
        return teacher['name'];
      }
    }
    return "No teacher assigned yet";
  }
}