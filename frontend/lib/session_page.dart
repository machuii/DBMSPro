import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'home_page.dart';
import 'dart:convert';
import 'login_page.dart';
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';

List<Map<dynamic, dynamic>> attended_students = [];
String apiUrl = '';

class MySessionPage extends StatefulWidget {
  final String? sid;
  MySessionPage({required this.sid, Key? key}) : super(key: key);
  @override
  SessionPage createState() => SessionPage();
}

class SessionPage extends State<MySessionPage> {
  late Timer _timer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    send_session(widget.sid);
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    await send_session(widget.sid);
  }

  Future<void> send_session(String? sid) async {
    try {
      String encodedSearchString = Uri.encodeComponent(sid ?? 'null');
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
                    'Session Details',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
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
              isLoading ?
              SpinKitThreeBounce(
                // Replace with your desired Spinkit
                color: Color(0xFF0DF5E3),
                size: 20.0,
              ) :
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
                          return Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF686666),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        attended_students[index]['name']
                                            .toUpperCase(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Montserrat',
                                            color: Colors.white,
                                            fontSize: 16),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        attended_students[index]['roll_no'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Montserrat',
                                            color: Colors.white,
                                            fontSize: 16),
                                      ),
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
