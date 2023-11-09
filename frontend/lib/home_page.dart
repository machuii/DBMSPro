import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inclass/login_page.dart';
import 'package:logger/logger.dart';


class MyHomePage extends StatefulWidget{
  @override
  HomePage createState() => HomePage();
}

String response_msg='';

class HomePage extends State<MyHomePage> {

  @override

  void initState(){
    super.initState();
    sendpostrequest();
  }

  void sendpostrequest() async {
    var url=Uri.parse('http://localhost:8000/api/dj-rest-auth/login/');
    var myheaders={
      'key': login_key,
    };

    var response=await http.post(url, headers: myheaders); 

    if(response.statusCode==200){
      response_msg= response.body;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Text(response_msg,),
      ),
    );
  }
}
