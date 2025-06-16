import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:madrasah_attendance/clerk/class_details/class_tab_details.dart';

class ClassList extends StatefulWidget {
  const ClassList({super.key});

  @override
  State<ClassList> createState() => _StaffViewState();
}

class _StaffViewState extends State<ClassList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SingleChildScrollView(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('classes').orderBy('className').snapshots(),
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
                                          "\n\nPlease contact principal to solve this issue..",
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
                            return StreamBuilder<QuerySnapshot>(
                              stream: _firestore.collection('users').where('role', isEqualTo: "teacher").where('assignedClass', isEqualTo: document['className']).snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
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
                                          "Loading...",
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
                                              builder: (context) => ClassTabDetails(className: document['className'])
                                            )
                                          );
                                        },
                                      ),
                                    );
                                  default:
                                    if (snapshot.data!.docs.isNotEmpty) {
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
                                            snapshot.data!.docs[0]['name'],
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
                                                builder: (context) => ClassTabDetails(className: document['className'])
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
                                                builder: (context) => ClassTabDetails(className: document['className'])
                                              )
                                            );
                                          },
                                        ),
                                      );
                                    }
                                }
                              },
                            );
                          },
                        );
                      }
                  }
                },
              )
            ),
          ],
        ),
      ),
    );
  }
}