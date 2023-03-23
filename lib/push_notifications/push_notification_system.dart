import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:drivers_app/push_notifications/notification_dialog_box.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async {
    //1. Terminated State -- When the app is closed and app opened directly from the notification.
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {

      if (remoteMessage != null) {
        // display the ride request information - user information.
        // print("\nThis is Ride request id: ");
        // print(remoteMessage.data["rideRequestId"]);

        readUserRideRequestInformation(remoteMessage.data["rideRequestId"], context);

      }
    });

    //2. Foreground State -- when the app is open and in use and it gets a notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      // display the ride request information - user information.
      // print("\nThis is Ride request id: ");
      // print(remoteMessage!.data["rideRequestId"]);

      readUserRideRequestInformation(remoteMessage!.data["rideRequestId"], context);
    });

    //3. Background State -- When the app is minimized and app is opened from the notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      // display the ride request information - user information.
      // print("\nThis is Ride request id: ");
      // print(remoteMessage!.data["rideRequestId"]);

      readUserRideRequestInformation(remoteMessage!.data["rideRequestId"], context);
    });
  }

  readUserRideRequestInformation(String userRideRequestId, context) {
    FirebaseDatabase.instance.ref()
        .child("All Ride Requests")
        .child(userRideRequestId)
        .once()
        .then((snapData)
    {
      if(snapData.snapshot.value != null){
        // Origin Details :
        double originLat = double.parse((snapData.snapshot.value! as Map)["origin"]["latitude"]);
        double originLng = double.parse((snapData.snapshot.value! as Map)["origin"]["longitude"]);
        String originAddress = (snapData.snapshot.value! as Map)["originAddress"];


        // Destination Details :
        double destinationLat = double.parse((snapData.snapshot.value! as Map)["destination"]["latitude"]);
        double destinationLng = double.parse((snapData.snapshot.value! as Map)["destination"]["longitude"]);
        String destinationAddress = (snapData.snapshot.value! as Map)["destinationAddress"];

        //User Information :
        String userName = (snapData.snapshot.value! as Map)["userName"];
        String userPhone = (snapData.snapshot.value! as Map)["userPhone"];


        UserRideRequestInformation userRideRequestDetails = UserRideRequestInformation();

        userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
        userRideRequestDetails.originAddress = originAddress;

        userRideRequestDetails.destinationLatLng = LatLng(destinationLat, destinationLng);
        userRideRequestDetails.destinationAddress = destinationAddress;

        userRideRequestDetails.userName = userName;
        userRideRequestDetails.userPhone = userPhone;

        // print("User Ride request information: ");
        // print(userRideRequestDetails.userName);
        // print(userRideRequestDetails.userPhone);
        // print(userRideRequestDetails.originAddress);
        // print(userRideRequestDetails.destinationAddress);
        
        showDialog(
            context: context,
            builder: (BuildContext context) => NotificationDialogBox(
                userRideRequestDetails: userRideRequestDetails,
            ),
        );

      }else
        {
        Fluttertoast.showToast(msg: "This Ride request Id do not exist");
      }

    });

  }

  //Get the user token
  Future generateAndGetToken() async {

    String? registrationToken = await messaging.getToken();
    print("\nFirebase Cloud Messaging Registration Token: $registrationToken \n");

    FirebaseDatabase.instance
        .ref()
        .child("users")  //users or activeDrivers
        .child(currentFirebaseUser!.uid)
        .child("token")
        .set(registrationToken);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }
}
