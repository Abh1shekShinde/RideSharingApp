import 'dart:developer';

import 'package:drivers_app/assistants/request_assistant.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/global/map_key.dart';
import 'package:drivers_app/infoHandler/app_info.dart';
import 'package:drivers_app/models/direction_details_info.dart';
import 'package:drivers_app/models/directions.dart';
import 'package:drivers_app/models/user_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AssistantMethods {

  static Future<String> searchAddressForGeographicCoordinates(Position position, context) async{
   String humanReadableAddress = "";

    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

   //https://maps.googleapis.com/maps/api/directions/json?origin=&destination=&key=AIzaSyAinQPUI5y_Rsw_gk7rgo8z315_E25-k2Y";


    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if(requestResponse != "Error Occurred. Try Again"){
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickupAddress = Directions();
      userPickupAddress.locationLatitude = position.latitude;
      userPickupAddress.locationLongitude= position.longitude;
      userPickupAddress.locationName = humanReadableAddress;

        Provider.of<AppInfo>(context, listen: false)
            .updatePickupLocationAddress(userPickupAddress);

    }
    return humanReadableAddress;
  }


  static void readCurrentOnlineUserInfo() async{
    currentFirebaseUser  = fAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(currentFirebaseUser!.uid);

  userRef.once().then((snap){
    if(snap.snapshot.value != null) {
      userModelCurrentInfo =  UserModel.fromSnapshot(snap.snapshot);
    }
    });
  }
  

  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async{

    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    https://maps.googleapis.com/maps/api/directions/json?origin=Disneyland&destination=Universal+Studios+Hollywood&key=AIzaSyAinQPUI5y_Rsw_gk7rgo8z315_E25-k2Y
    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

    // print("------------------------------------------------");
    // print("This is response from Directions API" + responseDirectionApi);


    if(responseDirectionApi == "Error Occurred. Try Again"){
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();

    directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;

  }

  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){


    //These 0.1 value is random and can be changed as per your preference.
     double timeTravelledFarePerMinute = (directionDetailsInfo.duration_value! / 60) * 0.1;

     double distanceTravelledFarePerKilometer = (directionDetailsInfo.distance_value! / 1000) * 0.1;

     // 1 USD = 80 Rupees then multiply by 80
     double totalFareAmount = (timeTravelledFarePerMinute + distanceTravelledFarePerKilometer) * 80;

     return double.parse(totalFareAmount.toStringAsFixed(2));
     //toStringAsFixed will limit the double value to max 2 places just like roundup.
  }

}