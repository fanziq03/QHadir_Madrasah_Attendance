import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:madrasah_attendance/clerk/class_details/assign_stud.dart';

class ClassStudents extends StatefulWidget {
  final String className;

  const ClassStudents({super.key, required this.className});

  @override
  State<ClassStudents> createState() => _ClassStudentsState();
}

class _ClassStudentsState extends State<ClassStudents> {
  final _isSelectedNotifier = ValueNotifier<List<bool>>([]);
  List<DocumentSnapshot>? _documents;

  void _removeSelectedStudents() {
    final selectedIndexes = _isSelectedNotifier.value.asMap().entries.where((entry) => entry.value).map((entry) => entry.key).toList();

    for (int index in selectedIndexes) {
      if (_documents != null && index < _documents!.length) {
        FirebaseFirestore.instance.collection('students').doc(_documents![index].id).update({
          'class': null,
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isSelectedNotifier.value = List<bool>.filled(_isSelectedNotifier.value.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('students').where("class", isEqualTo: widget.className).orderBy('name').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                    default:
                      if (snapshot.data == null) {
                        return Center(child: CircularProgressIndicator()); // Return a CircularProgressIndicator while data is loading
                      } else {
                        if (snapshot.data!.docs.isEmpty) {
                          // No students found, show a message
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
                                          "No student assigned for this class!",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          "\n\nStart assign a student to this\nclass by tapping the button below..",
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
                        } else {
                          if (_isSelectedNotifier.value.length!= snapshot.data!.docs.length) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _isSelectedNotifier.value = List<bool>.filled(snapshot.data!.docs.length, false);
                            });
                            _documents = snapshot.data!.docs;
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data?.docs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot document = snapshot.data!.docs[index];
                              return ValueListenableBuilder(
                                valueListenable: _isSelectedNotifier,
                                builder: (context, List<bool> isSelected, child) {
                                  if (index >= isSelected.length) return SizedBox.shrink();
                                  return Card(
                                    color: isSelected[index]? Colors.red : Colors.teal,
                                    child: ListTile(
                                      title: Text(
                                        document['name'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                      ),
                                      subtitle: Text(
                                        document['id'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                      ),
                                      onTap: () {
                                        _isSelectedNotifier.value = List<bool>.from(_isSelectedNotifier.value)
                                        ..[index] =!_isSelectedNotifier.value[index];
                                      },
                                      trailing: isSelected[index]
                                        ? Icon(Icons.check_box, color: Colors.white)
                                          : Icon(Icons.check_box_outline_blank, color: Colors.white),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }
                      }
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _isSelectedNotifier,
        builder: (context, List<bool> isSelected, child) {
          bool hasSelection = isSelected.any((element) => element);
          return FloatingActionButton(
            onPressed: hasSelection? _removeSelectedStudents : (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AssignStud(className: widget.className)),
              );
            },
            child: hasSelection? Icon(Icons.delete, color: Colors.white) : Icon(Icons.add, color: Colors.white),
            backgroundColor: hasSelection? Colors.red : const Color.fromARGB(255, 2, 88, 96),
          );
        },
      ),
    );
  }
}