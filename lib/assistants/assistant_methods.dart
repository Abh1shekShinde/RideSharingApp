import 'dart:convert';
import 'dart:developer';

import 'package:drivers_app/assistants/request_assistant.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/global/map_key.dart';
import 'package:drivers_app/infoHandler/app_info.dart';
import 'package:drivers_app/models/direction_details_info.dart';
import 'package:drivers_app/models/directions.dart';
import 'package:drivers_app/models/user_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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

    //These 0.01 value is random and can be changed as per your preference.
     double timeTravelledFarePerMinute = (directionDetailsInfo.duration_value! / 60) * 0.01;

     double distanceTravelledFarePerKilometer = (directionDetailsInfo.distance_value! / 1000) * 0.05;

     // 1 USD = 80 Rupees then multiply by 80
     double totalFareAmount = (timeTravelledFarePerMinute + distanceTravelledFarePerKilometer) * 50;

     //"Car", "Bike", "Scooter"
     if(driverVehicleType == "Car"){
       double resultFareAmount = (totalFareAmount.truncate()) * 1.8;
       return resultFareAmount;
     }else if(driverVehicleType == "Bike"){
       double resultFareAmount = (totalFareAmount.truncate().toDouble());
       return resultFareAmount;
     }else if(driverVehicleType == "Scooter"){
       double resultFareAmount = (totalFareAmount.truncate()) / 1.25;
       return resultFareAmount;
     }else{
       return totalFareAmount.truncate().toDouble();
     }

     // return double.parse(totalFareAmount.toStringAsFixed(2));
     //toStringAsFixed will limit the double value to max 2 places just like roundup.
  }

  static pauseLiveLocationUpdates(){
    streamSubscriptionPosition?.pause();
    Geofire.removeLocation(currentFirebaseUser!.uid);
  }

  static resumeLiveLocationUpdates(){
    streamSubscriptionPosition!.resume();
    Geofire.setLocation(
        currentFirebaseUser!.uid,
        userCurrentPosition!.latitude,
        userCurrentPosition!.longitude);
  }

  static sendNotificationToDriverNow(String deviceRegistrationToken, String userRideRequestId, context) async{

    String destinationAddress = userDropOffAddress;

    //All the below maps are done as per requirements and also done in postman
    Map<String , String> headerNotification ={
      "Content-Type": 'application/json',
      "Authorization": cloudMessagingServerToken,
    };

    Map bodyNotification = {
      "body":"You have a new ride share Request. \nTo:$destinationAddress",
      "title":"New Share Request"
    };

    Map dataMap ={
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id" : "1",
      "status" : "done",
      "rideRequestId" : userRideRequestId,
    };

    Map officialNotificationFormat = {
      "notification" : bodyNotification,
      "data" : dataMap,
      "priority" : "high",
      "to" : deviceRegistrationToken,
    };

    var responseNotification = http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: headerNotification,
        body: jsonEncode(officialNotificationFormat),
    );

  }

}