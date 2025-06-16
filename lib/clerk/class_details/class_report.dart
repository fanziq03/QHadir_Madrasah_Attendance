import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:madrasah_attendance/clerk/class_details/report_details.dart';
import 'package:lottie/lottie.dart';

class ClassReport extends StatefulWidget {
  final String className;

  const ClassReport({super.key, required this.className});

  @override
  State<ClassReport> createState() => _ClassTeacherState();
}

class _ClassTeacherState extends State<ClassReport> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('reports').where('className', isEqualTo: widget.className).orderBy("selectedDate", descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                if (snapshot.data!.docs.isEmpty) {
                  return Center(
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
                                  "No attendance data found!",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "\n\nSeems like there are no attendance submitted yet for this class..",
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
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      return Card(
                        color: Colors.teal,
                        child: ListTile(
                          title: Text(
                            DateFormat('E, d MMMM, yyyy').format(DateTime.parse(document['selectedDate'])),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                          ),
                          subtitle: Text(
                            'Submitted by: ${document['classTeacher']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReportDetails(
                                  reportId: document.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
            }
          },
        ),
      ),
    );
  }
}