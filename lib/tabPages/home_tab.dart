import 'dart:async';
import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/mainScreens/search_places_screen.dart';
import 'package:drivers_app/widgets/my_drawer.dart';
import 'package:drivers_app/widgets/progress_dialogue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../infoHandler/app_info.dart';

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
  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String userName = "";
  String userEmail = "";

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

    // print("this is your current address : $humanReadableAddress");

    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;
  }

  @override

  void initState(){
    super.initState();

    checkIfLocationPermissionAllowed();
  }

  @override
  Widget build(BuildContext context) {
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

                //Function for getting user location
                locateUserPosition();

                setState(() {
                  bottomPaddingOfMap = 220;
                });
              },
            ),

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
                    color: Color(0xffE8F9FD), //e3f2fd , e2eafc
                    borderRadius: BorderRadius.only(
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
                                      ? "${(Provider.of<AppInfo>(context).userPickupLocation!.locationName!).substring(0, 55)} ..."
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
                            var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder:(c)=> SearchPlacesScreen()));

                            if(responseFromSearchScreen == "obtainedDropOff"){
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
                                    Provider.of<AppInfo>(context).userDropOffLocation != null
                                        ? Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
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

                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFAA33),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)
                              ),
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                          child: const Text(
                            "Search Ride",
                            style: TextStyle(color: Colors.white, fontSize: 14,),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Future<void> drawPolyLineFromOriginToDestination() async{
    var originPosition = Provider.of<AppInfo>(context, listen: false).userPickupLocation;
    var destinationPosition = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;


    var originLatLng = LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);

      debugPrint("Origin LatLang :$originLatLng");
      debugPrint('Destination LatLang :' + destinationLatLng.toString());


    //wait till the api fetches data and show some message to the user till data is fetched.
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialogue(message: "Please wait...",),
    );

    var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

    Navigator.pop(context);

    print("These are the points = ");
    print(directionDetailsInfo!.e_points);
    print(directionDetailsInfo.distance_text);
    print(directionDetailsInfo.distance_value);
    print(directionDetailsInfo.duration_text);
    print(directionDetailsInfo.duration_value);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    pLineCoordinatesList.clear();

    if(decodedPolyLinePointsResultList.isNotEmpty){
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng)
      {
        pLineCoordinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));

      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.orange,
        polylineId: const PolylineId("PolyLineID"),
        jointType: JointType.round,
        points: pLineCoordinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polyLineSet.add(polyline);
    });


    //This will help to adjust the zoom as per origin and destination
    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(
          southwest: destinationLatLng,
          northeast: originLatLng
      );
    }else if(originLatLng.longitude > destinationLatLng.longitude ){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude)
      );

    }else if(originLatLng.latitude> destinationLatLng.latitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude)
      );
  }
    else{
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng );
    }

    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));


    //Markers to show user current position and destination
    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow: InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle =  Circle(
      circleId:const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.red,
      center: originLatLng,
    );

    Circle destinationCircle =  Circle(
      circleId:const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });

    }

}
