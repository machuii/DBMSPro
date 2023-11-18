import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';
import 'home_page.dart';
import 'dart:async';


List<List<dynamic>> batch_students = [];
String att_url = '';

class MyAttendancePage extends StatefulWidget {

  final String? batch;
  int attn = 0;
  MyAttendancePage({required this.batch, required this.attn, Key? key})
      : super(key: key);

  @override
  AttendancePageState createState() => AttendancePageState();
}

class AttendancePageState extends State<MyAttendancePage> {

  late Timer _timer;
  @override
  void initState() {
    super.initState();
    send_attendance(widget.batch);
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async{
    await send_attendance(widget.batch);
  }

  Future<void> send_attendance(String? batch) async {
    try {
      String encodedSearchString = Uri.encodeComponent(batch ?? 'elective');
      att_url = '$END_POINT/api/batch_attendance/?batch=$encodedSearchString';
      var response = await http.get(
        Uri.parse(att_url),
        headers: myheaders,
      );

      if (response.statusCode == 200) {
        setState(() {
          batch_students = List<List<dynamic>>.from(json.decode(response.body));
        });
      } else {
        print("response code: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(
              top: 50.0, bottom: 30.0, left: 20.0, right: 20.0),
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
                    'Batch Details - ${widget.batch}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
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
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  'NUMBER OF SESSIONS TAKEN: ${widget.attn}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                  ),
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
                          if (index < batch_students.length) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF686666),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: ListTile(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${batch_students[index][1]}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'Montserrat',
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                '${batch_students[index][0]}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontFamily: 'Montserrat',
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                'Classes Attended: ${batch_students[index][2]}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontFamily: 'Montserrat',
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${(batch_students[index][2] / widget.attn * 100).toStringAsFixed(1)}%',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Montserrat',
                                                  color: (batch_students[index]
                                                                  [2] /
                                                              widget.attn *
                                                              100) <
                                                          80
                                                      ? Colors.red
                                                      : Colors.green,
                                                  fontSize: 25,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
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
