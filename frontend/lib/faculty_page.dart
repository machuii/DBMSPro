import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';
import 'dart:convert';
import 'login_page.dart';
import 'session_page.dart';

class MyFacultyPage extends StatefulWidget {
  @override
  FacultyPage createState() => FacultyPage();
}

class FacultyPage extends State<MyFacultyPage> {
  List<Map<String, dynamic>> recent_sessions = [];
  String batch_selected = 'elective';
  String active_time = '';
  List<String> dropdownOptions = ['CS01', 'CS02', 'CS03', 'CS04','elective'];
  String fac_name = '';
  List<List<dynamic>> course_sessions = [];
  Map<String, String> sid_list={};



  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      await fetchData();  
      await fetchcourse(); 
      setState(() {});
    } catch (e) {
      print("Error loading data: $e");
      // Handle the error as needed
    }
  }

  Future<void> fetchcourse() async{
    try{
      var new_response= await http.get(Uri.parse('http://localhost:8000/api/course_sessions/'),headers:myheaders);
      if(new_response.statusCode==200){
        course_sessions=List<List<dynamic>>.from(jsonDecode(new_response.body));
      }
      else{
        throw Exception("recent_session status code: ${new_response.statusCode}");
      }
    }
    catch(e){
      print("error: $e");
    }
  }

  Future<void> fetchData() async {
    try {
      var response = await http.get(Uri.parse('http://localhost:8000/api/recent_sessions/'),headers:myheaders,);
      if (response.statusCode == 200) {
        setState(() {
          recent_sessions = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        throw Exception("recent_session status code: ${response.statusCode}");
      }
    } catch (e) {
      print("error: $e");
    }
  }

  void view_faculty_page() {
    setState(() {
      fac_name = response_msg?['name'] ?? 'null';
    });
  }

  void session_details(String ?sid_){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MySessionPage(sid: sid_),
        settings: RouteSettings(arguments: {'login_key': login_key}),
      ),
    );
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
    sid_list = Map<String, String>.from(json.decode(response.body));
    
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

  Future<void> create_session(String batch_selected, String active_time) async{
    if (batch_selected == '' || active_time == '') {
      print('select batch and duration');
    } 
    else{
      await make_session(batch_selected, active_time);
    }
      
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => MyFacultyPage()),
    );
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
        SizedBox(height: 16),
        if (!(response_msg?['is_elective'] ?? false))
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
          onPressed: () async{
            await create_session(batch_selected, active_time);
          },
          child: Text('create session'),
        ),
        Expanded(
          child: recent_sessions.isEmpty
            ? Center(
                child: Text(
                  'is empty',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : ListView.builder(
                itemCount: recent_sessions.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      session_details(sid_list['sid']);
                    },
                    child: ListTile(
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
                    ),
                  );
                },
              ),
        ),

          Expanded(
            child: course_sessions.isEmpty
                ? Center(
                    child: Text(
                      '',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
  itemCount: course_sessions.length,
  itemBuilder: (context, index) {
    return GestureDetector(
          onTap: () {
            // batch_attended(course_sessions[index][0],course_sessions[index][1]);
          },
          child: Container(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                'List ${index + 1}',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${course_sessions[index][0]}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    '${course_sessions[index][1]}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),

          ),

      ],
    ),
  );
}
}

