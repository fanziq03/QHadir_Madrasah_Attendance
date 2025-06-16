import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TableAttendance extends StatefulWidget {
  final String className;
  final DateTime selectedDate;

  const TableAttendance({super.key, required this.className, required this.selectedDate});

  @override
  State<TableAttendance> createState() => _TableAttendanceState();
}

class _TableAttendanceState extends State<TableAttendance> {
  List<Student> students = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getStudents();
  }

  Future<void> _getStudents() async {
    await FirebaseFirestore.instance
        .collection('attendance')
        .where('className', isEqualTo: widget.className)
        .where('selectedDate', isEqualTo: DateFormat('yyyy-MM-dd').format(widget.selectedDate))
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot attendanceDoc = querySnapshot.docs[0];
        attendanceDoc.reference.collection('students').get().then((querySnapshot) {
          students = querySnapshot.docs.map((doc) => Student.fromMap(doc.data())).toList();
          setState(() {});
        });
      } else {
        FirebaseFirestore.instance
            .collection('students')
            .where('class', isEqualTo: widget.className)
            .get()
            .then((querySnapshot) {
          students = querySnapshot.docs.map((doc) => Student.fromMap(doc.data())).toList();
          setState(() {});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _scrollController,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        child: Table(
          columnWidths: {
            0: FixedColumnWidth(MediaQuery.of(context).size.width * 0.12), // 10% of the screen width
            1: FixedColumnWidth(MediaQuery.of(context).size.width * 0.6), // 30% of the screen width
            2: FixedColumnWidth(MediaQuery.of(context).size.width * 0.3), // 20% of the screen width
            3: FixedColumnWidth(MediaQuery.of(context).size.width * 0.15), // 40% of the screen width
          },
          border: TableBorder.all(),
          children: [
            TableRow(
              children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    color: const Color.fromARGB(255, 2, 88, 96),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "No.",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ),
                    ),
                  )
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    color: const Color.fromARGB(255, 2, 88, 96),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "Name",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ),
                    ),
                  )
                ),
                                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    color: const Color.fromARGB(255, 2, 88, 96),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "ID",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ),
                    ),
                  )
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    color: const Color.fromARGB(255, 2, 88, 96),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "Status",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ),
                    ),
                  )
                ),
              ],
            ),
            ...students.map((student) {
              return TableRow(
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Text("${students.indexOf(student) + 1}.")),
                    )
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(student.name,),
                    )
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(student.id),
                    )
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.fill,
                    child: Container(
                      decoration: BoxDecoration(
                        color: getColor(student.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color getColor(String status) {
    if (status == 'default') {
      return Color.fromARGB(255, 52, 164, 153);
    } else if (status == 'present') {
      return Colors.green.shade300;
    } else if (status == 'absent') {
      return Colors.red.shade300;
    } else {
      return Colors.orange.shade300;
    }
  }
}

class Student {
  String name;
  String id;
  String status;

  Student({required this.name, required this.id, required this.status});

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      name: map['name'],
      id: map['id'],
      status: map['status'],
    );
  }
}