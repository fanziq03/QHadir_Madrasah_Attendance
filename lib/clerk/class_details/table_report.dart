import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TableReport extends StatefulWidget {
  final String className;
  final String selectedDate;
  final String reportId;

  const TableReport({super.key, required this.className, required this.reportId, required this.selectedDate});

  @override
  State<TableReport> createState() => _TableReportState();
}

class _TableReportState extends State<TableReport> {
  int countPresent = 0;
  int countAbsent = 0;
  int countExcused = 0;
  int countTotal = 0;
  List<Student> students = [];
  String className = "";

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getStudents();
  }

  Future<void> _getStudents() async {

    await FirebaseFirestore.instance
       .collection('reports')
       .where('className', isEqualTo: widget.className)
       .where('selectedDate', isEqualTo: widget.selectedDate)
       .get()
       .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot reportDoc = querySnapshot.docs[0];
        reportDoc.reference.collection('students').get().then((querySnapshot) {
          students = querySnapshot.docs.map((doc) => Student.fromMap(doc.data())).toList();
          setState(() {
            countPresent = 0;
            countAbsent = 0;
            countExcused = 0;
            countTotal = 0;
            for (var student in students) {
              if (student.status == 'present') {
                countPresent++;
              } else if (student.status == 'absent') {
                countAbsent++;
              } else {
                countExcused++;
              }
              countTotal++;
            }
          });
        });
      } else {
        FirebaseFirestore.instance
           .collection('students')
           .where('class', isEqualTo: widget.className)
           .get()
           .then((querySnapshot) {
          students = querySnapshot.docs.map((doc) => Student.fromMap(doc.data())).toList();
          setState(() {
            countPresent = 0;
            countAbsent = 0;
            countExcused = 0;
            countTotal = 0;
            for (var student in students) {
              if (student.status == 'present') {
                countPresent++;
              } else if (student.status == 'absent') {
                countAbsent++;
              } else {
                countExcused++;
              }
              countTotal++;
            }
          });
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
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
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
    if (status == 'present') {
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