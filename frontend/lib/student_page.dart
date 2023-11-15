import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'home_page.dart';
import 'dart:convert';
import 'login_page.dart';

class MyStudentPage extends StatefulWidget {
  @override
  StudentPage createState() => StudentPage();
}


class StudentPage extends State<MyStudentPage> {

  String batch_selected = '';
  String active_time='';
  List<String> dropdownOptions = ['cs01', 'cs02', 'cs03', 'cs04'];

  String stu_name='';

  void view_student_page(){
    setState(() {
      stu_name=response_msg?['name'] ?? 'null';
    });
  }


  @override
  Widget build(BuildContext context) {
    view_student_page();
    return Scaffold(
      appBar: AppBar(
        title: Text('student'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Text(stu_name),
        ],
      ),
      
    );
  }
}