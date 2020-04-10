import 'dart:convert';
import 'dart:developer' as dev;

import 'package:contact_tracker/globals.dart';
import 'package:contact_tracker/pages/nearbyContactsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


class ContactHistory extends StatefulWidget {
  @override
  _ContactHistoryState createState() => _ContactHistoryState();
}

class _ContactHistoryState extends State<ContactHistory> {

  List<Contact> historyContacts = List<Contact>();
  final dateFormat = new DateFormat('yyyy-MM-dd hh:mm a');
  int initilOffset = 0;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState(){
    super.initState();
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: WaterDropHeader(),
          footer: CustomFooter(
            builder: (BuildContext context,LoadStatus mode){
              Widget body ;
              if(mode==LoadStatus.idle){
                body =  Text("pull up load");
              }
              else if(mode==LoadStatus.loading){
                body =  CupertinoActivityIndicator();
              }
              else if(mode == LoadStatus.failed){
                body = Text("Load Failed!Click retry!");
              }
              else if(mode == LoadStatus.canLoading){
                  body = Text("release to load more");
              }
              else{
                body = Text("No more Data");
              }
              return Container(
                height: 55.0,
                child: Center(child:body),
              );
            },
          ),
          controller: _refreshController,
          onRefresh: _refreshHistory,
          onLoading: _loadHistory,
          child: ListView.builder(
            itemBuilder: (c, i) => Container(
              child: ListTile(
                leading: Icon(Icons.account_circle,color:Colors.green),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(historyContacts[i].id),
                  Text("From : ${dateFormat.format(historyContacts[i].firstSeen)}",style: TextStyle(fontSize:12),),
                  Text("To : ${dateFormat.format(historyContacts[i].lastSeen)}",style: TextStyle(fontSize:12),),
                ],)
              ),
            ),
            itemExtent: 100.0,
            itemCount: historyContacts.length,
          ),
        ),
      );
  }

  void _loadHistory(){
      var response = http.post(new Uri.http('${cfg["backendHost"]}', '/contacts/get'),
        headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String,dynamic>{
        "fromDeviceId": global_deviceID,
        "offset":initilOffset,
        "count":5,
        "jwt":globalJWT
      }),
    );

    response.then((r){
      var responseJSON = json.decode(r.body.toString());
      var tempContacts = historyContacts;
      for (var i=0;i<responseJSON.length;i++){
          dev.log("${responseJSON[i]}");
                var startTime = new DateTime.fromMillisecondsSinceEpoch(int.parse(responseJSON[i]['FirstTime'])*1000);
                var lastTime = new DateTime.fromMillisecondsSinceEpoch(int.parse(responseJSON[i]['LastTime'])*1000);
          tempContacts.add(new Contact(responseJSON[i]['ToDeviceID'],"${responseJSON[i]['InitialLatitude']},${responseJSON[i]['InitialLongitude']}",
          "${responseJSON[i]['LastLatitude']},${responseJSON[i]['LastLongitude']}",startTime,lastTime,"Unknown"));
      }

      setState(() {
        historyContacts  = tempContacts;
      });

    
      _refreshController.loadComplete();

    });

    setState(() {
        initilOffset = initilOffset+2;
    });

  }

  void _refreshHistory() async{

    setState(() {
      initilOffset = 0;
    });
    historyContacts.clear();

    var response = http.post(new Uri.http('${cfg["backendHost"]}', '/contacts/get'),
        headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String,dynamic>{
        "fromDeviceId": global_deviceID,
        "offset":0,
        "count":5,
        "jwt":globalJWT
      }),
    );

    response.then((r){
      var responseJSON = json.decode(r.body.toString());
      var tempContacts = historyContacts;
      for (var i=0;i<responseJSON.length;i++){
          dev.log("${responseJSON[i]}");
          var startTime = new DateTime.fromMillisecondsSinceEpoch(int.parse(responseJSON[i]['FirstTime'])*1000);
          var lastTime = new DateTime.fromMillisecondsSinceEpoch(int.parse(responseJSON[i]['LastTime'])*1000);
          tempContacts.add(new Contact(responseJSON[i]['ToDeviceID'],"${responseJSON[i]['InitialLatitude']},${responseJSON[i]['InitialLongitude']}",
          "${responseJSON[i]['LastLatitude']},${responseJSON[i]['LastLongitude']}",startTime,lastTime,"Unknown"));
      }

      setState(() {
        historyContacts  = tempContacts;
      });

      _refreshController.refreshCompleted();

    }).catchError((onError){
      dev.log("$onError");
    });

  }


}