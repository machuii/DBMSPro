import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';

List<List<dynamic>> batch_students = [];
String att_url = '';

class MyAttendancePage extends StatefulWidget {
  final String? batch;
  int attn = 0;
  MyAttendancePage({required this.batch, required this.attn, Key? key}) : super(key: key);

  @override
  AttendancePageState createState() => AttendancePageState();
}

class AttendancePageState extends State<MyAttendancePage> {
  @override
  void initState() {
    super.initState();
    send_attendance(widget.batch);
  }

  void send_attendance(String? batch) async {
    try {
      String encodedSearchString = Uri.encodeComponent(batch ?? 'elective');
      att_url = 'http://localhost:8000/api/batch_attendance/?batch=$encodedSearchString';
      var response = await http.get(
        Uri.parse(att_url),
        headers: myheaders,
      );

      if (response.statusCode == 200) {
        batch_students = List<List<dynamic>>.from(json.decode(response.body));
      } else {
        print("response code: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Page'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Classes: ${widget.attn}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: batch_students.isEmpty
                ? Center(
                    // Display this when attended_students is empty
                    child: Text(
                      'No students',
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                : ListView.builder(
                    itemCount: batch_students.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text('Name: ${batch_students[index][1]}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Roll No: ${batch_students[index][0]}'),
                              Text('Classes Attended: ${batch_students[index][2]}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
