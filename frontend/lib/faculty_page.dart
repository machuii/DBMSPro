import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';
import 'dart:convert';
import 'login_page.dart';
import 'session_page.dart';
import 'attendance_page.dart';

class MyFacultyPage extends StatefulWidget {
  @override
  FacultyPage createState() => FacultyPage();
}

class FacultyPage extends State<MyFacultyPage> {
  List<Map<String, dynamic>> recent_sessions = [];
  String batch_selected = 'elec';
  String active_time = '';
  List<String> dropdownOptions = ['CS01', 'CS02', 'CS03', 'CS04'];
  String fac_name = '';
  List<List<dynamic>> course_sessions = [];
  Map<String, String> sid_list = {};
  String session_err_message = '';
  @override
  void initState() {
    super.initState();
    if (response_msg?['is_elective'] == false) {
      batch_selected = 'CS01';
    }
    loadData();
  }

  Future<void> loadData() async {
    try {
      await fetchData();
      await fetchcourse();
      setState(() {});
    } catch (e) {
      print("Error loading data: $e");
      // Handle the error as needed
    }
  }

  Future<void> fetchcourse() async {
    try {
      var new_response = await http.get(
          Uri.parse('$END_POINT/api/course_sessions/'),
          headers: myheaders);
      if (new_response.statusCode == 200) {
        setState(() {
          course_sessions =
              List<List<dynamic>>.from(jsonDecode(new_response.body));
        });
      } else {
        throw Exception(
            "recent_session status code: ${new_response.statusCode}");
      }
    } catch (e) {
      print("error: $e");
    }
  }

  Future<void> fetchData() async {
    try {
      var response = await http.get(
        Uri.parse('$END_POINT/api/recent_sessions/'),
        headers: myheaders,
      );
      if (response.statusCode == 200) {
        setState(() {
          recent_sessions =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
        print(myheaders);
      } else {
        throw Exception("recent_session status code: ${response.statusCode}");
      }
    } catch (e) {
      print("error: $e");
    }
  }

  void view_faculty_page() {
    setState(() {
      fac_name = response_msg?['name'] ?? 'null';
    });
  }

  void session_details(String? sid_) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => MyFacultyPage()),
    );
    print('sid: $sid_');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MySessionPage(sid: sid_),
        settings: RouteSettings(arguments: {'login_key': login_key}),
      ),
    );
  }

  void batch_attended(String batch, int attn) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyAttendancePage(batch: batch, attn: attn),
        settings: RouteSettings(arguments: {'login_key': login_key}),
      ),
    );
  }

  Future<void> make_session(String batch, String duration) async {
    final response = await http.post(
      Uri.parse('$END_POINT/api/create_session/'),
      body: {
        'batch': batch,
        'duration': duration,
      },
      headers: myheaders,
    );
    setState(() {
      sid_list = Map<String, String>.from(json.decode(response.body));
    });
    try {
      if (response.statusCode == 200) {
        print(response);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => MyFacultyPage()),
        );
      } else {
        print("make_session response: ${response.statusCode}");
      }
    } catch (e) {
      print('Error make_session: $e');
    }
  }

  Future<void> create_session(String batch_selected, String active_time) async {
    if (batch_selected.isEmpty || active_time.isEmpty) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Please specify the batch and duration.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  } else {
      await make_session(batch_selected, active_time);
    }
  }

  @override
  Widget build(BuildContext context) {
    view_faculty_page();
    return Scaffold(
      backgroundColor: Color(0xFF201A30),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.only(
              top: 30.0, bottom: 50.0, left: 20.0, right: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    'Faculty Dashboard',
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
              Row(
                children: [
                  Text(
                    'CREATE A NEW SESSION',
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
                height: 25,
              ),
              //container for create session card
              Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF686666),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        (!(response_msg?['is_elective'] ?? false))
                            ?
                            //container for dropdown
                            Container(
                                width: 80,
                                child: DropdownButton<String>(
                                  dropdownColor: Color(0xFF201A30),
                                  value: batch_selected,
                                  items: dropdownOptions.map((String option) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Center(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            color: Colors.white,
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      batch_selected = newValue!;
                                    });
                                  },
                                ),
                              )
                            : Container(
                                height: 10,
                              ),
                        //container for duration
                        Container(
                          width: 80,
                          child: TextField(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                            ),
                            onChanged: (text) {
                              setState(() {
                                active_time = text;
                              });
                            },
                            decoration: InputDecoration(
                                labelText: 'DURATION',
                                labelStyle: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        //row for create session button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 150,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF0DF5E3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    )),
                                onPressed: () async {
                                  await create_session(
                                      batch_selected, active_time);
                                },
                                child: Text(
                                  'CREATE SESSION',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF201A30),
                                    fontSize: 12,
                                    letterSpacing: 0.7,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ])),
              SizedBox(
                height: 10,
              ),
              Text(
                session_err_message,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              //row for recent sessions
              Row(
                children: [
                  Text(
                    'RECENT SESSIONS',
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
                height: 25,
              ),
              Container(
                child: recent_sessions.isEmpty
                    ? Center(
                        child: Text(
                          'NO RECENT SESSIONS',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: recent_sessions.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  session_details(
                                      recent_sessions[index]['sid']);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF686666),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5.0,
                                        left: 1.0,
                                        right: 5.0,
                                        bottom: 5.0),
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'STRENGTH',
                                                style: TextStyle(
                                                  fontSize: 6,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Montserrat',
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                (recent_sessions[index]
                                                        ['attendance'])
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Montserrat',
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10.0,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Container(
                                                    width: 210,
                                                    child: Text(
                                                      recent_sessions[index]
                                                              ['course'] ??
                                                          '',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                (!(response_msg?[
                                                            'is_elective'] ??
                                                        false))
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5.0),
                                                        child: Text(
                                                          recent_sessions[index]
                                                                  ['batch'] ??
                                                              '',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            color: Colors.white,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Text(
                                                    recent_sessions[index]
                                                            ['datetime'] ??
                                                        '',
                                                    style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          );
                        },
                      ),
              ),
              SizedBox(
                height: 35,
              ),
              //row for batches
              Row(
                children: [
                  Text(
                    'BATCHES',
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
                height: 25,
              ),
              Container(
                child: course_sessions.isEmpty
                    ? Center(
                        child: Text(
                          '',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: course_sessions.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  batch_attended(course_sessions[index][0],
                                      course_sessions[index][1]);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF686666),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: ListTile(
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 5),
                                    title: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 3.0, bottom: 3.0),
                                      child: Container(
                                        child: ((response_msg?['is_elective'] ??
                                                false))
                                            ? Text(
                                                recent_sessions[index]
                                                        ['course'] ??
                                                    '',
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              )
                                            : Text(
                                                '${course_sessions[index][0]}',
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 3.0, bottom: 3.0),
                                      child: Container(
                                        child: Text(
                                          'NUMBER OF SESSIONS TAKEN: ${course_sessions[index][1]}',
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
