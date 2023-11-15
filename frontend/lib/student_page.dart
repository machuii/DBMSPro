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

  String fac_name='';

  void view_faculty_page(){
    setState(() {
      fac_name=response_msg?['name'] ?? 'null';
    });
  }

  Future<void> make_session(String batch, String duration) async{

    final response = await http.get(
      Uri.parse('http://localhost:8000/api/fetch_session/'), 
      headers:myheaders,
    );

    try{
      if(response.statusCode==200){
        print('session created');
      }
      else{
        print("make_session response: ${response.statusCode}");
      }
    }
    catch(e){
      logger.i('Error make_session: $e');
    }
  }
  

  @override
  Widget build(BuildContext context) {
    view_faculty_page();
    return Scaffold(
      appBar: AppBar(
        title: Text('faculty'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Text('hiiii'),
        ],
      ),
      
    );
  }
}