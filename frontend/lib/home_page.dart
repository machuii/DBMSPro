import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';
import 'faculty_page.dart';
import 'student_page.dart';
import 'login_page.dart';



var logger=Logger();
Map<String,dynamic>? response_msg={};


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

  final response = await http.get(url, headers: myheaders);

  try {
    if (response.statusCode == 200) {
      setState(() {
        logger.i(response.body);
        response_msg = Map<String, dynamic>.from(json.decode(response.body));
      });
      (response_msg != null && response_msg?['roll_no'] == null)
      ? Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyFacultyPage(),
            settings: RouteSettings(arguments: {'login_key': login_key}),
          ),
        )
        :Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyStudentPage(),
            settings: RouteSettings(arguments: {'login_key': login_key}),
          ),
        );
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