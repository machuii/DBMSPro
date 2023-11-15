import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inclass/login_page.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'faculty_page.dart';
import 'student_page.dart';


var logger=Logger();
Map<String,String>? response_msg={};


class MyHomePage extends StatefulWidget{
  @override
  HomePage createState() => HomePage();
}


class HomePage extends State<MyHomePage> {

  @override

  void initState(){
    super.initState();
    sendgetrequest();
  }


  void sendgetrequest() async {
  var url = Uri.parse('http://localhost:8000/api/profile/');

  var myheaders = {
    'Authorization': 'Token $login_key'
  };

  // Print key-value pairs of myheaders
  myheaders.forEach((key, value) {
    print('$key: $value');
  });

  final response = await http.get(url, headers: myheaders);

  try {
    if (response.statusCode == 200) {
      setState(() {
        logger.i(response.body);
        response_msg = Map<String, String>.from(json.decode(response.body));
      });
      response_msg['roll_no']==null
      ? Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FacultyPage(),
            settings: RouteSettings(arguments: {'login_key': login_key}),
          ),
        )
        :Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StudentPage(),
            settings: RouteSettings(arguments: {'login_key': login_key}),
          ),
        )
    } else {
      logger.i('Error - Status Code: ${response.statusCode}');
      logger.i('${login_key}');
    }
  } catch (e) {
    logger.i("error: $e");
  }
}


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: response_msg == null
            ? CircularProgressIndicator()  // Or another loading indicator
            : Text(response_msg?['name'] ?? 'null'),
        ),
    );
  }
}