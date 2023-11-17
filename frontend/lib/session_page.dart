import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'home_page.dart';
import 'dart:convert';
import 'login_page.dart';


List<Map<String,String>> attended_students=[];
String apiUrl='';


class MySessionPage extends StatefulWidget{
  final String? sid;
  MySessionPage({required this.sid, Key? key}) : super(key: key);
  @override
  SessionPage createState() => SessionPage();
}

class SessionPage extends State<MySessionPage> {
   @override
  
  void initState(){
    super.initState();
    send_session(widget.sid);
  }

  void send_session(String ?sid) async{
    try{
      String encodedSearchString = Uri.encodeComponent(sid??'null');
      apiUrl = 'https://loaclhost:8000/api/attended_students/?sid=$encodedSearchString';
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: myheaders,
      );

      if(response.statusCode==200){
        attended_students=List<Map<String,String>>.from(json.decode(response.body));
      }
      else{
        print("response code: ${response.statusCode}");
      }
    }
    catch(e){
      print(e);
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Session Page'),
      ),
      body: attended_students.isEmpty
          ? Center(
              // Display this when attended_students is empty
              child: Text(
                'No attended students',
                style: TextStyle(color: Colors.black),
              ),
            )
          : Expanded(
              child: ListView.builder(
                itemCount: attended_students.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text('Student ID: ${attended_students[index]['name']}'),
                      subtitle: Text('Name: ${attended_students[index]['roll_no']}'),
                    ),
                  );
                },
              ),
            ),
    );
  }

}