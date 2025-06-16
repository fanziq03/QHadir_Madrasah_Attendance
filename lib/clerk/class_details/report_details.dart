import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:madrasah_attendance/clerk/class_details/pdf_report.dart';
import 'package:madrasah_attendance/clerk/class_details/table_report.dart';
import 'package:madrasah_attendance/clerk/save_and_open_pdf.dart';

class ReportDetails extends StatefulWidget {
  final String reportId;

  const ReportDetails({super.key, required this.reportId});

  @override
  State<ReportDetails> createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  int countPresent = 0;
  int countAbsent = 0;
  int countExcused = 0;
  int countTotal = 0;
  String className = "";
  String date = "";

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _countStudents();
  }

  Future<void> _countStudents() async {
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(widget.reportId)
        .get()
        .then((document) {
      setState(() {
        className = document['className'];
        date = document['selectedDate'];
      });
    });

    await FirebaseFirestore.instance
        .collection('reports')
        .doc(widget.reportId)
        .collection('students')
        .get()
        .then((querySnapshot) {
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
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = date.isEmpty ? '' : DateFormat('E, d MMMM, yyyy').format(DateTime.parse(date));

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 2, 88, 96),
        title: Text(
          "Report Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: className.isEmpty || date.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        className,
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
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 2, 88, 96),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
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
                                  formattedDate,
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
                      child: TableReport(
                        className: className,
                        selectedDate: date,
                        reportId: widget.reportId,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final tablePdf = await TablePdfApi.generateTablePdf(
            className: className,
            selectedDate: date,
            reportId: widget.reportId,
          );
          SaveAndOpenDocument.openPdf(tablePdf);
        },
        tooltip: 'Generate PDF',
        child: Icon(Icons.picture_as_pdf, color: Colors.white, size: 30,),
        backgroundColor: const Color.fromARGB(255, 2, 88, 96),
      )
    );
  }
}