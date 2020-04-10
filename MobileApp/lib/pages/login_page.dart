import 'dart:convert';
import 'dart:developer';
import 'package:contact_tracker/globals.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {

  Function(String) callback;

  LoginPage(this.callback);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool isLoading = true;
  @override
  void initState(){
    super.initState();

    _checkLoginState();
      }
    
      @override
      Widget build(BuildContext context) {
        return  MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: new Text('Login'),
            ),
            body: Center(
              
              child: isLoading ? AlertDialog(
                    title: new Text("Loading .."),
                    content: new Text("Please wait."),
                  ): RaisedButton(
                  onPressed: () {
                    _facebookLogin();
                  },
                  child: const Text(
                    'Facebook Login',
                    style: TextStyle(fontSize: 20,color: Colors.white)
                  ),
                  color: Colors.blue[800],
                ),
            ),
          ),
        ); 
    
        
      }
    
      _facebookLogin() async {
          final facebookLogin = FacebookLogin();
          final result = await facebookLogin.logIn(['email']);
    
          switch (result.status) {
            case FacebookLoginStatus.loggedIn:
              log("Logged in Successfully thank God :) ");
              var response =  http.post(new Uri.http('${cfg["backendHost"]}', '/login/fb'),
                  headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(<String,dynamic>{
                  "token": result.accessToken.token,
                }),
              );
    
              response.then((onValue) async {
                var jsonResponse = json.decode(onValue.body.toString());
                if (jsonResponse['Status'] == "Success"){
                  log("Success");
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString("nativejwt", jsonResponse['nativeToken']);
                  await prefs.setString("deviceId", jsonResponse['deviceID']);
                  await prefs.setString("ownerState", jsonResponse['personState']);
                  global_deviceID = jsonResponse['deviceID'];
                  globalOwnerState = jsonResponse['personState'];
                  globalJWT = jsonResponse['nativeToken'];
                  widget.callback("Success");
                }else{
                  log("Fail");
                }
              });
              break;
            case FacebookLoginStatus.cancelledByUser:
              
              break;
            case FacebookLoginStatus.error:
              
              break;
          }
      }
    
      Future<void> _checkLoginState() async {
        final prefs = await SharedPreferences.getInstance();
        var jwt =  prefs.getString("nativejwt");
        if (jwt != null){
          globalJWT = jwt;
          widget.callback("Success");
        }else{
          setState(() {
            isLoading = false;
          });
        }

      }
}