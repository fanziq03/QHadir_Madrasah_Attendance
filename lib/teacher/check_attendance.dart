import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:madrasah_attendance/Widget/custom_shape/circular_container.dart';
import 'package:madrasah_attendance/teacher/dashboard_teacher.dart';
import 'package:madrasah_attendance/teacher/table_attendance.dart';

class CheckAttendancePage extends StatefulWidget {
  final String classTeacher;
  final String className;
  final DateTime selectedDate;
  final List<Map<String, dynamic>> students;

  const CheckAttendancePage({
    super.key,
    required this.classTeacher,
    required this.className,
    required this.selectedDate,
    required this.students,
  });

  @override
  State<CheckAttendancePage> createState() => _CheckAttendancePageState();
}

class _CheckAttendancePageState extends State<CheckAttendancePage> {
  int countPresent = 0;
  int countAbsent = 0;
  int countExcused = 0;
  int countTotal = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _countStudents();
  }

  Future<void> _countStudents() async {
    await FirebaseFirestore.instance
    .collection('attendance')
    .where('className', isEqualTo: widget.className)
    .where('selectedDate', isEqualTo: DateFormat('yyyy-MM-dd').format(widget.selectedDate))
    .get()
    .then((querySnapshot) async {
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot attendanceDoc = querySnapshot.docs[0];
          await attendanceDoc.reference.collection('students').get().then((querySnapshot) {
            countPresent = 0;
            countAbsent = 0;
            countExcused = 0;
            countTotal = 0;
            querySnapshot.docs.forEach((document) {
              switch (document['status']) {
                case "present":
                  setState(() {
                    countPresent++;
                    countTotal++;
                  });
                  break;
                case "absent":
                  setState(() {
                    countAbsent++;
                    countTotal++;
                  });
                  break;
                case "excused":
                  setState(() {
                    countExcused++;
                    countTotal++;
                  });
                  break;
                default:
                  break;
              }
            });
          });
        } else {
          await FirebaseFirestore.instance
            .collection('students')
            .where('class', isEqualTo: widget.className)
            .get()
            .then((querySnapshot) {
              countPresent = 0;
              countAbsent = 0;
              countExcused = 0;
              countTotal = 0;
              querySnapshot.docs.forEach((document) {
                switch (document['status']) {
                  case 'present':
                    setState(() {
                      countPresent++;
                      countTotal++;
                    });
                    break;
                  case 'absent':
                    setState(() {
                      countAbsent++;
                      countTotal++;
                    });
                    break;
                  case "excused":
                    setState(() {
                      countExcused++;
                      countTotal++;
                    });
                    break;
                  default:
                    break;
                }
              });
            });
        }
      });
  }

  Future<void> _resetStudentStatuses() async {
    await FirebaseFirestore.instance
      .collection('students')
      .where('class', isEqualTo: widget.className)
      .get()
      .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        document.reference.update({
          'status': 'present',
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String date = DateFormat('E, d MMMM, yyyy').format(widget.selectedDate);

    return Scaffold(
      // APPBAR
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 2, 88, 96),
        title: Text(
          "Confirmation",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),

      // BODY
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.className,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 140,
                width: double.infinity,
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 2, 88, 96),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Set space evenly
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)
                            ),
                            width: 100,
                            height: 70,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      "$countPresent",
                                      style: TextStyle(
                                        color: Colors.green.shade600,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Present",
                                      style: TextStyle(
                                        color: const Color.fromARGB(255, 2, 88, 96),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container( // Wrap in a container
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)
                            ),
                            width: 100,
                            height: 70,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      "$countAbsent",
                                      style: TextStyle(
                                        color: Colors.red.shade600,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Absent",
                                      style: TextStyle(
                                        color: const Color.fromARGB(255, 2, 88, 96),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container( // Wrap in a container
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)
                            ),
                            width: 100,
                            height: 70,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      "$countExcused",
                                      style: TextStyle(
                                        color: Colors.orange.shade600,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Excused",
                                      style: TextStyle(
                                        color: const Color.fromARGB(255, 2, 88, 96),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                "List of students:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1)
                ),
                child: TableAttendance(
                  className: widget.className, // This table
                  selectedDate: widget.selectedDate,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Confirmation'),
                content: Text('Are you sure want to submit the attendance of this class?'),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Submit'),
                    onPressed: () async {
                      final dateFormatter = DateFormat('yyyy-MM-dd');
                      final selectedDateStr = dateFormatter.format(widget.selectedDate);

                      // Check if document already exists in "attendance" collection
                      final attendanceQuery = await FirebaseFirestore.instance
                          .collection('attendance')
                          .where('className', isEqualTo: widget.className)
                          .where('selectedDate', isEqualTo: selectedDateStr)
                          .get();

                      // Check if document already exists in "reports" collection
                      final reportsQuery = await FirebaseFirestore.instance
                          .collection('reports')
                          .where('className', isEqualTo: widget.className)
                          .where('selectedDate', isEqualTo: selectedDateStr)
                          .get();

                      if (attendanceQuery.docs.isNotEmpty && reportsQuery.docs.isNotEmpty) {
                        // Update document if it already exists
                        final attendanceDoc = attendanceQuery.docs.first;
                        final reportsDoc = reportsQuery.docs.first;

                        await attendanceDoc.reference.update({
                          'classTeacher': widget.classTeacher,
                          'className': widget.className,
                          'selectedDate': selectedDateStr,
                        });

                        await reportsDoc.reference.update({
                          'classTeacher': widget.classTeacher,
                          'className': widget.className,
                          'selectedDate': selectedDateStr,
                        });

                        List<Map<String, dynamic>> students = [];
                        await attendanceDoc.reference.collection('students').get().then((querySnapshot) {
                          querySnapshot.docs.forEach((document) {
                            students.add({
                              'class': document['class'],
                              'gender': document['gender'],
                              'name': document['name'],
                              'id': document['id'],
                              'status': document['status'],
                            });
                          });
                        });

                        // Delete all students from attendance and reports
                        await attendanceDoc.reference.collection('students').get().then((querySnapshot) {
                          querySnapshot.docs.forEach((document) async {
                            await document.reference.delete();
                          });
                        });

                        await reportsDoc.reference.collection('students').get().then((querySnapshot) {
                          querySnapshot.docs.forEach((document) async {
                            await document.reference.delete();
                          });
                        });

                        for (var student in students) {
                          await attendanceDoc.reference.collection('students').add(student);
                          await reportsDoc.reference.collection('students').add(student);
                        }

                        // Add new students to attendance and reports
                        // await attendanceDoc.reference.collection('students').get().then((querySnapshot) {
                        //   querySnapshot.docs.forEach((document) async {
                        //     // Get the current status of the student
                        //     String status = document['status'];

                        //     await attendanceDoc.reference.collection('students').add({
                        //       'class': document['class'],
                        //       'gender': document['gender'],
                        //       'name': document['name'],
                        //       'id': document['id'],
                        //       'status': status,
                        //     });

                        //     await reportsDoc.reference.collection('students').add({
                        //       'class': document['class'],
                        //       'gender': document['gender'],
                        //       'name': document['name'],
                        //       'id': document['id'],
                        //       'status': status,
                        //     });
                        //   });
                        // });

                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => DashboardTeacher()),
                        );
                      } else {
                        // Create new document if it doesn't exist
                        await FirebaseFirestore.instance.collection('attendance').add({
                          'classTeacher': widget.classTeacher,
                          'className': widget.className,
                          'selectedDate': selectedDateStr,
                        }).then((attendanceDoc) async {
                          await FirebaseFirestore.instance.collection('reports').add({
                            'classTeacher': widget.classTeacher,
                            'className': widget.className,
                            'selectedDate': selectedDateStr,
                          }).then((reportDoc) async {
                            await FirebaseFirestore.instance
                                .collection('students')
                                .where('class', isEqualTo: widget.className)
                                .get()
                                .then((querySnapshot) {
                              querySnapshot.docs.forEach((document) async {
                                // Get the current status of the student
                                String status = document['status'];

                                await attendanceDoc.collection('students').add({
                                  'class': document['class'],
                                  'gender': document['gender'],
                                  'name': document['name'],
                                  'id': document['id'],
                                  'status': status,
                                });

                                await reportDoc.collection('students').add({
                                  'class': document['class'],
                                  'gender': document['gender'],
                                  'name': document['name'],
                                  'id': document['id'],
                                  'status': status,
                                });
                              });
                            });
                          });

                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder:(context) => DashboardTeacher()),
                          );
                        });
                      }

                      await _resetStudentStatuses();
                    },
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: const Color.fromARGB(255, 2, 88, 96),
        child: Icon(
          Icons.upload,
          color: Colors.white,
        ),
      ),
    );
  }
}