import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inclass/login_page.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

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
    var url=Uri.parse('http://localhost:8000/api/profile/');
   
    var myheaders={
      'key': '${login_key}',
    };
    logger.i('Request Headers: $myheaders');


    final response=await http.get(url, headers: myheaders,); 
//  logger.i(login_key);
    try{
      if(response.statusCode==200){
        setState(() {
          logger.i(response.body);
          response_msg = Map<String,String>.from(json.decode(response.body));
        });
        if(response_msg==null){
          logger.i("null response");
        }
        
      }
      else{
        logger.i(response.statusCode);
      }
    }
    catch(e){
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