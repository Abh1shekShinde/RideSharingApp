import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:drivers_app/assistants/geofire_assistant.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/mainScreens/rate_driver_screen.dart';
import 'package:drivers_app/mainScreens/search_places_screen.dart';
import 'package:drivers_app/mainScreens/select_nearest_active_drivers_screen.dart';
import 'package:drivers_app/models/active_nearby_available_drivers.dart';
import 'package:drivers_app/push_notifications/push_notification_system.dart';
import 'package:drivers_app/widgets/my_drawer.dart';
import 'package:drivers_app/widgets/progress_dialogue.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../infoHandler/app_info.dart';
import '../widgets/pay_fare_amount_dialog.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 5,
  );

  GlobalKey<ScaffoldState> skey = GlobalKey<ScaffoldState>();

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  double searchLocationContainerHeight = 220.0;
  double waitingResponseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;
  String driverRideStatus = "On the way..";
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;
  String userRideRequestStatus = "";

  bool requestPositionInfo = true;

  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String userName = "";
  String userEmail = "";

  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyDriverIcon;

  List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList = [];

  DatabaseReference? referenceRideRequest;

  //This will check if the user has enabled device location or not.
  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  //Function for getting user location
  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    userCurrentPosition = cPosition;
    LatLng latLangPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    //used to change the animation of camera when user is moving.
    CameraPosition cameraPosition =
        CameraPosition(target: latLangPosition, zoom: 20);
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoordinates(
            userCurrentPosition!, context);

    print("this is your current address : $humanReadableAddress");

    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;

    initializeGeoFireListener();

    AssistantMethods.readTripKeysForOnlineUser(context);
    AssistantMethods.readDriverRatings(context);
  }

  //Function for notification
  readCurrentDriverInformation() async {
    currentFirebaseUser = fAuth.currentUser;

    await FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((DatabaseEvent snap) {
      if (snap.snapshot.value != null) {
        onlineDriverData.id = (snap.snapshot.value as Map)["id"];
        onlineDriverData.name = (snap.snapshot.value as Map)["name"];
        onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
        onlineDriverData.email = (snap.snapshot.value as Map)["email"];
        onlineDriverData.vehicleColor =
            (snap.snapshot.value as Map)["vehicle_details"]["vehicleColor"];
        onlineDriverData.vehicleModel =
            (snap.snapshot.value as Map)["vehicle_details"]["vehicleModel"];
        onlineDriverData.vehicleNumber =
            (snap.snapshot.value as Map)["vehicle_details"]["vehicleNumber"];
        driverVehicleType =
            (snap.snapshot.value as Map)["vehicle_details"]["vehicleType"];

        print("Driver Car details: ");
        print(onlineDriverData.name);
        print(onlineDriverData.vehicleModel);
        print(onlineDriverData.vehicleType);
      }
    });
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();

    AssistantMethods.readDriverEarnings(context);
  }

  saveRideRequestInformation() {
    //1. Save the Ride request Information
    referenceRideRequest =
        FirebaseDatabase.instance.ref().child("All Ride Requests").push();
    //.push() will generate a unique id everytime a ride is requested.

    var originLocation =
        Provider.of<AppInfo>(context, listen: false).userPickupLocation;
    var destinationLocation =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    Map originLocationMap = {
      //"key" : value

      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation.locationLongitude.toString(),
    };

    Map destinationLocationMap = {
      //"key" : value

      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation.locationLongitude.toString(),
    };

    Map userInformationMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "driverId": "waiting",
    };

    //Add request details to database.
    referenceRideRequest!.set(userInformationMap);

    tripRideRequestInfoStreamSubscription =
        referenceRideRequest!.onValue.listen((eventSnap) async{
      if (eventSnap.snapshot.value == null) {
        return;
      }

      if ((eventSnap.snapshot.value as Map)["vehicle_details"] != null) {
        setState(() {
          driverVehicleDetails =
              (eventSnap.snapshot.value as Map)["vehicle_details"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["userPhone"] != null) {
        setState(() {
          userPhone = (eventSnap.snapshot.value as Map)["userPhone"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["userName"] != null) {
        setState(() {
          userName = (eventSnap.snapshot.value as Map)["userName"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["status"] != null) {
        userRideRequestStatus = (eventSnap.snapshot.value as Map)["status"];
      }

      if ((eventSnap.snapshot.value as Map)["driverLocation"] != null) {
        double driverCurrentPositionLat = double.parse(
            (eventSnap.snapshot.value as Map)["driverLocation"]["latitude"]
                .toString());
        double driverCurrentPositionLng = double.parse(
            (eventSnap.snapshot.value as Map)["driverLocation"]["longitude"]
                .toString());

        LatLng driverCurrentPositionLatLng =
            LatLng(driverCurrentPositionLat, driverCurrentPositionLng);

        //status = accepted
        if (userRideRequestStatus == "accepted") {
          updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng);
        }

        //status = arrived
        if (userRideRequestStatus == "arrived") {
          driverRideStatus = "Your ride is here";
        }

        //status = ontrip
        if (userRideRequestStatus == "ontrip") {
          updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng);
        }

        //status = ended
        if (userRideRequestStatus == "ended") {
          if ((eventSnap.snapshot.value as Map)["fareAmount"] != null) {
            double fareAmount = double.parse(
                (eventSnap.snapshot.value as Map)["fareAmount"].toString());

            var response = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext c) => PayFareAmountDialog(
                      fareAmount: fareAmount,
                    ));

            if(response == "cashPayed"){
              //User can rate the driver.
              if ((eventSnap.snapshot.value as Map)["driverId"] != null) {
                String assignedDriverId = (eventSnap.snapshot.value as Map)["driverId"].toString();
                Navigator.push(context, MaterialPageRoute(builder: (c)=> RateDriverScreen(
                  assignedDriverId: assignedDriverId,
                )));

                referenceRideRequest!.onDisconnect();
                tripRideRequestInfoStreamSubscription!.cancel();


              }
            }
          }
        }
      }
    });

    //If no available driver
    referenceRideRequest!.remove();

    //save the ride request given by the user to database.
    onlineNearByAvailableDriversList =
        GeoFireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers();
  }

  updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      LatLng userPickUpPosition =
          LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      var directionDetailsInfo =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
              driverCurrentPositionLatLng, userPickUpPosition);

      if (directionDetailsInfo == null) {
        return;
      }
      setState(() {
        driverRideStatus = "Ride is Arriving in : " +
            directionDetailsInfo.duration_text.toString();
      });
      requestPositionInfo = true;
    }
  }

  updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      var dropOffLocation =
          Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

      LatLng userDestinationPosition = LatLng(
          dropOffLocation!.locationLatitude!,
          dropOffLocation.locationLongitude!);

      var directionDetailsInfo =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatLng,
        userDestinationPosition,
      );

      if (directionDetailsInfo == null) {
        return;
      }
      setState(() {
        driverRideStatus = "Reaching the destination in : " +
            directionDetailsInfo.duration_text.toString();
      });
      requestPositionInfo = true;
    }
  }

  searchNearestOnlineDrivers() async {
    //When there is no active driver available
    if (onlineNearByAvailableDriversList.isEmpty) {
      //we have to cancel the ride request
      if (mounted) {
        setState(() {
          polyLineSet.clear();
          markersSet.clear();
          circlesSet.clear();
          pLineCoordinatesList.clear();
        });
      }

      Fluttertoast.showToast(msg: "No online nearest ride available");

      // MyApp.restartApp(context);

      return;
    }

    //If there is any nearest online driver available.
    await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);

    var response = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => SelectNearestActiveDriversScreen(
                referenceRideRequest: referenceRideRequest)));

    if (response == "driverSelected") {
      FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(chosenDriverId!)
          .once()
          .then((snap) {
        if (snap.snapshot.value != null) {
          // send notification to the specific driver.
          sendNotificationToDriverNow(chosenDriverId!);

          //Waiting for the response from the rider UI.----> 1. and 2. below
          showWaitingResponseFromDriverUI();

          FirebaseDatabase.instance
              .ref()
              .child("users")
              .child(chosenDriverId!)
              .child("newRideStatus")
              .onValue
              .listen((eventSnapshot) {
            //1. Rider has cancelled the request.
            if (eventSnapshot.snapshot.value == "idle") {
              Fluttertoast.showToast(
                  msg: "The Rider has reject your ride share request.");
            }

            //2. Rider has accept the request.
            if (eventSnapshot.snapshot.value == "accepted") {
              //UI after accepting the request.
              showUIForAssignedDriverInfo();
            }
          });
        } else {
          Fluttertoast.showToast(msg: "This user does not exist.. Try Again!!");
        }
      });
    }
  }

  showUIForAssignedDriverInfo() {
    setState(() {
      waitingResponseFromDriverContainerHeight = 0;
      searchLocationContainerHeight = 0;
      assignedDriverInfoContainerHeight = 240;
    });
  }

  showWaitingResponseFromDriverUI() {
    setState(() {
      searchLocationContainerHeight = 0;
      waitingResponseFromDriverContainerHeight = 220;
    });
  }

  sendNotificationToDriverNow(String chosenDriverId) {
    //assign ride request to new ride status in users parent node for tha specific chosen driver.
    FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(chosenDriverId)
        .child("newRideStatus")
        .set(referenceRideRequest!.key);

    //Automate the push notification.
    FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(chosenDriverId)
        .child("token")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        String deviceRegistrationToken = snap.snapshot.value.toString();

        //as we have the registration token ... we can send the notification.
        AssistantMethods.sendNotificationToDriverNow(
          deviceRegistrationToken,
          referenceRideRequest!.key.toString(),
          context,
        );
        Fluttertoast.showToast(msg: "Notification sent successfully");
      } else {
        Fluttertoast.showToast(
            msg: "There is some problem with the selected ride.");
        return;
      }
    });
  }

  retrieveOnlineDriversInformation(List onlineNearestDrivesList) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("users");
    for (int i = 0; i < onlineNearByAvailableDriversList.length; i++) {
      await ref
          .child(onlineNearestDrivesList[i].driverId.toString())
          .once()
          .then((dataSnapshot) {
        var driverKeyInfo = dataSnapshot.snapshot.value;
        dList.add(driverKeyInfo);
        print("\n-----Driver Key information" + dList.toString() + "-----");
      });
    }
  }

  @override
  void initState() {
    super.initState();

    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
  }

  @override
  Widget build(BuildContext context) {
    createActiveNearbyDriverIconMarker();
    return Scaffold(
        key: skey,
        drawer: Container(
          // for setting the width of drawer
          // width: 250,
          child: Theme(
            data: Theme.of(context)
                .copyWith(canvasColor: const Color(0xFFFAEEE0)),
            child: MyDrawer(
              name: userName,
              email: userEmail,
            ),
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: bottomPaddingOfMap, top: 40),
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              initialCameraPosition: _kGooglePlex,
              polylines: polyLineSet,
              markers: markersSet,
              circles: circlesSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                //Function for getting user location - both user as well as driver
                locateUserPosition();

                if (mounted) {
                  setState(() {
                    bottomPaddingOfMap = 220;
                  });
                }
              },
            ),

            //Ui for online offline for Driver.
            statusText != "Share Ride" ? Container() : Container(),

            //Custom button for drawer
            Positioned(
              top: 50,
              left: 22,
              child: GestureDetector(
                onTap: () {
                  skey.currentState!.openDrawer();
                },
                child: const CircleAvatar(
                  maxRadius: 25,
                  backgroundColor: Color(0xFFFFA45B),
                  child: Icon(
                    Icons.menu,
                    color: Colors.black,
                    size: 25,
                  ),
                ),
              ),
            ),

            // UI for searching location
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSize(
                curve: Curves.easeIn,
                duration: const Duration(milliseconds: 120),
                child: Container(
                  height: searchLocationContainerHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 0),
                    color: const Color(0xffE8F9FD), //e3f2fd , e2eafc
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 24),
                    child: Column(
                      children: [
                        //From Location fields
                        Row(
                          children: [
                            const Icon(
                              Icons.add_location_alt_outlined,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "From",
                                  style: TextStyle(
                                    color: Color(0xFFFF7800),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  Provider.of<AppInfo>(context)
                                              .userPickupLocation !=
                                          null
                                      ? "${(Provider.of<AppInfo>(context).userPickupLocation!.locationName!).substring(0, 35)} ..."
                                      : " Unable to get location",
                                  style: const TextStyle(
                                    color: Color(0xFFFF7800),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),

                        const SizedBox(height: 10),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: () async {
                            //go to the search places Screen
                            var responseFromSearchScreen = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) =>
                                        const SearchPlacesScreen()));

                            if (responseFromSearchScreen == "obtainedDropOff") {
                              //Draw Routes  - draw polyline between location and destination.
                              await drawPolyLineFromOriginToDestination();
                            }
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add_location_alt_outlined,
                                color: Colors.grey,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "To",
                                    style: TextStyle(
                                      color: Color(0xFFFF7800),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    Provider.of<AppInfo>(context)
                                                .userDropOffLocation !=
                                            null
                                        ? Provider.of<AppInfo>(context)
                                            .userDropOffLocation!
                                            .locationName!
                                        : "Your Destination",
                                    style: const TextStyle(
                                      color: Color(0xFFFF7800),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50),
                              //Search Rides button
                              child: ElevatedButton(
                                onPressed: () {
                                  if (Provider.of<AppInfo>(context,
                                              listen: false)
                                          .userDropOffLocation !=
                                      null) {
                                    saveRideRequestInformation();
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Please choose your destination");
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFAA33),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    )),
                                child: const Text(
                                  "Search Ride",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            //Button for online offline driver
                            // Positioned(
                            //   top: statusText != "Sharing Ride"
                            //       ? MediaQuery.of(context).size.height * 0.855
                            //       : MediaQuery.of(context).size.height * 0.855 ,
                            //   left: 150,
                            //   right: 0,
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            ElevatedButton(
                              onPressed: () {
                                if (Provider.of<AppInfo>(context, listen: false)
                                        .userDropOffLocation !=
                                    null) {
                                  if (isDriverActive !=
                                      true) //Offline condition
                                  {
                                    driverIsOnlineNow();
                                    updateDriversLocationAtRealTime();

                                    if (mounted) {
                                      setState(() {
                                        statusText = "Sharing Ride";
                                        isDriverActive = true;
                                        buttonColor = Colors.green;
                                      });
                                    }
                                    // display Toast message
                                    Fluttertoast.showToast(
                                        msg: "You are now Sharing your Ride");
                                  } else {
                                    driverIsOfflineNow();
                                    if (mounted) {
                                      setState(() {
                                        statusText = "Share Ride";
                                        isDriverActive = false;
                                        buttonColor = Colors.grey;
                                      });
                                    }
                                    // display Toast message
                                    Fluttertoast.showToast(
                                        msg: "You are not Sharing your Ride");
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Please choose your destination");
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  )),
                              child: statusText != "Sharing Ride"
                                  ? const Text(
                                      "Share Ride",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      "Stop Sharing Ride",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            //UI for waiting for response from rider
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: waitingResponseFromDriverContainerHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 0),
                  color: const Color(0xffE8F9FD), //e3f2fd , e2eafc
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        FadeAnimatedText(
                          'Waiting for response \nfrom Driver..',
                          duration: const Duration(seconds: 6),
                          textAlign: TextAlign.center,
                          textStyle: const TextStyle(
                              fontSize: 30.0,
                              color: Color(0xFFFF6000),
                              fontWeight: FontWeight.bold),
                        ),
                        ScaleAnimatedText(
                          'Please Wait..',
                          duration: const Duration(seconds: 10),
                          textAlign: TextAlign.center,
                          textStyle: const TextStyle(
                              fontSize: 32.0,
                              color: Color(0xFFFF6000),
                              fontFamily: 'Canterbury'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            //UI for displaying assigned driver information
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: assignedDriverInfoContainerHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 0),
                  color: const Color(0xffE8F9FD), //e3f2fd , e2eafc
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //status of the ride.
                      Center(
                        child: Text(
                          driverRideStatus,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),
                      const Divider(
                        height: 2,
                        thickness: 2,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 10),

                      //driver name
                      Text(
                        userName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 10),

                      //vehicle details of the driver.
                      Text(
                        driverVehicleDetails,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          // fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),

                      const SizedBox(
                        height: 18,
                      ),
                      const Divider(
                        height: 2,
                        thickness: 2,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        height: 20,
                      ),

                      //call the driver button.
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                          icon: const Icon(
                            Icons.phone_enabled,
                            color: Colors.black,
                            size: 24,
                          ),
                          label: const Text(
                            "Call",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

//draw the polyline from source to destination.
  Future<void> drawPolyLineFromOriginToDestination() async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickupLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition.locationLongitude!);

    debugPrint("Origin LatLang :$originLatLng");
    debugPrint('Destination LatLang :$destinationLatLng');

    //wait till the api fetches data and show some message to the user till data is fetched.
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgressDialogue(message: "Please wait..."),
    );

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

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

    pLineCoordinatesList.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoordinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    if (mounted) {
      setState(() {
        Polyline polyline = Polyline(
          color: const Color(0xFFFFAA33),
          // color: Colors.black,
          polylineId: const PolylineId("PolyLineID"),
          jointType: JointType.round,
          points: pLineCoordinatesList,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );
        polyLineSet.add(polyline);
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

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    //Markers to show user current position and destination
    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    if (mounted) {
      setState(() {
        markersSet.add(originMarker);
        markersSet.add(destinationMarker);
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
        circlesSet.add(originCircle);
        circlesSet.add(destinationCircle);
      });
    }
  }

  driverIsOnlineNow() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    userCurrentPosition = pos;

    Geofire.initialize("activeDrivers");
    Geofire.setLocation(currentFirebaseUser!.uid, userCurrentPosition!.latitude,
        userCurrentPosition!.longitude);

    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");

    ref.set("idle");
    ref.onValue.listen((event) {});
  }

  updateDriversLocationAtRealTime() {
    streamSubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) {
      userCurrentPosition = position;
      if (isDriverActive == true) {
        Geofire.setLocation(currentFirebaseUser!.uid,
            userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      }
      LatLng latLng = LatLng(
        userCurrentPosition!.latitude,
        userCurrentPosition!.longitude,
      );

      newGoogleMapController!.animateCamera((CameraUpdate.newLatLng(latLng)));
    });
  }

  driverIsOfflineNow() {
    Geofire.removeLocation(currentFirebaseUser!.uid);
    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");

    ref.onDisconnect();
    ref.remove();
    ref = null;

    // Future.delayed(const Duration(milliseconds: 2000), (){
    //   SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    // });
  }

  initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");
    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 5)!
        .listen((map)
            //lat long and 5 is the radius in km up to which active drivers will be displayed.
            {
      print("Geofire query Map:  $map");
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          //When any driver becomes active i.e comes online
          case Geofire.onKeyEntered:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver =
                ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.activeNearbyAvailableDriversList
                .add(activeNearbyAvailableDriver);
            if (activeNearbyDriverKeysLoaded == true) {
              displayActiveDriversOnMap();
            }
            break;

          //When any driver becomes non active i.e goes offline
          case Geofire.onKeyExited:
            GeoFireAssistant.deleteOfflineDriverFromList(map['key']);
            displayActiveDriversOnMap();
            break;

          //Whenever driver moves - update the driver location
          case Geofire.onKeyMoved:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver =
                ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.updateActiveNearbyAvailableDriverLocation(
                activeNearbyAvailableDriver);
            displayActiveDriversOnMap();
            break;

          //Display the online active drivers on the map.
          case Geofire.onGeoQueryReady:
            activeNearbyDriverKeysLoaded = true;
            displayActiveDriversOnMap();
            break;
        }
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  displayActiveDriversOnMap() {
    if (mounted) {
      setState(() {
        markersSet.clear();
        circlesSet.clear();

        Set<Marker> driversMarkerSet = Set<Marker>();

        for (ActiveNearbyAvailableDrivers eachDriver
            in GeoFireAssistant.activeNearbyAvailableDriversList) {
          LatLng eachDriverActivePosition = LatLng(
              eachDriver.locationLatitude!, eachDriver.locationLongitude!);
          Marker marker = Marker(
            markerId: MarkerId(eachDriver.driverId!),
            position: eachDriverActivePosition,
            icon: activeNearbyDriverIcon!,
            rotation: 360,
          );

          driversMarkerSet.add(marker);
        }

        if (mounted) {
          setState(() {
            markersSet = driversMarkerSet;
          });
        }
      });
    }
  }

  //custom map marker for nearby drivers
  createActiveNearbyDriverIconMarker() {
    if (activeNearbyDriverIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "images/carMarker.png")
          .then((value) {
        activeNearbyDriverIcon = value;
      });
    }
  }
}
