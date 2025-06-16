import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AssignStud extends StatefulWidget {
  final String className;

  const AssignStud({super.key, required this.className});

  @override
  State<AssignStud> createState() => _AssignStudState();
}

class _AssignStudState extends State<AssignStud> {
  final _isSelectedNotifier = ValueNotifier<List<bool>>([]);
  List<DocumentSnapshot>? _documents;

  @override
  void initState() {
    super.initState();
    _isSelectedNotifier.value = [];
  }

  void _assignSelectedStudents() {
    final selectedIndexes = _isSelectedNotifier.value.asMap().entries.where((entry) => entry.value).map((entry) => entry.key).toList();

    for (int index in selectedIndexes) {
      if (_documents!= null && index < _documents!.length) {
        FirebaseFirestore.instance.collection('students').doc(_documents![index].id).update({
          'class': widget.className,
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
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 2, 88, 96),
        title: Text(
          "Assign Student",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),

      //Body
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('students').where("class", isNull: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                    default:
                      if (snapshot.data!.docs.isEmpty) {
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
                                        "No students to be assign!",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        "\n\nSeems like every student already\nhave a class..",
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
                                  color: isSelected[index]? Colors.green : Colors.teal,
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
          return Visibility(
            visible: hasSelection,
            child: FloatingActionButton(
              onPressed: hasSelection? _assignSelectedStudents : null,
              child: hasSelection? Icon(Icons.check, color: Colors.white) : null,
              backgroundColor: hasSelection? Colors.green : null,
            ),
          );
        },
      ),
    );
  }
}