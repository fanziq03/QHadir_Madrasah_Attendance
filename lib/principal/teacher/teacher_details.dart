import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:madrasah_attendance/Widget/input_field.dart';

class TeacherDetails extends StatefulWidget {
  final String id;

  const TeacherDetails({super.key, required this.id});

  @override
  State<TeacherDetails> createState() => _StaffDetailsState();
}

class _StaffDetailsState extends State<TeacherDetails> {
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
          "Teacher Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').where("id", isEqualTo: widget.id).snapshots(),
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
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(document['image']),
                        ),
                        const SizedBox(height: 16,),
                        InputField(
                          title: 'Name',
                          hint: '',
                          readOnly: true,
                          controller: TextEditingController(text: document['name']),
                        ),
                        const SizedBox(height: 16,),
                        InputField(
                          title: 'ID Number',
                          hint: '',
                          readOnly: true,
                          controller: TextEditingController(text: document['id']),
                        ),
                        const SizedBox(height: 16,),
                        InputField(
                          title: 'Password',
                          hint: '',
                          readOnly: true,
                          controller: TextEditingController(text: document['password']),
                        ),
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
            QuerySnapshot document = await _firestore.collection('users').where("id", isEqualTo: widget.id).limit(1).get();
            if (document.docs.isNotEmpty) {
              await document.docs.first.reference.delete();
              _showSnackBar('Teacher deleted successfully');
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