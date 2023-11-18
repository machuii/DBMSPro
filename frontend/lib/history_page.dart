import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';
import 'home_page.dart';
import 'dart:async';


class MyHistoryPage extends StatefulWidget {
  final String? course_id;
  MyHistoryPage({required this.course_id, Key? key}) : super(key: key);
  @override
  HistoryPage createState() => HistoryPage();
}


class HistoryPage extends State<MyHistoryPage> {

  String apiUrl='';
  List<Map<dynamic,dynamic>> att_history=[];

  @override
  void initState() {
    super.initState();
    view_attendance_details(widget.course_id);

  }


  Future<void> view_attendance_details(String? course_id) async{
    try {
      String encodedSearchString = Uri.encodeComponent(course_id ?? 'null');
      print(course_id);
      apiUrl = '$END_POINT/api/course_history/?course_id=$encodedSearchString';
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: myheaders,
      );

      if (response.statusCode == 200) {
        setState(() {
          att_history =
              List<Map<dynamic, dynamic>>.from(json.decode(response.body));
        });
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
        title: Text('Attendance History'),
      ),
      body: att_history.isEmpty
          ? Center(
              child: Text('No attendance history available'),
            )
          : ListView.builder(
              itemCount: att_history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Date: ${att_history[index]['time']}'),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Faculty: ${att_history[index]['faculty']}'),
                        Text('Attended: ${att_history[index]['attended']}'),
                      ],
                    ),
                );
              },
            ),
    );
  }

}