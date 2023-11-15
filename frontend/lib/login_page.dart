import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'home_page.dart';
import 'dart:convert';

String login_key='';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}


class LoginPageState extends State<LoginPage> {

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String responseMessage = '';

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
          login_key = firstresponse['key'];
          setState(() {
            responseMessage=login_key;
          });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(),
            settings: RouteSettings(arguments: {'login_key': login_key}),
          ),
        );
          
        }
        else if(response.statusCode == 400){
          setState(() {
            responseMessage = 'Invalid username/password';
          });
        }
        else {
          logger.i('Failed to send data to the API');
          logger.i('Response status code: ${response.statusCode}');
          logger.i('Response body: ${response.body}');
        }
        } catch (e) {
          logger.i('Error: $e');
        }

  }

  void _login(){
    String username = usernameController.text;
    String password = passwordController.text;


    sendLoginData(username,password);
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username/Email'),
            ),
            SizedBox(height: 20),
            TextField(
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _login();
              },
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            Text(
              responseMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16,
              color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}