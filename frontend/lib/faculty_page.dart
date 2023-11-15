import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'home_page.dart';
import 'dart:convert';
import 'login_page.dart';

class MyFacultyPage extends StatefulWidget {
  @override
  FacultyPage createState() => FacultyPage();
}


class FacultyPage extends State<MyFacultyPage> {

  String batch_selected = 'cs01';
  String active_time='';
  List<String> dropdownOptions = ['cs01', 'cs02', 'cs03', 'cs04'];

  String fac_name='';

  void view_faculty_page(){
    setState(() {
      fac_name=response_msg?['name'] ?? 'null';
    });
  }

  Future<void> make_session(String batch, String duration) async{
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/create_session/'), 
      body: {
        'batch': batch,
        'duration': duration,
      },
      headers:myheaders,
    );
    response_msg = Map<String, String>.from(json.decode(response.body));
    print(response_msg?['sid']);
    try{
      if(response.statusCode==200){
        print(response);
      }
      else{
        print("make_session response: ${response.statusCode}");
      }
    }
    catch(e){
      logger.i('Error make_session: $e');
    }
  }

  void create_session(String batch_selected, String active_time){
    if(batch_selected=='' || active_time==''){
      print('select batch and duration');
    }
    else
      make_session(batch_selected,active_time);
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
          Text(fac_name),
          DropdownButton<String>(
            value: batch_selected,
            items: dropdownOptions.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                batch_selected = newValue!;
              });
            },
          ),
          TextField(
            onChanged: (text) {
              setState(() {
                active_time = text;
              });
            },
            decoration: InputDecoration(labelText: 'duration'),
          ),
          ElevatedButton(
            onPressed: () {
                create_session(batch_selected,active_time);
              },
            child: Text('create session'),
          ),
        ],
      ),
      
    );
  }
}