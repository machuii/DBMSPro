import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyStudentPage extends StatefulWidget {
  const MyStudentPage({super.key});

  @override
  State<MyStudentPage> createState() => StudentPage();
}

class StudentPage extends State<MyStudentPage> {
  late Timer _timer;
  Map<String, String> curr_session = {};
  int status_code = 0, att_status = 1;
  int att_marked = 0;
  List<Map<String, dynamic>> course_att = [];
  bool isLoading = false;
  bool isLoadingInitial = true;

  @override
  void initState() {
    super.initState();
    check_sessions();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoadingInitial = false;
      });
    });
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    await check_sessions();
  }

  Future<void> check_sessions() async {
    try {
      final response = await http
          .get(Uri.parse('$END_POINT/api/fetch_sessions/'), headers: myheaders);
      if (response.statusCode == 200) {
        setState(() {
          curr_session = Map<String, String>.from(jsonDecode(response.body));
          status_code = 1;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          curr_session = {};
          status_code = 0;
        });
      } else {
        print("fetch_sessions status code: ${response.statusCode}");
      }
    } catch (error) {
      print('Error: $error');
    }

    try {
      final response = await http.get(
          Uri.parse('$END_POINT/api/course_attendance/'),
          headers: myheaders);
      if (response.statusCode == 200) {
        setState(() {
          course_att =
              List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      } else {
        print('course_attendance status code: ${response.statusCode}');
      }
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> mark_attendance() async {
    try {
      final response = await http.post(
          Uri.parse('$END_POINT/api/mark_attendance/'),
          body: {'sid': curr_session['sid']},
          headers: myheaders);
      if (response.statusCode == 200) {
        print('Attendance marked');
        setState(() {
          att_status = 1;
          att_marked = 1;
        });
      } else if (response.statusCode == 403) {
        setState(() {
          att_status = 0;
          att_marked = 0;
        });
      } else {
        print("mark_attendance status code: ${response.statusCode}");
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void view_history(String course_id) {
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
      backgroundColor: Color(0xFF201A30),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: ListView(children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 30.0, bottom: 30.0, left: 20.0, right: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      'Student Dashboard',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'ACTIVE SESSIONS',
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
                  height: 18,
                ),
                isLoadingInitial
                    ? SpinKitDoubleBounce(
                        // Replace with your desired Spinkit
                        color: Color(0xFF0DF5E3),
                        size: 20.0,
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          status_code == 1
                              ? Expanded(
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFF686666),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, bottom: 8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (status_code == 1)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0,
                                                    left: 5.0,
                                                    right: 5.0,
                                                    bottom: 5.0),
                                                child: Text(
                                                  curr_session["course"] ?? '',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Montserrat',
                                                      color: Colors.white),
                                                ),
                                              ),
                                            if (status_code == 1)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Text(
                                                  curr_session["faculty"] ??
                                                      '', // Replace with your actual text
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w200,
                                                      fontFamily: 'Montserrat',
                                                      color: Colors.white),
                                                ),
                                              ),
                                            if (status_code == 1)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Text(
                                                  curr_session["end_time"] ??
                                                      '', // Replace with your actual text
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w200,
                                                      fontFamily: 'Montserrat',
                                                      color: Colors.white),
                                                ),
                                              ),
                                            att_marked == 1
                                                ? // Adjust the spacing as needed
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            14.0),
                                                    child: Text(
                                                        'ATTENDANCE RECORDED',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontFamily:
                                                              'Montserrat',
                                                          color:
                                                              Color(0xFF0DF5E3),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        )),
                                                  )
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 15.0,
                                                            top: 15.0),
                                                    child: Container(
                                                      height: 40,
                                                      width: 100,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                backgroundColor:
                                                                    Color(
                                                                        0xFF0DF5E3),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                )),
                                                        onPressed: () async {
                                                          setState(() {
                                                            isLoading = true;
                                                          });
                                                          await mark_attendance();
                                                          setState(() {
                                                            isLoading = false;
                                                          });
                                                        },
                                                        child: isLoading
                                                            ? SpinKitThreeBounce(
                                                                // Replace with your desired Spinkit
                                                                color: Color(
                                                                    0xFF201A30),
                                                                size: 20.0,
                                                              )
                                                            : Text(
                                                                'ATTEND',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    color: Color(
                                                                        0xFF201A30)),
                                                              ),
                                                      ),
                                                    ),
                                                  )
                                          ],
                                        ),
                                      )),
                                )
                              : Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      'NO ACTIVE SESSIONS',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                SizedBox(height: 25), // Adjust the spacing as needed
                Row(
                  children: [
                    Text(
                      'MY COURSES',
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
                  height: 18,
                ),
                isLoadingInitial
                    ? SpinKitDoubleBounce(
                        // Replace with your desired Spinkit
                        color: Color(0xFF0DF5E3),
                        size: 20.0,
                      )
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: course_att.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              view_history(course_att[index]['course_id']);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Color(0xFF686666),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        '${course_att[index]['course_id']}  ${course_att[index]['course_name']}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                            'Classes Attended: ${course_att[index]['attended']}',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w200,
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                            'Total Classes: ${course_att[index]['total classes']}',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w200,
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ]),
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
