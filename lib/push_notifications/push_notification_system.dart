import 'package:drivers_app/global/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging() async {
    //1. Terminated State -- When the app is closed and app opened directly from the notification.
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {

      if (remoteMessage != null) {
        // display the ride request information - user information.
        print("\nThis is Ride request id: ");
        print(remoteMessage.data["rideRequestId"]);

      }
    });

    //2. Foreground State -- when the app is open and in use and it gets a notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      // display the ride request information - user information.
      print("\nThis is Ride request id: ");
      print(remoteMessage!.data["rideRequestId"]);
    });

    //3. Background State -- When the app is minimized and app is opened from the notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      // display the ride request information - user information.
      print("\nThis is Ride request id: ");
      print(remoteMessage!.data["rideRequestId"]);
    });
  }

  //Get the user token
  Future generateAndGetToken() async {

    String? registrationToken = await messaging.getToken();
    print("\nFirebase Cloud Messaging Registration Token: $registrationToken \n");

    FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid)
        .child("token")
        .set(registrationToken);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }
}
