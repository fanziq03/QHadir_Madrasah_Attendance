import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:madrasah_attendance/Widget/date_time_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DonutChart extends StatefulWidget {

  const DonutChart({super.key});

  @override
  State<DonutChart> createState() => _CircleChartState();
}

class _CircleChartState extends State<DonutChart> {
  List<ChartData> chartData = [
    ChartData('Absent', 0, Colors.red),
    ChartData('Present', 0, Colors.green),
    ChartData('Excused', 0, Colors.orange),
  ];

  DateTime? _selectedDate;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _attendanceStream;

  String _className = "No class selected";

  Stream<QuerySnapshot<Map<String, dynamic>>>? _classesStream;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _initStreams();
    _classesStream = FirebaseFirestore.instance.collection('classes').snapshots();
  }

  Future<void> _selectClass(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _classesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            QuerySnapshot<Map<String, dynamic>> classesSnapshot = snapshot.data!;
            List<DropdownMenuItem<String>> items = [
              DropdownMenuItem<String>(
                value: "No class selected",
                child: Text("No class selected"),
              ),
            ];
            items.addAll(classesSnapshot.docs.map((doc) {
              return DropdownMenuItem<String>(
                value: doc['className'],
                child: Text(doc['className']),
              );
            }).toList());
            return AlertDialog(
              title: Text("Select a class"),
              content: DropdownButtonFormField(
                value: _className,
                onChanged: (value) {
                  setState(() {
                    _className = value!;
                  });
                  Navigator.pop(context);
                },
                items: items,
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void _initStreams() {
    _attendanceStream = FirebaseFirestore.instance
      .collection('reports')
      .where('className', isEqualTo: _className)
      .where('selectedDate', isEqualTo: DateFormat('yyyy-MM-dd').format(_selectedDate!))
      .snapshots();
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
            _initStreams();
          },
          className: _className,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 1, 42, 44),
        borderRadius: BorderRadius.circular(12),
      ),
      height: MediaQuery.of(context).size.height * 0.72, // 60%
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Attendance Summary",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Divider(
                thickness: 4,
                color: Colors.teal,
                height: 1,
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 6,),
                Text(
                  "Select a class:",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 4,),

            GestureDetector(
              onTap: (){
                _selectClass(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _className == "No class selected"? "No class selected" : _className,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10,),

            Row(
              children: [
                const SizedBox(width: 6,),
                Text(
                  "Select a date:",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4,),
            GestureDetector(
              onTap: (){
                _selectDate(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('E, d MMMM, yyyy').format(_selectedDate!),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _attendanceStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    QuerySnapshot<Map<String, dynamic>> reportSnapshot = snapshot.data!;
                    if (reportSnapshot.docs.isNotEmpty) {
                      DocumentSnapshot<Map<String, dynamic>> reportDoc = reportSnapshot.docs[0];
                      Stream<QuerySnapshot<Map<String, dynamic>>> studentsStream = reportDoc.reference.collection('students').snapshots();

                      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: studentsStream,
                        builder: (context, studentsSnapshot) {
                          if (studentsSnapshot.hasData) {
                            QuerySnapshot<Map<String, dynamic>> studentsQuerySnapshot = studentsSnapshot.data!;
                            int absentCount = 0;
                            int presentCount = 0;
                            int excusedCount = 0;
                            int totalCount = studentsQuerySnapshot.docs.length;

                            for (var studentDoc in studentsQuerySnapshot.docs) {
                              switch (studentDoc['status']) {
                                case 'absent':
                                  absentCount++;
                                  break;
                                case 'present':
                                  presentCount++;
                                  break;
                                case 'excused':
                                  excusedCount++;
                                  break;
                                default:
                                  break;
                              }
                            }

                            chartData = [
                              if (absentCount > 0) ChartData('Absent', absentCount, Colors.red),
                              if (presentCount > 0) ChartData('Present', presentCount, Colors.green),
                              if (excusedCount > 0) ChartData('Excused', excusedCount, Colors.orange),
                            ];

                            return Column(
                              children: [
                                Expanded(
                                  child: SfCircularChart(
                                    series: [
                                      DoughnutSeries<ChartData, String>(
                                        dataSource: chartData,
                                        xValueMapper: (ChartData data, _) => data.label,
                                        yValueMapper: (ChartData data, _) => data.value,
                                        pointColorMapper: (ChartData data, _) => data.color,
                                        radius: "90%",
                                        innerRadius: "50%",
                                        explode: true,
                                        dataLabelMapper: (ChartData data, _) => data.value.toString(),
                                        dataLabelSettings: DataLabelSettings(
                                          isVisible: true,
                                          textStyle: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          labelPosition: ChartDataLabelPosition.inside,
                                        ),
                                      ),
                                    ],
                                    legend: Legend(
                                      isVisible: true,
                                      position: LegendPosition.bottom,
                                      orientation: LegendItemOrientation.horizontal,
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      iconHeight: 18,
                                      iconWidth: 18,
                                    ),
                                  ),
                                ),
                                Text(
                                  "Total Students: $totalCount",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      );
                    } else {
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
                            const SizedBox(height: 20,),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "No data for the selected date",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String label;
  final int value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}