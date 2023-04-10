import 'dart:async';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:drivers_app/widgets/fare_amount_collection_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../assistants/assistant_methods.dart';
import '../widgets/progress_dialogue.dart';

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

  Set<Marker> setOfMarkers = <Marker>{};
  Set<Circle> setOfCircle = <Circle>{};
  Set<Polyline> setOfPolyline = <Polyline>{};
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();
  Position? onlineDriverCurrentPosition;

  String rideRequestStatus = "accepted";

  String durationFromOriginToDestination = "";
  bool isRequestDirectionDetails = false;

//Draw polyline from source to destination.
  //Step1 : When driver accepts the ride request
  // originLatLng = driver current location
  //                &
  // destinationLatLng = user pickup location.

  //Step 2 : Driver already picked up the user in the vehicle.
  //originLatLng = user pickupLocation
  //                &
  //destinationLatLng = user dropOff Location
  Future<void> drawPolyLineFromOriginToDestination(
      LatLng originLatLng, LatLng destinationLatLng) async {
    //wait till the api fetches data and show some message to the user till data is fetched.
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgressDialogue(message: "Please wait..."),
    );

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    Navigator.pop(context);

    print("These are the points = ");
    print(directionDetailsInfo!.e_points!);
    // print(directionDetailsInfo.distance_text);
    // print(directionDetailsInfo.distance_value);
    // print(directionDetailsInfo.duration_text);
    // print(directionDetailsInfo.duration_value);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);

    polyLinePositionCoordinates.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        polyLinePositionCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();

    if (mounted) {
      setState(() {
        Polyline polyline = Polyline(
          color: const Color(0xFFFFAA33),
          // color: Colors.black,
          polylineId: const PolylineId("PolyLineID"),
          jointType: JointType.round,
          points: polyLinePositionCoordinates,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );
        setOfPolyline.add(polyline);
      });
    }

    //This will help to adjust the zoom as per origin and destination
    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, originLatLng.longitude));
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          northeast:
              LatLng(originLatLng.latitude, destinationLatLng.longitude));
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newTripGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    //Markers to show user current position and destination
    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    if (mounted) {
      setState(() {
        setOfMarkers.add(originMarker);
        setOfMarkers.add(destinationMarker);
      });
    }

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: const Color(0xFFFCF9BE),
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.red,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: const Color(0xFFD6E4E5),
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.red,
      center: destinationLatLng,
    );

    if (mounted) {
      setState(() {
        setOfCircle.add(originCircle);
        setOfCircle.add(destinationCircle);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    saveAssignedDriverDetailsToUserRideRequest();
  }

  //Animated marker after driver accepts the ride.
  createDriverIconMarker() {
    if (iconAnimatedMarker == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "images/movingCarIcon.png")
          .then((value) {
        iconAnimatedMarker = value;
      });
    }
  }

  //keeps updating the driver's live location.
  getDriversLocationUpdatesAtRealTime() {
    LatLng oldLatLng = const LatLng(0, 0);
    streamSubscriptionDriverLivePosition =
        Geolocator.getPositionStream().listen((Position position) {
      userCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      LatLng latLngLiveDriverPosition = LatLng(
        onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude,
      );

      Marker animatingMarker = Marker(
        markerId: const MarkerId("animatedMarker"),
        position: latLngLiveDriverPosition,
        icon: iconAnimatedMarker!,
        infoWindow: const InfoWindow(title: "This is your current location"),
      );

      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: latLngLiveDriverPosition, zoom: 17);
        newTripGoogleMapController!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        setOfMarkers.removeWhere(
            (element) => element.markerId.value == "animatedMarker");
        setOfMarkers.add(animatingMarker);
      });

      oldLatLng = latLngLiveDriverPosition;
      updateDurationTimeAtRealTime();

      //For updating the driver location in real time in the database every second.
      Map driverLatLngDataMap = {
        "latitude": onlineDriverCurrentPosition!.latitude.toString(),
        "longitude": onlineDriverCurrentPosition!.longitude.toString(),
      };

      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(widget.userRideRequestDetails!.rideRequestId!)
          .child("driverLocation")
          .set(driverLatLngDataMap);
    });
  }

  updateDurationTimeAtRealTime() async {
    if (isRequestDirectionDetails == false) {
      isRequestDirectionDetails = true;

      //If we are unable to get the driver location then return and stop executing further.
      if (onlineDriverCurrentPosition == null) {
        return;
      }

      var originLatLng = LatLng(
          onlineDriverCurrentPosition!.latitude,
          onlineDriverCurrentPosition!
              .longitude); //This is the driver current location

      var destinationLatLng;

      if (rideRequestStatus == "accepted") {
        //This is basically the user pickup location
        destinationLatLng = widget.userRideRequestDetails!.originLatLng;
      } else {
        //This is the user Drop Off location.
        destinationLatLng = widget.userRideRequestDetails!.destinationLatLng;
      }
      var directionInformation =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
              originLatLng, destinationLatLng);

      if (directionInformation != null) {
        setState(() {
          durationFromOriginToDestination = directionInformation.duration_text!;
        });
      }
      isRequestDirectionDetails = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    createDriverIconMarker();

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding, top: 50),
            mapType: MapType.normal,
            myLocationEnabled: true,
            // zoomGesturesEnabled: true,
            // zoomControlsEnabled: false,
            initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,

            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController = controller;

              setState(() {
                mapPadding = 320;
              });

              var driverCurrentLatLng = LatLng(userCurrentPosition!.latitude,
                  userCurrentPosition!.longitude);
              var userPickUpLatLng =
                  widget.userRideRequestDetails!.originLatLng;

              //Step 1: where driver current position is the origin
              drawPolyLineFromOriginToDestination(
                  driverCurrentLatLng, userPickUpLatLng!);

              getDriversLocationUpdatesAtRealTime();
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  children: [
                    //Duration of the ride
                    Text(
                      durationFromOriginToDestination,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),
                    const Divider(
                      thickness: 1,
                      height: 2,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
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

                    const SizedBox(
                      height: 18,
                    ),

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

                    const SizedBox(
                      height: 20,
                    ),

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
                              widget
                                  .userRideRequestDetails!.destinationAddress!,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 24,
                    ),
                    const Divider(
                      thickness: 1,
                      height: 2,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    ElevatedButton.icon(
                      onPressed: () async {
                        //this means that the driver has arrived at the user pickup location.
                        //Arrived Button.
                        if (rideRequestStatus == "accepted") {
                          rideRequestStatus = "arrived";

                          //change the status from accepted to arrived in the database as well.
                          FirebaseDatabase.instance
                              .ref()
                              .child("All Ride Requests")
                              .child(
                                  widget.userRideRequestDetails!.rideRequestId!)
                              .child("status")
                              .set(rideRequestStatus);

                          setState(() {
                            buttonTitle = "Lets Go";
                            buttonColor = const Color(0xFFFFAA33);
                          });

                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext c) => ProgressDialogue(
                                    message: "Please Wait..",
                                  ));

                          await drawPolyLineFromOriginToDestination(
                            widget.userRideRequestDetails!.originLatLng!,
                            widget.userRideRequestDetails!.destinationLatLng!,
                          );

                          Navigator.pop(context);
                        }

                        //user has already sat in the car - so we can start the trip.
                        //Lets go button
                        else if (rideRequestStatus == "arrived") {
                          rideRequestStatus = "ontrip";

                          //change the status from accepted to arrived in the database as well.
                          FirebaseDatabase.instance
                              .ref()
                              .child("All Ride Requests")
                              .child(
                                  widget.userRideRequestDetails!.rideRequestId!)
                              .child("status")
                              .set(rideRequestStatus);

                          setState(() {
                            buttonTitle = "End Trip";
                            buttonColor = Colors.redAccent;
                          });
                        }

                        //user has already sat in the car - so we can start the trip.
                        //Lets go button
                        else if (rideRequestStatus == "ontrip") {
                          endTripNow();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )),
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

  endTripNow() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) => ProgressDialogue(
              message: "Please Wait..",
            ));

    //Get the trip direction details - distance travelled.
    var currentDriverPositionLatLng = LatLng(
        onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude);

    var tripDirectionDetails =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            currentDriverPositionLatLng,
            widget.userRideRequestDetails!.originLatLng!);

    //Calculate fare amount.
    double totalFareAmount =
        AssistantMethods.calculateFareAmountFromOriginToDestination(
            tripDirectionDetails!);

    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child("fareAmount")
        .set(totalFareAmount.toString());

    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child("status")
        .set("ended");

    streamSubscriptionDriverLivePosition!.cancel();

    Navigator.pop(context);

    //Display fare amount in dialog box.
    showDialog(
        context: context,
        builder: (BuildContext c) => FareAmountCollectionDialog(
              totalFareAmount: totalFareAmount,
            ));
    //save fare amount to drivers  total earnings.
    saveFareAmountToDriverEarnings(totalFareAmount);
  }

  //save fare amount to drivers  total earnings.
  saveFareAmountToDriverEarnings(double totalFareAmount) {
    FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid)
        .child("earnings")
        .once()
        .then((snap) {
          //this condition checks that earnings sub child exist in the database
          if(snap.snapshot.value != null){
            double oldEarnings = double.parse(snap.snapshot.value.toString());
            double driverTotalEarnings = totalFareAmount + oldEarnings;

            //add the new fare and the old earnings and save to database.
            FirebaseDatabase.instance
                .ref()
                .child("users")
                .child(currentFirebaseUser!.uid)
                .child("earnings")
                .set(driverTotalEarnings.toString());

          }else{
            //earning sub child does not exist. Then First we have to create the sub child.
            FirebaseDatabase.instance
                .ref()
                .child("users")
                .child(currentFirebaseUser!.uid)
                .child("earnings")
                .set(totalFareAmount.toString());
          }
    });
  }

  //Save the details of the driver assigned to the DB
  saveAssignedDriverDetailsToUserRideRequest() {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!);

    Map driverLocationDataMap = {
      "latitude": userCurrentPosition!.latitude.toString(),
      "longitude": userCurrentPosition!.longitude.toString(),
    };

    databaseReference.child("driverLocation").set(driverLocationDataMap);
    databaseReference.child("status").set("accepted");
    databaseReference.child("driverId").set(onlineDriverData.id);
    databaseReference.child("driverName").set(onlineDriverData.name);
    databaseReference.child("driverPhone").set(onlineDriverData.phone);
    databaseReference.child("vehicle_details").set(
        onlineDriverData.vehicleColor.toString() +
            " " +
            onlineDriverData.vehicleModel.toString());

    // saveRideRequestIdToDriverHistory();
  }

  // saveRideRequestIdToDriverHistory() {
  //   DatabaseReference tripsHistoryReference = FirebaseDatabase.instance
  //       .ref()
  //       .child("users")
  //       .child(currentFirebaseUser!.uid)
  //       .child("tripsHistory");
  //
  //   tripsHistoryReference
  //       .child(widget.userRideRequestDetails!.rideRequestId!)
  //       .set(true);
  // }
}
