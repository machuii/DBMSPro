import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';
import 'dart:convert';
import 'login_page.dart';

class MyFacultyPage extends StatefulWidget {
  @override
  FacultyPage createState() => FacultyPage();
}

class FacultyPage extends State<MyFacultyPage> {
  List<Map<String, dynamic>> recent_sessions = [];
  String batch_selected = 'cs01';
  String active_time = '';
  List<String> dropdownOptions = ['cs01', 'cs02', 'cs03', 'cs04'];
  String fac_name = '';
  Map<String,dynamic>course_sessions={};

  @override
  void initState() {
    super.initState();
    fetchData(); // Call the method to send the GET request
  }

  Future<void> fetchData() async {
    try {
      var response = await http.get(Uri.parse('http://localhost:8000/api/recent_sessions/'),headers:myheaders,);
      if (response.statusCode == 200) {
        setState(() {
          recent_sessions = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
        print("${response.body}");
      } else {
        throw Exception("recent_session status code: ${response.statusCode}");
      }
    } catch (e) {
      print("error: $e");
    }

    try{
      var new_response= await http.get(Uri.parse('http://localhost:8000/api/course_sessions/'),headers:myheaders);
      if(new_response.statusCode==200){
        course_sessions=Map<String, dynamic>.from(jsonDecode(new_response.body));
        // print("${new_response.body}");
      }
      else{
        throw Exception("recent_session status code: ${new_response.statusCode}");
      }
    }
    catch(e){
      print("error: $e");
    }
  }

  void view_faculty_page() {
    setState(() {
      fac_name = response_msg?['name'] ?? 'null';
    });
  }

  Future<void> make_session(String batch, String duration) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/create_session/'),
      body: {
        'batch': batch,
        'duration': duration,
      },
      headers: myheaders,
    );
    response_msg = Map<String, String>.from(json.decode(response.body));
    print(response_msg?['sid']);
    try {
      if (response.statusCode == 200) {
        print(response);
      } else {
        print("make_session response: ${response.statusCode}");
      }
    } catch (e) {
      print('Error make_session: $e');
    }
  }

  void create_session(String batch_selected, String active_time) {
    if (batch_selected == '' || active_time == '') {
      print('select batch and duration');
    } else
      make_session(batch_selected, active_time);
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
      children: [
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
            create_session(batch_selected, active_time);
          },
          child: Text('create session'),
        ),
        // Wrap the Column with Expanded
        Expanded(
          child: ListView.builder(
            itemCount: recent_sessions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(recent_sessions[index]['course'] ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recent_sessions[index]['batch'] ?? ''),
                    Text(recent_sessions[index]['datetime'] ?? ''),
                  ],
                ),
                leading: Text(
                  (recent_sessions[index]['attendance']).toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: course_sessions.length,
            itemBuilder: (context, index) {
              final key = course_sessions.keys.elementAt(index);
              final value = course_sessions[key];
              print('$key : $value');
              return ListTile(
                title: Text('$key : $value'),
              );
            },
          ),
        ),
      ],
    ),
  );
}
}