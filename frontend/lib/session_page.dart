import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'home_page.dart';
import 'dart:convert';
import 'login_page.dart';

List<Map<dynamic, dynamic>> attended_students = [];
String apiUrl = '';

class MySessionPage extends StatefulWidget {
  final String? sid;
  MySessionPage({required this.sid, Key? key}) : super(key: key);
  @override
  SessionPage createState() => SessionPage();
}

class SessionPage extends State<MySessionPage> {
  @override
  void initState() {
    super.initState();
    send_session(widget.sid);
  }

  void send_session(String? sid) async {
    try {
      String encodedSearchString = Uri.encodeComponent(sid ?? 'null');
      print("encoded: $encodedSearchString");
      apiUrl = '$END_POINT/api/attended_students/?sid=$encodedSearchString';
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: myheaders,
      );

      if (response.statusCode == 200) {
        setState(() {
          attended_students =
              List<Map<dynamic, dynamic>>.from(json.decode(response.body));
        });
      } else {
        print("response code: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> _onWillPop() async {
    return true; // Return true to allow pop
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'SESSION DETAILS',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              attended_students.isEmpty
                  ? Center(
                      // Display this when attended_students is empty
                      child: Text(
                        'NO ATTENDEES YET',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: attended_students.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(attended_students[index]['name']),
                              subtitle:
                                  Text(attended_students[index]['roll_no']),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
