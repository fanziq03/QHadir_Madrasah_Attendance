import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:madrasah_attendance/Widget/custom_shape/circular_container.dart';
import 'package:madrasah_attendance/Widget/date_time_picker.dart';
import 'package:madrasah_attendance/teacher/check_attendance.dart';

class ClassAttendance extends StatefulWidget {
  final String classTeacher;
  final String className;

  const ClassAttendance({
    super.key,
    required this.classTeacher,
    required this.className,
  });

  @override
  State<ClassAttendance> createState() => _ClassAttendanceState();
}

class _ClassAttendanceState extends State<ClassAttendance> {

  DateTime _selectedDate = DateTime.now();
  String _currentStatus = 'present';
  List<DateTime> _tickedDate = [];
  bool _hasStudents = true;

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

  Future<void> _updateStudentStatusInAttendance(String attendanceId, String studentId, String newStatus) async {
    await FirebaseFirestore.instance
      .collection('attendance')
      .doc(attendanceId)
      .collection('students')
      .doc(studentId)
      .update({
        'status': newStatus,
      });
  }

  void _fetchTickedDates() async {
    await FirebaseFirestore.instance
      .collection('attendance')
      .where('className', isEqualTo: widget.className)
      .get()
      .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        DateTime date = DateTime.parse(document['selectedDate']);
        print('Adding date to _tickedDate: $date');
        if (!_tickedDate.contains(date)) {
          _tickedDate.add(date);
        }
      });
      setState(() {});
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DateTimePicker(
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
          className: widget.className,
        ),
      ),
    );
  }

  String getStatus(String currentStatus) {
    if (currentStatus == 'present') {
      return 'absent';
    } else if (currentStatus == 'absent') {
      return 'excused';
    } else {
      return 'present';
    }
  }

  Color getColor(String status) {
    if (status == 'present') {
      return Colors.green.shade600;
    } else if (status == 'absent') {
      return Colors.red.shade600;
    } else {
      return Colors.orange.shade600;
    }
  }

  Future<void> _updateStudentStatus(String studentId, String newStatus) async {
    await FirebaseFirestore.instance.collection('students').doc(studentId).update({
      'status': newStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // APPBAR
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            await _resetStudentStatuses();
            Navigator.pop(context);
          },
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 2, 88, 96),
        title: Text(
          "Attendance",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          )
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      widget.className,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  _selectDate(context);
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 2, 88, 96),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Center(
                          child: Text(
                            DateFormat('E, d MMMM, yyyy').format(_selectedDate),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                            ),
                          ),
                          const SizedBox(width: 8,),
                          Text(
                            "Present",
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                            ),
                          ),
                          const SizedBox(width: 8,),
                          Text(
                            "Absent",
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                            ),
                          ),
                          const SizedBox(width: 8,),
                          Text(
                            "Excused",
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                  .collection('attendance')
                  .where('className', isEqualTo: widget.className)
                  .where('selectedDate', isEqualTo: DateFormat('yyyy-MM-dd').format(_selectedDate))
                  .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    // No attendance found for the selected date, show all students
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                        .collection('students')
                        .where('class', isEqualTo: widget.className)
                        .orderBy("name")
                        .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        
                        if (snapshot.data!.docs.isEmpty) {
                          // No classes found, show a message
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
                                          "No students for you to tick!",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          "\n\nPlease contact the staff to\nsolve this issue..",
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
                        }

                        return Visibility(
                          visible: snapshot.hasData,
                          child: Column(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height * 0.64,
                                child: ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot studentDoc = snapshot.data!.docs[index];
                                    return GestureDetector(
                                      onTap: () async{
                                        _currentStatus = getStatus(studentDoc['status']);
                                        await _updateStudentStatus(studentDoc.id, _currentStatus);
                                      },
                                      child: Container(
                                        height: 90,
                                        margin: EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: getColor(studentDoc['status']),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 55,
                                              right: -6,
                                              child: CircularContainer(
                                                height: 50,
                                                width: 50,
                                                backgroundColor: const Color.fromARGB(255, 2, 88, 96).withOpacity(0.2),
                                              ),
                                            ),
                                            Positioned(
                                              top: -30,
                                              right: -40,
                                              child: CircularContainer(
                                                height: 100,
                                                width: 100,
                                                backgroundColor: const Color.fromARGB(255, 2, 88, 96).withOpacity(0.2),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    studentDoc['id'],
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                  Text(
                                                    studentDoc['name'],
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  DocumentSnapshot attendanceDoc = snapshot.data!.docs[0];
                  return StreamBuilder<QuerySnapshot>(
                    stream: attendanceDoc.reference.collection('students').orderBy("name").snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.data!.docs.isEmpty) {
                        // No classes found, show a message
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
                                        "No classes for you to tick!",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        "\n\nPlease contact the staff to\nassign a class for you..",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
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
                      }

                      return Visibility(
                        visible: snapshot.hasData,
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.64,
                              child: ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot studentDoc = snapshot.data!.docs[index];
                                  return GestureDetector(
                                    onTap: () async{
                                      _currentStatus = getStatus(studentDoc['status']);
                                      await _updateStudentStatusInAttendance(attendanceDoc.id, studentDoc.id, _currentStatus);
                                    },
                                    child: Container(
                                      height: 90,
                                      margin: EdgeInsets.only(
                                        bottom: 8.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: getColor(studentDoc['status']),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: 55,
                                            right: -6,
                                            child: CircularContainer(
                                              height: 50,
                                              width: 50,
                                              backgroundColor: const Color.fromARGB(255, 2, 88, 96).withOpacity(0.2),
                                            ),
                                          ),
                                          Positioned(
                                                                          top: -30,
                                            right: -40,
                                            child: CircularContainer(
                                              height: 100,
                                              width: 100,
                                              backgroundColor: const Color.fromARGB(255, 2, 88, 96).withOpacity(0.2),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  studentDoc['id'],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.fade,
                                                ),
                                                Text(
                                                  studentDoc['name'],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      
      floatingActionButton: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('students')
          .where('class', isEqualTo: widget.className)
          .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          if (snapshot.data!.docs.isEmpty) {
            _hasStudents = false;
          } else {
            _hasStudents = true;
          }

          //return
          return FloatingActionButton(
            onPressed: _hasStudents ? () async {
              List<Map<String, dynamic>> students = [];

              await FirebaseFirestore.instance
                .collection('attendance')
                .where('className', isEqualTo: widget.className)
                .where('selectedDate', isEqualTo: DateFormat('yyyy-MM-dd').format(_selectedDate))
                .get()
                .then((querySnapshot) {
                if (querySnapshot.docs.isNotEmpty) {
                  DocumentSnapshot attendanceDoc = querySnapshot.docs[0];
                  attendanceDoc.reference.collection('students').get().then((querySnapshot) {
                    querySnapshot.docs.forEach((document) {
                      students.add({
                        'id': document['id'],
                        'name': document['name'],
                        'status': document['status'],
                      });
                    });
                  });
                } else {
                  FirebaseFirestore.instance
                    .collection('students')
                    .where('class', isEqualTo: widget.className)
                    .get()
                    .then((querySnapshot) {
                    querySnapshot.docs.forEach((document) {
                      students.add({
                        'id': document['id'],
                        'name': document['name'],
                        'status': 'present',
                      });
                    });
                  });
                }
              });

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckAttendancePage(
                    classTeacher: widget.classTeacher,
                    className: widget.className,
                    selectedDate: _selectedDate,
                    students: students,
                  ),
                ),
              );
            } : null,
            backgroundColor: _hasStudents ? const Color.fromARGB(255, 2, 88, 96) : Colors.grey,
            child: Icon(
              Icons.navigate_next,
              color: Colors.white,
              size: 40,
            ),
          );
        }
      )
    );
  }
}