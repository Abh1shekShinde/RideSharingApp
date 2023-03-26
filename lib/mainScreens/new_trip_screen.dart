import 'dart:async';

import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class NewTripScreen extends StatefulWidget {

  UserRideRequestInformation? userRideRequestDetails;
  NewTripScreen({
    this.userRideRequestDetails,
});

  @override
  _NewTripScreenState createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {

  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 5,
  );

  String? buttonTitle = "Arrived";
  Color? buttonColor = Colors.green;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            // zoomGesturesEnabled: true,
            // zoomControlsEnabled: false,
            initialCameraPosition: _kGooglePlex,

            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController = controller;

            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration:BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                color: const Color(0xFFDEF5E5),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
                boxShadow: const [
                  BoxShadow(
                  color: Colors.white10,
                  blurRadius: 18,
                  spreadRadius: 0.5,
                  offset: Offset(0.6, 0.6),
                ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  children: [

                    //Duration of the ride
                    Text(
                      "18 minutes",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),

                    const SizedBox(height: 18,),
                    const Divider(thickness: 1,height: 2, color: Colors.grey,),
                    const SizedBox(height: 10,),
                    //User name
                    Row(
                      children: [
                        Text(
                    widget.userRideRequestDetails!.userName!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const Icon(
                          Icons.phone_android,
                          color: Colors.red,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18,),

                    //UserPickUP location with Icon.
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

                    const SizedBox(height: 20,),

                    //User Drop off location with Icon
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

                    const SizedBox(height: 24,),
                    const Divider(thickness: 1,height: 2, color: Colors.grey,),
                    const SizedBox(height: 20,),

                    ElevatedButton.icon(
                      onPressed: (){

                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )
                      ),
                      icon: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 25,
                      ),
                      label: Text(
                        buttonTitle!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    )

                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
