// import 'package:contact_tracker/pages/nearbyContactsPage.dart';
import 'dart:developer';

import 'package:contact_tracker/pages/contact_history.dart';
import 'package:contact_tracker/pages/login_page.dart';
import 'package:contact_tracker/pages/nearbyContactsPage.dart';
import 'package:contact_tracker/pages/statistics_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);
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
  static const platform = const MethodChannel('samples.flutter.dev/mainconnet');

  final List<Tab> myTabs = <Tab>[
    Tab(
      text: 'Nearby',
      icon: Icon(Icons.near_me),
    ),
    Tab(
      text: 'Stats',
      icon: Icon(Icons.trending_down),
    ),
    Tab(
      text: 'History',
      icon: Icon(Icons.history),
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
    var stateIcon = Icon(Icons.account_circle, color: Colors.grey);
    if (ownerState == "unknown")
      stateIcon = Icon(Icons.account_circle, color: Colors.grey);
    else if (ownerState == "green")
      stateIcon = Icon(Icons.account_circle, color: Colors.greenAccent);
    else if (ownerState == "red")
      stateIcon = Icon(Icons.account_circle, color: Colors.red[400]);
    else if (ownerState == "yellow")
      stateIcon = Icon(Icons.account_circle, color: Colors.yellowAccent);

    List<String> stateChoices = <String>["Yellow", "Green"];

    return isUserLoggedIn
        ? MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: Column(
                  children: <Widget>[
                    Text('Covid-19 Besiege'),
                    Text(
                      " #$deviceId",
                      style: TextStyle(fontSize: 13),
                    )
                  ],
                ),
                actions: <Widget>[
                  stateIcon,
                  PopupMenuButton<String>(
                    onSelected: _stateChoiceSelected,
                    itemBuilder: (BuildContext context) {
                      return stateChoices.map((String choice) {
                        return PopupMenuItem<String>(
                          child: Text(choice),
                          value: choice,
                        );
                      }).toList();
                    },
                  )
                ],
                bottom: TabBar(
                  controller: _tabController,
                  tabs: myTabs,
                ),
              ),
              body: TabBarView(
                  controller: _tabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    NearbyContactsPage(ownerState, nearbyCallback),
                    StatsPage(),
                    ContactHistory()
                  ]),
            ),
          )
        : LoginPage(loginCallback);
  }

  loginCallback(loginState) async {
    if (loginState == "Success") {
      final prefs = await SharedPreferences.getInstance();

      var persistentDeviceId = prefs.getString("deviceId");
      if (persistentDeviceId != null)
        setState(() {
          deviceId = persistentDeviceId;
          global_deviceID = persistentDeviceId;
        });
      var persistentOwnerState = prefs.getString("ownerState");
      if (persistentDeviceId != null)
        setState(() {
          globalOwnerState = persistentOwnerState;
          ownerState = persistentOwnerState;
        });

      setState(() {
        isUserLoggedIn = true;
      });
    }
  }

  nearbyCallback(placeholder) async {
    final prefs = await SharedPreferences.getInstance();

    var persistentOwnerState = prefs.getString("ownerState");
    if (persistentOwnerState != null) {
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

  _stateChoiceSelected(String newOwnerState) async {
    if (newOwnerState == "Yellow" && ownerState != 'yellow') {
      setState(() {
        ownerState = 'yellow';
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("ownerState", ownerState);

      platform.invokeMethod("changeOwnerState",
          {"ownerDeviceId": deviceId, "newOwnerState": newOwnerState});
    }
    if (newOwnerState == "Green" && ownerState != 'green') {
      setState(() {
        ownerState = 'green';
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("ownerState", ownerState);

      platform.invokeMethod("changeOwnerState",
          {"ownerDeviceId": deviceId, "newOwnerState": newOwnerState});
    }
  }
}
