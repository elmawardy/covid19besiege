import 'dart:async';
import 'dart:convert';
// import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shortid/shortid.dart';

import '../globals.dart';
// import 'package:nearby_connections/nearby_connections.dart';
import 'package:location/location.dart';

class NearbyContactsPage extends StatefulWidget {
  Function(String) callback;
  String myState = "unknown";

  NearbyContactsPage(this.myState, this.callback);

  @override
  _NearbyContactsPageState createState() => _NearbyContactsPageState();
}

class _NearbyContactsPageState extends State<NearbyContactsPage>
    with AutomaticKeepAliveClientMixin<NearbyContactsPage> {
  // List<Contact> contactsBuffer = List<Contact>();
  List<Contact> nearbyContacts = List<Contact>();
  List<Contact> contactsBuffer = List<Contact>();

  // final String userName = "asd";
  // final Strategy strategy = Strategy.P2P_STAR;
  Location location = new Location();
  LocationData currentLocation;

  static const platform =
      const MethodChannel('samples.flutter.dev/nearconnect');

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // currentLocation = null;
    // Nearby().stopAdvertising();
    // Nearby().stopDiscovery();

    try {
      platform.setMethodCallHandler((MethodCall call) async {
        if (call.method == 'foundsome1') _foundsome1(call.arguments);

        if (call.method == 'some1left') _some1left(call.arguments);
      });
    } catch (e) {
      log("$e");
    }

    _identifyBeforeStream();
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await _getCurrentLocation();
    //   // _discoverContacts();
    //   // _connectNearby();
    //   _incrementTime();
    // });
  }

  @override
  Widget build(BuildContext context) {
    var connectionColorIcon = Icon(Icons.account_circle, color: Colors.grey);

    return Scaffold(
      body: new ListView.builder(
          itemCount: nearbyContacts.length,
          itemBuilder: (context, index) {
            if (nearbyContacts[index].state == "green") {
              connectionColorIcon =
                  Icon(Icons.account_circle, color: Colors.green);
            } else if (nearbyContacts[index].state == "yellow") {
              connectionColorIcon =
                  Icon(Icons.account_circle, color: Colors.yellow[600]);
            } else if (nearbyContacts[index].state == "red") {
              connectionColorIcon =
                  Icon(Icons.account_circle, color: Colors.red);
            } else {
              connectionColorIcon =
                  Icon(Icons.account_circle, color: Colors.grey);
            }
            return ListTile(
              leading: connectionColorIcon,
              title: Text('${nearbyContacts[index].id}'),
              subtitle: Text(
                  '${nearbyContacts[index].lastSeen.difference(nearbyContacts[index].firstSeen).inMinutes} Minutes'),
            );
          }),
    );
  }

  _identifyBeforeStream() async {
    final prefs = await SharedPreferences.getInstance();
    if (global_deviceID == "") {
      global_deviceID = shortid.generate();

      var persistentDeviceId = prefs.getString("deviceId");
      if (persistentDeviceId != null)
        global_deviceID = persistentDeviceId;
      else {
        await prefs.setString("deviceId", global_deviceID);
      }
    }

    var uri = cfg["dev"]
        ? new Uri.http('${cfg["backendHost"]}', '/api/person/getstate')
        : new Uri.https('${cfg["backendHost"]}', '/api/person/getstate');
    var response = http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{"deviceId": global_deviceID}),
    );

    response.then((onValue) async {
      var r = json.decode(onValue.body.toString());
      if (r['Status'] == "Success") {
        globalOwnerState = r['PersonState'];
        var persistendOwnerState = prefs.getString("ownerState");
        if (persistendOwnerState != null && persistendOwnerState != "")
          globalOwnerState = persistendOwnerState;
        else {
          await prefs.setString("ownerState", globalOwnerState);
        }

        widget.callback("");
      }
    });

    _streamAndDiscover();
  }

  _streamAndDiscover() {
    // send default callback to Class instantiator to trigger reading the deviceId from storage

    try {
      var result = platform.invokeMethod('advertise',
          {"deviceId": global_deviceID, "ownerState": globalOwnerState});
      result.then((onValue) {
        if (onValue == 0) log("Platform is Advertising...");
      });
    } on PlatformException catch (e) {
      log("${e.message}.");
    }

    try {
      var result = platform.invokeMethod('discover');
      result.then((onValue) {
        if (onValue == 0) log("Platform is Discoverting...");
      });
    } on PlatformException catch (e) {
      log("${e.message}.");
    }

    _updateTimeAndLocation();
  }

  _foundsome1(String endPointName) {
    var immutableEndPointName = endPointName;

    // get endpoint name without person state after @prefix state
    endPointName = endPointName.split('@')[0];

    bool alreadyConnected = false;
    var connectedIndex = 0;
    for (var i = 0; i < nearbyContacts.length; i++) {
      if (nearbyContacts[i].id == endPointName) {
        alreadyConnected = true;
        connectedIndex = i;
      }
    }

    if (!alreadyConnected) {
      final newContacts = nearbyContacts;
      newContacts.add(new Contact(
          //endPointName,endPointName,"${currentLocation.latitude},${currentLocation.longitude}","${currentLocation.latitude},${currentLocation.longitude}",DateTime.now(),DateTime.now()
          //endPointName,"0,0","0,0",DateTime.now(),DateTime.now(),"Unknown"
          endPointName,
          currentLocation != null
              ? "${currentLocation.latitude},${currentLocation.longitude}"
              : "0,0",
          currentLocation != null
              ? "${currentLocation.latitude},${currentLocation.longitude}"
              : "0,0",
          DateTime.now(),
          DateTime.now(),
          "Unknown"));
      if (this.mounted)
        setState(() {
          nearbyContacts = newContacts;
        });

      // If already connected
    } else {
      final contact = nearbyContacts[connectedIndex];
      contact.lastSeen = DateTime.now();
      contact.lastLocation = currentLocation != null
          ? "${currentLocation.latitude},${currentLocation.longitude}"
          : "0,0";

      final newContacts = nearbyContacts;
      newContacts[connectedIndex] = contact;

      if (this.mounted)
        setState(() {
          nearbyContacts = newContacts;
        });
    }

    _changePersonState(immutableEndPointName);
    log("$nearbyContacts");
  }

// _discoverContacts() async{

//   try {
//         Nearby().askLocationAndExternalStoragePermission();
//         bool discovering = await Nearby().startDiscovery(
//             userName,
//             strategy,
//             onEndpointFound: (String id,String userName, String serviceId) async {
//                 // called when an advertiser is found
//                 log("some1 found");

//             },
//             onEndpointLost: (String id) {
//                 //called when an advertiser is lost (only if we weren't connected to it )

//                 var temp = contactsBuffer;
//                 temp.add(nearbyContacts.where((item)=>item.connectionid == id).elementAt(0));
//                 setState(() {
//                   contactsBuffer=temp;
//                 });

//                 var newContacts = nearbyContacts;
//                 newContacts.removeWhere((item) => item.connectionid == id);
//                 setState(() {
//                   nearbyContacts = newContacts;
//                 });

//                 _flushContacts();

//             },
//             serviceId: "com.yourdomain.appname", // uniquely identifies your app
//         );
//         if (discovering){
//           log("Scanning");

//         }else{
//           log("Not Scanning ?");
//         }
//     } catch (e) {
//         // platform exceptions like unable to start bluetooth or insufficient permissions
//         log('$e');
//     }
// }

// _connectNearby() async{

//   try {
//     bool advertising = await Nearby().startAdvertising(
//         userName,
//         strategy,
//         onConnectionInitiated: (String id,ConnectionInfo info) async {
//         // Called whenever a discoverer requests connection
//           try {
//             await Nearby().rejectConnection(id);
//           } catch (e) {
//             log("$e");
//           }
//         },
//         onConnectionResult: (String id,Status status) {
//         // Called when connection is accepted/rejected
//           log("$id : $status");
//         },
//         onDisconnected: (String id) {
//         // Callled whenever a discoverer disconnects from advertiser
//           log("Disconnected $id");
//         },
//         serviceId: "com.yourdomain.appname", // uniquely identifies your app
//     );
//     } catch (exception) {
//         // platform exceptions like unable to start bluetooth or insufficient permissions
//         log("$exception");
//     }
// }

  _incrementNearby() {
    if (nearbyContacts.length > 0) {
      var newContacts = nearbyContacts;
      for (var i = 0; i < newContacts.length; i++) {
        newContacts[i].lastSeen = DateTime.now();
        newContacts[i].lastLocation = currentLocation != null
            ? "${currentLocation.latitude},${currentLocation.longitude}"
            : "0,0";
      }

      if (this.mounted)
        setState(() {
          nearbyContacts = newContacts;
        });
    }
  }

  _updateTimeAndLocation() {
    var timer = new Timer.periodic(const Duration(seconds: 20), (Timer t) {
      _incrementNearby();
      _getCurrentLocation();
    });

    log("timer state : ${timer.isActive}");
  }

  void _some1left(String deviceId) {
    //called when an advertiser is lost (only if we weren't connected to it )

    var newContacts = nearbyContacts;

    deviceId = deviceId.split('@')[0];
    var tempContact =
        newContacts.where((item) => item.id == deviceId).elementAt(0);
    contactsBuffer.add(tempContact);
    newContacts.removeWhere((item) => item.id == deviceId);

    if (this.mounted)
      setState(() {
        nearbyContacts = newContacts;
      });

    _flushContacts();
  }

  Future<void> _changePersonState(String deviceIdAndstate) async {
    var personState = deviceIdAndstate.split('@')[1];

    var temp = nearbyContacts
        .where((contact) => contact.id == deviceIdAndstate.split('@')[0])
        .elementAt(0);

    if (temp.state != 'green' && temp.state != "Unknown") {
      if (temp.state == 'yellow' && personState == "red")
        temp.state = personState;
    } else {
      temp.state = personState.toLowerCase();
    }

    var tempContacts = nearbyContacts;
    tempContacts[nearbyContacts.indexOf(temp)] = temp;

    if (this.mounted)
      setState(() {
        nearbyContacts = tempContacts;
      });

    if (personState == "red") {
      final prefs = await SharedPreferences.getInstance();
      var persistentOwnerState = prefs.getString("ownerState");
      if (persistentOwnerState != null) {
        if (persistentOwnerState != "red") globalOwnerState = "yellow";
        await prefs.setString("ownerState", globalOwnerState);
      }

      widget.callback("");
    }

    var uri = cfg["dev"]
        ? new Uri.http('${cfg["backendHost"]}', '/api/person/getstate')
        : new Uri.https('${cfg["backendHost"]}', '/api/person/getstate');
    var response = http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "deviceId": deviceIdAndstate.split('@')[0],
      }),
    );

    response.then((onValue) async {
      var r = json.decode(onValue.body.toString());
      if (r['Status'] == "Success") {
        var temp = nearbyContacts
            .where((contact) => contact.id == deviceIdAndstate.split('@')[0])
            .elementAt(0);

        if ((temp.state == 'green' || temp.state == "Unknown") ||
            (temp.state == "yellow" && r['PersonState'] == 'red'))
          temp.state = r['PersonState'];

        var tempContacts = nearbyContacts;
        tempContacts[nearbyContacts.indexOf(temp)] = temp;
        if (this.mounted)
          setState(() {
            nearbyContacts = tempContacts;
          });

        if (r['PersonState'] == "red") {
          final prefs = await SharedPreferences.getInstance();
          var persistentOwnerState = prefs.getString("ownerState");
          if (persistentOwnerState != null) {
            if (persistentOwnerState != "red") {
              globalOwnerState = "yellow";
              await prefs.setString("ownerState", globalOwnerState);
            }
          }

          widget.callback("");
        }
      }
    });
  }

  _getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    currentLocation = await location.getLocation();
    Timer.periodic(const Duration(milliseconds: 10000),
        (Timer t) async => currentLocation = await location.getLocation());
  }

  _flushContacts() {
    List<Contact> contacts = List<Contact>();

    for (var i = 0; i < contactsBuffer.length; i++) {
      contacts.add(new Contact(
          contactsBuffer[i].id,
          contactsBuffer[i].firstLocation,
          contactsBuffer[i].lastLocation,
          contactsBuffer[i].firstSeen,
          contactsBuffer[i].lastSeen,
          contactsBuffer[i].state));
    }

    // var contactsJson = jsonEncode(contacts.map((c)=>c.toJson()).toList());

    var uri = cfg["dev"]
        ? new Uri.http('${cfg["backendHost"]}', '/api/contacts/add')
        : new Uri.https('${cfg["backendHost"]}', '/api/contacts/add');
    var response = http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "from_deviceid": global_deviceID,
        "contacts": contacts,
        "jwt": globalJWT
      }),
    );

    response.then((onValue) {
      var jsonResponse = json.decode(onValue.body.toString());
      if (jsonResponse['Status'] == "Success") {
        log("Success");
        contactsBuffer.clear();
      } else {
        log("Fail");
      }
    });
  }
}

class Contact {
  String id;
  String firstLocation;
  String lastLocation;
  DateTime firstSeen;
  DateTime lastSeen;
  String state;

  Map<String, dynamic> toJson() => {
        'to_deviceid': id,
        'initial_location': firstLocation.toString(),
        'last_location': lastLocation.toString(),
        'first_time': firstSeen.toString(),
        'last_time': lastSeen.toString()
      };

  Contact(this.id, this.firstLocation, this.lastLocation, this.firstSeen,
      this.lastSeen, this.state);
}
