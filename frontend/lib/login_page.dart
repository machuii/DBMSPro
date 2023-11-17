import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';
import 'dart:convert';

var myheaders = {
  'Authorization': 'Token $login_key'
};

String login_key='';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String responseMessage = '';
  String selectedButton = '';

  Future<void> sendLoginData(String username, String password) async {
    var logger = Logger();

    final response = await http.post(
      Uri.parse('http://localhost:8000/api/dj-rest-auth/login/'),
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
          myheaders = {
            'Authorization': 'Token $login_key'
          };
        });
        setState(() {
          responseMessage = login_key;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(),
            settings: RouteSettings(arguments: {'login_key': login_key}),
          ),
        );
      } else if (response.statusCode == 400) {
        setState(() {
          responseMessage = 'Invalid username/password';
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

  void _login() {
    String username = usernameController.text;
    String password = passwordController.text;

    sendLoginData(username, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF201A30),
      body: Padding(
        padding: EdgeInsets.all(64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login to InClass',
              style: GoogleFonts.righteous(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 30),  // Increased distance from the 'Login to InClass' text to the 'STUDENT' button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedButton = 'STUDENT';
                    });
                  },
                  child: Text(
                    'STUDENT',
                    style: TextStyle(
                      color: selectedButton == 'STUDENT'
                          ? Color(0xFF201A30)
                          : Color(0xFF9A8AC4),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: selectedButton == 'STUDENT'
                        ? Colors.white
                        : Color(0xFF201A30),
                    onPrimary: Color(0xFF201A30),
                    side: BorderSide(color: Color(0xFF9A8AC4), width: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: Size(215, 50), // Adjust width and height as needed
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedButton = 'FACULTY';
                    });
                  },
                  child: Text(
                    'FACULTY',
                    style: TextStyle(
                      color: selectedButton == 'FACULTY'
                          ? Color(0xFF201A30)
                          : Color(0xFF9A8AC4),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: selectedButton == 'FACULTY'
                        ? Colors.white
                        : Color(0xFF201A30),
                    onPrimary: Color(0xFF201A30),
                    side: BorderSide(color: Color(0xFF9A8AC4), width: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: Size(215, 50), // Adjust width and height as needed
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: usernameController,
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
            SizedBox(height: 30),  // Increased distance from the username input box to the password input box
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                obscureText: true,
                controller: passwordController,
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
            SizedBox(height: 50),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () {
                  _login();
                },
                child: Container(
                  height: 50,
                  child: Center(
                    child: Text(
                      'LOGIN',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        color: Color(0xFF201A30),
                        fontWeight: FontWeight.w900,
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
          ],
        ),
      ),
    );
  }
}
