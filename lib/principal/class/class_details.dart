import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:madrasah_attendance/Widget/input_field.dart';

class ClassDetails extends StatefulWidget {
  final String className;

  const ClassDetails({super.key, required this.className});

  @override
  State<ClassDetails> createState() => _StaffDetailsState();
}

class _StaffDetailsState extends State<ClassDetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 2, 88, 96),
        title: Text(
          "Class Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('classes').where("className", isEqualTo: widget.className).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text('Loading....');
            default:
              QuerySnapshot querySnapshot = snapshot.data!;
              if (querySnapshot.docs.isEmpty) {
                return Text('No data found');
              } else {
                DocumentSnapshot document = querySnapshot.docs[0];
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16,),
                        InputField(
                          title: 'Class Name',
                          hint: '',
                          readOnly: true,
                          controller: TextEditingController(text: document['className']),
                        ),
                        const SizedBox(height: 16,),
                        // Class teacher
                      ],
                    ),
                  ),
                );
              }
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            QuerySnapshot document = await _firestore.collection('classes').where("className", isEqualTo: widget.className).limit(1).get();
            if (document.docs.isNotEmpty) {
              await document.docs.first.reference.delete();
              _showSnackBar('Class deleted successfully');
              Navigator.pop(context);
            }
          } catch (e) {
            print('Error deleting document: $e');
          }
        },
        backgroundColor: Colors.red,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}