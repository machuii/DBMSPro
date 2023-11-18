import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'dart:async';

String displayText = 'Mark Attendance';

class MyStudentPage extends StatefulWidget {
  const MyStudentPage({super.key});

  @override
  State<MyStudentPage> createState() => StudentPage();
}

class StudentPage extends State<MyStudentPage> {

  late Timer _timer;
  Map<String,String> curr_session={};
  int status_code=0,att_status=1;
  int att_marked=0;
  List<Map<String,dynamic>> course_att=[];

  @override
  void initState() {
    super.initState();
    check_sessions();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async{
    await check_sessions();
  }

  Future<void> check_sessions() async{
    try {
      final response = await http.get(
          Uri.parse('$END_POINT/api/fetch_sessions/'),
          headers: myheaders);
      if (response.statusCode == 200) {
        setState(() {
          curr_session=Map<String,String>.from(jsonDecode(response.body));
          status_code=1;
        });
      } else if(response.statusCode==404){
        setState(() {
          curr_session={};
          status_code=0;
        });
      } else {
        print("fetch_sessions status code: ${response.statusCode}");
      }
    } catch (error) {
      print('Error: $error');
    }

    try{
      final response = await http.get(
          Uri.parse('$END_POINT/api/course_attendance/'),
          headers: myheaders);
          if(response.statusCode==200){
            setState(() {
              course_att=List<Map<String,dynamic>>.from(jsonDecode(response.body));
            });
          }
          else{
            print('course_attendance status code: ${response.statusCode}');
          }
    }catch(e){
      print('error: $e');
    }
  }


  Future<void> mark_attendance() async{
    try {
      final response = await http.post(
          Uri.parse('$END_POINT/api/mark_attendance/'),
          body: {'sid': curr_session['sid']},
          headers: myheaders);
      if (response.statusCode == 200) {
        print('Attendance marked');
        setState(() {
          att_status=1;
          att_marked=1;
        });
      } else if(response.statusCode==403){
        setState(() {
          att_status=0;
          att_marked=0;
        });
      } else {
        print("mark_attendance status code: ${response.statusCode}");
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void view_history(String course_id){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyHistoryPage(course_id: course_id),
        settings: RouteSettings(arguments: {'login_key': login_key}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (status_code == 1)
              Text(
                curr_session["course"]??'', // Replace with your actual text
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            if (status_code == 1)
              Text(
                curr_session["faculty"]??'', // Replace with your actual text
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (status_code == 1)
              Text(
                curr_session["end_time"]??'', // Replace with your actual text
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 16), // Adjust the spacing as needed
            status_code == 1
                ? att_marked==1
                    ? Text('Attendance Marked', style: TextStyle(fontSize: 18))
                    : ElevatedButton(
                        onPressed: () {
                          mark_attendance();
                        },
                        child: Text('Mark Attendance'),
                      )
                : att_marked==1
                ?Text('Attendance Marked')
                :Text('No Active Sessions'),
            SizedBox(height: 16), // Adjust the spacing as needed
            ListView.builder(
              shrinkWrap: true,
              itemCount: course_att.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    view_history(course_att[index]['course_id']);
                  },
                  child: ListTile(
                    title: Text('${course_att[index]['course_id']}  ${course_att[index]['course_name']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Classes Attended: ${course_att[index]['attended']}'),
                        Text('Total Classes: ${course_att[index]['total classes']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    // Cancel the timer when the page is disposed to avoid memory leaks
    _timer.cancel();
    super.dispose();
  }

}
