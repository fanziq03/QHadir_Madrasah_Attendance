import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:madrasah_attendance/clerk/class_details/table_report.dart';
import 'package:madrasah_attendance/clerk/save_and_open_pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class TablePdfApi {
  static Future<File> generateTablePdf(
      {required String className, required String selectedDate, required String reportId}) async {
    final pdf = Document();

    final headers = ["No.", "Name", "ID", "Status"];

    final logo = (await rootBundle.load('assets/images/logoMadrasahBlack.png')).buffer.asUint8List();

    List<Student> students = [];

    String formattedDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.parse(selectedDate));
    String pdfDate = DateFormat('d_MMMM_yyyy').format(DateTime.parse(selectedDate));
    String filename = "$className _$pdfDate.pdf";
    String generatedTime = DateFormat('EEEE, d MMMM yyyy, hh:mm a').format(DateTime.now());

    // Get the students' data from Firestore
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(reportId)
        .collection('students')
        .get()
        .then((querySnapshot) {
      students = querySnapshot.docs.map((doc) => Student.fromMap(doc.data())).toList();
    });

    final data = students.map((student) => [
      "${students.indexOf(student) + 1}.",
      student.name,
      student.id,
      student.status.substring(0, 1).toUpperCase() + student.status.substring(1),
    ]).toList();

    //Kira student
    int totalStudents = students.length;
    int totalPresent = students.where((student) => student.status.toLowerCase() == 'present').length;
    int totalAbsent = students.where((student) => student.status.toLowerCase() == 'absent').length;
    int totalExcused = students.where((student) => student.status.toLowerCase() == 'excused').length;

    pdf.addPage(
      MultiPage(

        header: (context){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customHeader(pdf, logo),

              SizedBox(height: 2 * PdfPageFormat.mm),

              Text(
                "Generated on: $generatedTime",
                style: TextStyle(fontSize: 10),
              ),

              SizedBox(height: 2 * PdfPageFormat.mm),
            ]
          );
        },

        build: (context) => [

          Text(
            "Attendance report of $className on $formattedDate",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold
            )
          ),

          SizedBox(height: 2 * PdfPageFormat.mm),
          
          TableHelper.fromTextArray(
            data: data,
            headers: headers,
            cellAlignment: Alignment.center,
            tableWidth: TableWidth.max,
            columnWidths: {
              0: FixedColumnWidth(40),
              1: FixedColumnWidth(330),
              2: FixedColumnWidth(110),
              3: FixedColumnWidth(70),
            },
            // headerHeight: 80,
            // cellHeight: 80,
            border: TableBorder.all(width: 1, color: PdfColors.grey300),
            headerDecoration:const BoxDecoration(color: PdfColors.grey300),
            headerStyle: TextStyle(fontWeight: FontWeight.bold),
            cellAlignments: {
              0: Alignment.centerLeft,
              1: Alignment.centerLeft,
              2: Alignment.centerLeft,
              3: Alignment.centerLeft,
            },
            oddRowDecoration: const BoxDecoration(
              color: PdfColors.grey100,
            )
            // cellStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
          ),

          SizedBox(height: 1 * PdfPageFormat.mm),

          // Text(
          //   "Total Students: $totalStudents",
          //   style: TextStyle(fontSize: 12),
          // ),
          // Text(
          //   "Total Present: $totalPresent",
          //   style: TextStyle(fontSize: 12),
          // ),
          // Text(
          //   "Total Absent: $totalAbsent",
          //   style: TextStyle(fontSize: 12),
          // ),
          // Text(
          //   "Total Excuded: $totalExcused",
          //   style: TextStyle(fontSize: 12),
          // ),
        ],

        footer: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(),
              Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: TextStyle(fontSize: 10),
              ),
              //SizedBox(height: 2 * PdfPageFormat.mm),
            ]
          );
        }
      ),
    );

    return SaveAndOpenDocument.savePdf(name: filename, pdf: pdf);
  }

  static Widget customHeader(Document pdf, Uint8List logo) => Container(
    padding: const EdgeInsets.only(bottom: 3 * PdfPageFormat.mm),
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide.none,
      )
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image(
          MemoryImage(logo),
          width: 60,
          height: 60,
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Madrasah Qamarul Huda",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.normal
              )
            ),
            Text(
              "C-7886 Pantai Kundur, Batu 9,",
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.normal
              )
            ),
            Text(
              "Tanjung Keling, 76400, Melaka, Malaysia.",
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.normal
              )
            ),
            Text(
              "Nombor Perakuan Pendaftaran: JAIM/SAS(M)048",
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.normal,
                fontStyle: FontStyle.italic,
              )
            ),
            Text(
              "www.e-mqh.edu.my",
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold
              )
            ),
            Text(
              "Tel: +606-351 2966",
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.normal
              )
            ),
          ]
        )
      ]
    )
  );
}