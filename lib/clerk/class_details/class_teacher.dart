import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:madrasah_attendance/Widget/input_field.dart';

class ClassTeacher extends StatefulWidget {
  final String className;

  const ClassTeacher({super.key, required this.className});

  @override
  State<ClassTeacher> createState() => _ClassTeacherState();
}

class _ClassTeacherState extends State<ClassTeacher> {
  String? _teacherId;
  String? _teacherName;
  String? _teacherImage;

  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  Future<void> _fetchTeacherDetails() async {

    await FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: "teacher")
      .where('assignedClass', isEqualTo: widget.className)
      .get()
      .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _teacherName = data.containsKey('name')? data['name'] : null;
          _teacherId = data.containsKey('id')? data['id'] : null;
          _teacherImage = data.containsKey('image')? data['image'] : null;
          _nameController.text = _teacherName?? '';
          _idController.text = _teacherId?? '';
        });
      }
    });
  }

  Future<void> _selectTeacher(BuildContext context) async {
    String? selectedTeacherId = 'no_teacher'; // Initialize with 'no_teacher'

    await showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: "teacher")
            .where('assignedClass', isNull: true)
            .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              QuerySnapshot<Map<String, dynamic>> teachersSnapshot = snapshot.data!;
              List<DropdownMenuItem<String>> items = [
                DropdownMenuItem<String>(
                  value: 'no_teacher', // Add a default value
                  child: Text('No teacher selected'),
                ),
              ];
              for (int i = 0; i < teachersSnapshot.docs.length; i++) {
                DocumentSnapshot documentSnapshot = teachersSnapshot.docs[i];
                items.add(DropdownMenuItem<String>(
                  value: documentSnapshot.id, // Use the teacher's ID as the value
                  child: SizedBox(
                    width: 210,
                    child: Text(
                      documentSnapshot['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ));
              }

              // Add the selected teacher ID to the list of items
              if (_teacherId != null) {
                items.add(DropdownMenuItem<String>(
                  value: _teacherId, // Add the selected teacher ID
                  child: Text(_teacherId!),
                ));
              }

              return AlertDialog(
                title: Text("Select a teacher"),
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: DropdownButtonFormField<String>(
                                value: selectedTeacherId, 
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedTeacherId = value;
                                      if (value != 'no_teacher') {
                                        _teacherId = value; // Set _teacherId to the selected teacher's ID
                                      } else {
                                        _teacherId = null;
                                      }
                                    });
                                  }
                                },
                                items: items,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: selectedTeacherId != 'no_teacher' 
                              ? () {
                                  _assignTeacher();
                                  Navigator.pop(context);
                                }
                              : null,
                              child: Text('Confirm'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }

  Future<void> _assignTeacher() async {
    await FirebaseFirestore.instance.collection('users').doc(_teacherId).update({'assignedClass': widget.className});
    _fetchTeacherDetails();
  }

  @override
  void initState() {
    super.initState();
    _fetchTeacherDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 3, 62, 66),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 50,
                   backgroundImage: _teacherImage!= null
                       ? NetworkImage(_teacherImage!)
                        : NetworkImage("https://cdn-icons-png.flaticon.com/512/149/149071.png",),
                  ),
                ),
                SizedBox(height: 20),
            
                InputField(
                  title: 'Name',
                  titleColor: Colors.white,
                  hint: _teacherName!= null? '' : 'No teacher assigned yet',
                  controller: _nameController,
                  readOnly: true,
                ),

                SizedBox(height: 16),

                InputField(
                  title: 'ID Number',
                  titleColor: Colors.white,
                  hint: _teacherId!= null? '' : 'No teacher assigned yet',
                  controller: _idController,
                  readOnly: true,
                ),
            
                Spacer(),
            
                _teacherId!= null
                   ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                           .collection('users')
                           .where('role', isEqualTo: "teacher")
                           .where('assignedClass', isEqualTo: widget.className)
                           .get()
                           .then((QuerySnapshot querySnapshot) {
                              if (querySnapshot.docs.isNotEmpty) {
                                DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
                                documentSnapshot.reference.update({'assignedClass': null});
                                setState(() {
                                  _teacherId = null;
                                  _teacherName = null;
                                  _teacherImage = null;
                                  _nameController.text = '';
                                  _idController.text = '';
                                });
                              }
                            });
                          _fetchTeacherDetails();
                        },
                        child: Text(
                          'Remove Teacher',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        onPressed: () {
                          _selectTeacher(context);
                        },
                        child: Text(
                          'Assign Teacher',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}