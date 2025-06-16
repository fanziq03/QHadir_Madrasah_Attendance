import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 2, 88, 96),
        title: Text(
          "About QHadir",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          )
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration( 
            color: const Color.fromARGB(255, 2, 88, 96),
            borderRadius: BorderRadius.circular(20), 
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 150,
                    child: Image.asset(
                      "assets/images/logoMadrasah.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Text(
                    "QHadir is a cutting-edge attendance management application designed specifically for Madrasah Qamarul Huda. This innovative app aims to transform the traditional paper-based attendance system into a modern, efficient, and user-friendly digital platform. QHadir caters to the unique needs of teachers, clerks, and the principal, providing each with tailored functionalities to streamline their tasks and enhance overall productivity.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 20,),
                  Text(
                    "Key Features:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Text(
                    "• Secure Attendance Recording: QHadir ensures the security and integrity of attendance data through advanced encryption and secure authentication processes, protecting student information from unauthorized access.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  Text(
                    "• Automated Reporting: The app automatically generates detailed attendance reports, minimizing human error and reducing the time clerks spend on administrative tasks. This allows for quicker and more accurate reporting.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  Text(
                    "• Convenient for Teachers: Teachers can easily mark student attendance directly from their mobile devices using a color-coded system. This feature eliminates the need for physical attendance sheets, saving time and effort.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  Text(
                    "• Centralized Management: The principal can efficiently manage staff, teachers, classes, and students through a centralized interface. This capability ensures that the system remains up-to-date and accurate.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  Text(
                    "• Environmental Sustainability: By reducing the dependency on paper, QHadir contributes to environmental conservation efforts, helping to reduce waste and the institution's carbon footprint.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 20,),
                  Text(
                    "Purpose and Benefits:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Text(
                    "QHadir is designed to enhance the accuracy, efficiency, and security of the attendance process at Madrasah Qamarul Huda. By providing a digital solution, the app not only simplifies the tasks of recording and managing attendance but also contributes to a more sustainable and eco-friendly approach. QHadir’s user-friendly interface and robust feature set empower teachers, clerks, and the principal to perform their duties more effectively, ultimately fostering a more organized and efficient educational environment.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}