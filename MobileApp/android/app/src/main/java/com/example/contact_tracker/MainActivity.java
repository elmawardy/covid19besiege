package com.example.contact_tracker;

import androidx.annotation.NonNull;
import java.util.HashMap;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.google.android.gms.nearby.Nearby;
import com.google.android.gms.nearby.connection.Strategy;
import com.google.android.gms.nearby.connection.ConnectionsClient;
import com.google.android.gms.nearby.connection.AdvertisingOptions;
import com.google.android.gms.nearby.connection.ConnectionInfo;
import com.google.android.gms.nearby.connection.ConnectionLifecycleCallback;
import com.google.android.gms.nearby.connection.ConnectionResolution;
import com.google.android.gms.nearby.connection.DiscoveredEndpointInfo;
import com.google.android.gms.nearby.connection.DiscoveryOptions;
import com.google.android.gms.nearby.connection.EndpointDiscoveryCallback;


public class MainActivity extends FlutterActivity {

    public static final Strategy STRATEGY = Strategy.P2P_STAR;
    public static final String SERVICE_ID="com.yourdomain.appname";
    private ConnectionsClient connectionsClient;
    private static final String CHANNEL = "samples.flutter.dev/nearconnect";
    private static MethodChannel channel = null;
    HashMap<String, String> nearbyConnections = new HashMap<String, String>();

    @Override
        public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        

        if (channel != null) {
            throw new IllegalStateException("You should not call registerWith more than once.");
        }
        
        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);

        GeneratedPluginRegistrant.registerWith(flutterEngine);
        connectionsClient = Nearby.getConnectionsClient(this);

        
        channel.setMethodCallHandler(
          (call, result) -> {
                if (call.method.equals("advertise")) {
                System.out.println("asd");
                int exitCode = startAdvertising(call.argument("deviceId"),call.argument("ownerState"));
                    if (exitCode != -1) {
                        result.success(exitCode);
                    } else {
                        result.error("UNAVAILABLE", "Advertising not available.", null);
                    }
                } else if (call.method.equals("discover")) {
                    int exitCode = startDiscovery();
                    if (exitCode != -1) {
                        System.out.println("Java : Discovering nearby length : "+nearbyConnections.size());
                        if (nearbyConnections.size() > 0){
                            nearbyConnections.forEach((k, v) -> {
                                channel.invokeMethod("foundsome1", v);
                            });
                        }
                        result.success(exitCode);
                    } else {
                        result.error("UNAVAILABLE", "Discovering not available.", null);
                    }
                } 
                else {
                result.notImplemented();
                }
          }
        );


        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "samples.flutter.dev/mainconnet")
        .setMethodCallHandler(
          (call, result) -> {
                if (call.method.equals("changeOwnerState")) {
                    System.out.println("Java : Owner changed state");
                    connectionsClient.stopAdvertising();
                    int exitCode = startAdvertising(call.argument("ownerDeviceId"),call.argument("newOwnerState"));
                     if (exitCode != -1) {
                        result.success(exitCode);
                    } else {
                        result.error("UNAVAILABLE", "Advertising not available.", null);
                    }
                }
          }
        );



    }


    private int startAdvertising(String deviceId,String ownerState) {
        // Note: Advertising may fail. To keep this demo simple, we don't handle failures.
        connectionsClient.startAdvertising(
                deviceId+"@"+ownerState, SERVICE_ID, connectionLifecycleCallback,
                new AdvertisingOptions.Builder().setStrategy(STRATEGY).build());

        return 0;
    }

    private int startDiscovery() {
        // Note: Discovery may fail. To keep this demo simple, we don't handle failures.
        connectionsClient.startDiscovery(
                SERVICE_ID, endpointDiscoveryCallback,
                new DiscoveryOptions.Builder().setStrategy(STRATEGY).build());

        return 0;
    }

    private final ConnectionLifecycleCallback connectionLifecycleCallback =
      new ConnectionLifecycleCallback() {
        @Override
        public void onConnectionInitiated(String endpointId, ConnectionInfo connectionInfo) {
          
        }

        @Override
        public void onConnectionResult(String endpointId, ConnectionResolution result) {
         
        }

        @Override
        public void onDisconnected(String endpointId) {
         
        }
    };

      // Callbacks for finding other devices
    private final EndpointDiscoveryCallback endpointDiscoveryCallback =
        new EndpointDiscoveryCallback() {
        @Override
        public void onEndpointFound(String endpointId, DiscoveredEndpointInfo info) {
            // Log.i(TAG, "onEndpointFound: endpoint found.");
            // connectionsClient.requestConnection(codeName, endpointId, connectionLifecycleCallback);

            nearbyConnections.put(endpointId,info.getEndpointName());
            System.out.println("Found Some1 "+info.getEndpointName());
            channel.invokeMethod("foundsome1", info.getEndpointName());
        }

        @Override
        public void onEndpointLost(String endpointId) {
            System.out.println("Java : Some1left");
            channel.invokeMethod("some1left", nearbyConnections.get(endpointId));
            nearbyConnections.remove(endpointId);
        }
    };

}
