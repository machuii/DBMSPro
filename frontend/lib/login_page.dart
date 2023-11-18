import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'home_page.dart';
import 'faculty_page.dart';
import 'student_page.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

var myheaders = {'Authorization': 'Token $login_key'};

String login_key = '';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String responseMessage = '';
  String errorMessage = '';
  String selectedButton = 'STUDENT';
  bool isLoading = false;

  Future<void> sendLoginData(String username, String password) async {
    var logger = Logger();

    final response = await http.post(
      Uri.parse('$END_POINT/api/dj-rest-auth/login/'),
      body: {
        'username': username,
        'password': password,
      },
    );

    try {
      if (response.statusCode == 200) {
        Map<String, dynamic> firstresponse = json.decode(response.body);
        setState(() {
          login_key = firstresponse['key'];
          myheaders = {'Authorization': 'Token $login_key'};
        });
        setState(() {
          responseMessage = login_key;
        });

        setState(() {
          response_msg = {};
        });
        var url = Uri.parse('$END_POINT/api/profile/');

        final profile_response = await http.get(url, headers: myheaders);

        try {
          if (profile_response.statusCode == 200) {
            setState(() {
              logger.i(profile_response.body);
              response_msg =
                  Map<String, dynamic>.from(json.decode(profile_response.body));
            });
            (response_msg != null && response_msg?['roll_no'] == null)
                ? Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyFacultyPage(),
                      settings:
                          RouteSettings(arguments: {'login_key': login_key}),
                    ),
                  )
                : Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyFacultyPage(),
                      settings:
                          RouteSettings(arguments: {'login_key': login_key}),
                    ),
                  );
          } else {
            logger.i('Error - Status Code: ${profile_response.statusCode}');
            logger.i('${login_key}');
          }
        } catch (e) {
          logger.i("error: $e");
        }
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => MyHomePage(),
        //     settings: RouteSettings(arguments: {'login_key': login_key}),
        //   ),
        // );
      } else if (response.statusCode == 400) {
        setState(() {
          responseMessage = 'Invalid username/password';
          errorMessage = responseMessage;
        });
      } else {
        logger.i('Failed to send data to the API');
        logger.i('Response status code: ${response.statusCode}');
        logger.i('Response body: ${response.body}');
      }
    } catch (e) {
      logger.i('Error: $e');
    }
  }

  Future<void> _login() async {
    String username = usernameController.text;
    String password = passwordController.text;

    sendLoginData(username, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF201A30),
      body: Padding(
        padding: EdgeInsets.all(35.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Login to InClass',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Please sign in to continue',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Color(0xFFBAAFD8),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                    height:
                        30), // Increased distance from the 'Login to InClass' text to the 'STUDENT' button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: 90,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedButton = 'STUDENT';
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 13.0),
                              child: Text(
                                'STUDENT',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: selectedButton == 'STUDENT'
                                      ? Color(0xFF201A30)
                                      : Color(0xFF9A8AC4),
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: selectedButton == 'STUDENT'
                                  ? Colors.white
                                  : Color(0xFF201A30),
                              onPrimary: Color(0xFF201A30),
                              side: BorderSide(
                                  color: Color(0xFF9A8AC4), width: 3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(13),
                                  bottomLeft: Radius.circular(13),
                                ),
                              ), // Adjust width and height as needed
                            ),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedButton = 'FACULTY';
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 13.0),
                              child: Text(
                                'FACULTY',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: selectedButton == 'FACULTY'
                                      ? Color(0xFF201A30)
                                      : Color(0xFF9A8AC4),
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: selectedButton == 'FACULTY'
                                  ? Colors.white
                                  : Color(0xFF201A30),
                              onPrimary: Color(0xFF201A30),
                              side: BorderSide(
                                  color: Color(0xFF9A8AC4), width: 3),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                topRight: Radius.circular(13),
                                bottomRight: Radius.circular(13),
                              )), // Adjust width and height as needed
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: usernameController,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.8,
                    ),
                    decoration: InputDecoration(
                      labelText: 'USERNAME',
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                      fillColor: Color(0xFF686666),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    height:
                        30), // Increased distance from the username input box to the password input box
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.8,
                    ),
                    decoration: InputDecoration(
                      labelText: 'PASSWORD',
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                      fillColor: Color(0xFF686666),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                SizedBox(
                  width: 100,
                  child: Container(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true; // Start loading
                        });
                        _login();
                        Future.delayed(Duration(seconds: 3), () {
                          setState(() {
                            isLoading =
                                false; // Stop loading after a delay (replace this with your logic)
                          });
                        });
                      },
                      child: isLoading
                          ? SpinKitThreeBounce(
                              // Replace with your desired Spinkit
                              color: Color(0xFF201A30),
                              size: 20.0,
                            )
                          : Container(
                              height: 50,
                              child: Center(
                                child: Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF201A30),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF0DF5E3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  errorMessage,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Color(0xffff0000),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
