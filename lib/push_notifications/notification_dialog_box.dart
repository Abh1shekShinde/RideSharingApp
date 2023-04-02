import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:drivers_app/mainScreens/new_trip_screen.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';

class NotificationDialogBox extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;

  NotificationDialogBox({
    this.userRideRequestDetails,
  });

  @override
  _NotificationDialogBoxState createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      backgroundColor: const Color(0xFF),
      // elevation: 2,
      child: Container(
        margin: EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color(0xFFFFFFE8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // const SizedBox(height: 14,),
            Image.asset(
              "images/notificationLogo.jpg",
              width: 120,
            ),
            const SizedBox(
              height: 2,
            ),
            const Text(
              "New Ride Share Request ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 15),

            const Divider(
              height: 3,
              thickness: 3,
            ),

            //Origin and Destination Address
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  //origin location with icon
                  Row(
                    children: [
                      Image.asset(
                        "images/origin.png",
                        width: 25,
                        height: 25,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userRideRequestDetails!.originAddress!,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 30),

                  //destination location with icon
                  Row(
                    children: [
                      Image.asset(
                        "images/destination.png",
                        width: 25,
                        height: 25,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userRideRequestDetails!.destinationAddress!,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(
              height: 3,
              thickness: 3,
            ),

            //Accept and Cancel Ride request buttons
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Button to reject the request
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                    ),
                    onPressed: () {
                      //This will stop the notification sound
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AssetsAudioPlayer();
                      //cancel the request
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 30,
                  ),

                  //Button to accept the request
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                    ),
                    onPressed: () {
                      //This will stop the notification sound
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AssetsAudioPlayer();
                      //Accept the request
                      acceptRideRequest(context);
                    },
                    child: Text(
                      "Accept".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  acceptRideRequest(BuildContext context) {
    String getRideRequestId = "";

    FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        getRideRequestId = snap.snapshot.value.toString();
        print("------This is the ride request ID------");
        print(getRideRequestId);
      } else {
        Fluttertoast.showToast(msg: "This ride request does not exist");
      }
      // print("------This is the ride request ID------");
      // print(getRideRequestId);
      // Fluttertoast.showToast(msg: "getRideRequestId" + getRideRequestId);

      if (getRideRequestId == widget.userRideRequestDetails!.rideRequestId) {
        FirebaseDatabase.instance
            .ref()
            .child("users")
            .child(currentFirebaseUser!.uid)
            .child("newRideStatus")
            .set("accepted");

        AssistantMethods.pauseLiveLocationUpdates();

        //Send the driver to Trip Screen.

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) => NewTripScreen(
                      userRideRequestDetails: widget.userRideRequestDetails,
                    )));
      } else {
        Fluttertoast.showToast(msg: "This Ride Request do not exist");
      }
    });
  }
}
