// import 'package:contact_tracker/pages/nearbyContactsPage.dart';
import 'package:contact_tracker/pages/contact_history.dart';
import 'package:contact_tracker/pages/login_page.dart';
import 'package:contact_tracker/pages/nearbyContactsPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';

void main() => runApp(MyApp());


class MyApp extends StatefulWidget {
  const MyApp({ Key key }) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
} 


// class _MyAppState extends State<MyApp> {

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NearbyContactsPage(),
//     );
//   }
// }

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {

  String ownerState = "unknown";
  String deviceId = "";
  bool isUserLoggedIn = false;

  final List<Tab> myTabs = <Tab>[
    Tab(
        text: 'Nearby',
    ),
    Tab(
        text: 'History'
      ),
  ];

  // final List<Widget> tabContent = <Widget>[
  //   NearbyContactsPage(personState,nearbyCallback),
  //   ContactHistory()
  // ];

  TabController _tabController;

  @override
  initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: myTabs.length);
  }

 @override
 void dispose() {
   _tabController.dispose();
   super.dispose();
 }

  @override
  Widget build(BuildContext context) {

    var stateIcon = Icon(Icons.account_circle,color: Colors.grey);
    if (ownerState == "unknown")
      stateIcon = Icon(Icons.account_circle,color: Colors.grey);
    else if (ownerState == "green")
      stateIcon = Icon(Icons.account_circle,color: Colors.greenAccent);
    else if (ownerState == "red")
      stateIcon = Icon(Icons.account_circle,color: Colors.red[400]);
    else if (ownerState == "yellow")
      stateIcon = Icon(Icons.account_circle,color: Colors.yellowAccent);

    return isUserLoggedIn? MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Row(children: <Widget>[Text('Covid-19 Besiege'),Text(" #$deviceId",style: TextStyle(fontSize:15),)],),
          actions: <Widget>[
            stateIcon
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: myTabs,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            NearbyContactsPage(ownerState,nearbyCallback),
            ContactHistory()
          ]
        ),
      ),
    ) : LoginPage(loginCallback);
  }

  loginCallback(loginState) {
    if (loginState == "Success"){
      setState(() {
        isUserLoggedIn = true;
        ownerState = globalOwnerState;
      });
    }
  }

  nearbyCallback(placeholder) async {

    final prefs = await SharedPreferences.getInstance();

    var persistentOwnerState = prefs.getString("ownerState");
    if (persistentOwnerState != null){
      setState(() {
        ownerState = persistentOwnerState;
      });
    }

    var persistentDeviceId = prefs.getString("deviceId");
    if (persistentDeviceId != null)
      setState(() {
        deviceId = persistentDeviceId;
      });



  }

}