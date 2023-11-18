import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';
import 'home_page.dart';
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyHistoryPage extends StatefulWidget {
  final String? course_id;
  MyHistoryPage({required this.course_id, Key? key}) : super(key: key);
  @override
  HistoryPage createState() => HistoryPage();
}

class HistoryPage extends State<MyHistoryPage> {
  String apiUrl = '';
  List<Map<dynamic, dynamic>> att_history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    view_attendance_details(widget.course_id);
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> view_attendance_details(String? course_id) async {
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
        backgroundColor: Color(0xFF201A30),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Color(0xFF0DF5E3),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // Navigate back to the previous screen
                    },
                  ),
                  Text(
                    'Course History',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    'PAST SESSIONS',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w300,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                height: 2.5,
                color: Color(0xFF0DF5E3),
              ),
              SizedBox(
                height: 10,
              ),
              isLoading ?
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: SpinKitThreeBounce(
                  // Replace with your desired Spinkit
                  color: Color(0xFF0DF5E3),
                  size: 20.0,
                ),
              ) :
              att_history.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Text(
                          'NO ATTENDANCE HISTORY AVAILABLE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: att_history.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Color(0xFF686666),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0, right: 6.0,),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 1.5, bottom: 1.5),
                                              child: Text(
                                                'Date: ${att_history[index]['time']}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'Montserrat',
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Text(
                                                'Faculty: ${att_history[index]['faculty']}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w200,
                                                    fontFamily: 'Montserrat',
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            att_history[index]['attended'] ==
                                                    'False'
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(5.0),
                                                    child: Text(
                                                      'ABSENT',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontFamily: 'Montserrat',
                                                          color: Colors.red,
                                                          fontSize: 16),
                                                    ),
                                                  )
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.all(5.0),
                                                    child: Text(
                                                      'PRESENT',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontFamily: 'Montserrat',
                                                          color: Color(0xFF0DF5E3),
                                                          fontSize: 16),
                                                    ),
                                                  )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ));
  }
}
