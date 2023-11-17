import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'login_page.dart';

String displayText = 'Mark Attendance';

class AttendanceWidget extends StatefulWidget {
  const AttendanceWidget({super.key});

  @override
  State<AttendanceWidget> createState() => _AttendanceWidgetState();
}

class _AttendanceWidgetState extends State<AttendanceWidget> {
  //when pressed send a get request to backend and change text based on response

  void updateTextsuccess() {
    setState(() {
      displayText = "Attendance Marked";
    });
  }

  void updateTextfailure() {
    setState(() {
      displayText = "Timed out";
    });
  }

  Future<void> checkAttendance() async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:8000/api/mark_attendance/'),
          headers: myheaders);
      Logger().i("Status Code : ${response.statusCode}");
      if (response.statusCode == 200) {
        //change text
        print('Attendance marked');
        updateTextsuccess();
      } else {
        //change text
        updateTextfailure();
        //log the status code
        Logger().i("Status Code : ${response.statusCode}");
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        onPressed: checkAttendance,
        child: Container(
            width: 100,
            height: 100,
            child: Text(displayText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.green, spreadRadius: 3),
              ],
            )),
      ),
    );
  }
}
